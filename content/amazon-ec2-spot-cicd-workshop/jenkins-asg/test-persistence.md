+++
title = "Configure Persistence Storage when using Spot"
weight = 125
+++
You're now using Spot instances for your code builds – but your Jenkins server is still using an on-demand instance. Jenkins itself does not natively support running in high-availability configurations because it persists all data on a local file system. If you can store this data durably somewhere else than on the local file system, you can move your Jenkins Master instance to a self-healing Spot instance. To provide persistence for this file system data, you’ll move your Jenkins data to an Elastic File System (EFS) volume and mount this volume on instance spawned by an Auto Scaling group.

## Get the EFS Filesystem ID
As with the previous steps, the CloudFormation stack deployed during your Workshop Preparation has provisioned some of the resources required for this lab. You will need to determine and make a note of what the **EFS Filesystem ID** is. To get it, run the following command get the ID from the CloudFormation stack output:

```bash
aws cloudformation describe-stacks --stack-name SpotCICDWorkshop --query "Stacks[0].Outputs[?OutputKey=='EFSFileSystemID'].OutputValue" --output text;
```

## Copy the contents of Jenkins home to your EFS file system
In order to copy the contents of the `JENKINS_HOME` directory to the EFS file system, you'll need to first mount the file system on the EC2 instance currently running your Jenkins server. To do so, SSH into the Jenkins server:

1. Go to the **EC2** console and select the **Instances** option from the left pane (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances:sort=instanceId));
2. Select the instance with the Name tag of **Jenkins Master (On-demand)** and make a note of it's current IPv4 Pubic IP;
3. Establish an SSH session to this IP address (For instructions on how to establish an SSH connection to your EC2 instance, please refer to [this link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html?icmpid=docs_ec2_console)) - you'll need to use the EC2 Key Pair that you generated during the Workshop Preparation to establish connectivity;

Then, run the following command and replace the `EFSFileSystemID` text with the ID you got in the previous section:

```bash
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)\
.EFSFileSystemID.efs.eu-west-1.amazonaws.com:/ /mnt
```

Once the file system has been mounted, stop the Jenkins container. 

```bash
cd /usr/share/jenkins
docker-compose stop
```

The content of `JENKINS_HOME` is stored under /jenkins_home – copy this content to your EFS file system mount point (/mnt) using the following commands (note that this will take a couple of minutes - while it's progressing, commence the next section of this lab):

```bash
sudo cp -rpv /jenkins_home/* /mnt
```

## Provision an Auto Scaling group for the new Jenkins host
The Auto Scaling group that you'll provision for your Jenkins server will be configured in a similar manner to what you did for the build agents. Additionally, you'll configure this Auto Scaling group so that the instances are associated with the Target Group used by the Application Load Balancer that you've been using to access Jenkins.

Run the following commands to create the Auto Scaling group configuration file:

```bash
export LAUNCH_TEMPLATE_HOST_ID=$(aws ec2 describe-launch-templates --filters Name=launch-template-name,Values=JenkinsMasterLaunchTemplate | jq -r '.LaunchTemplates[0].LaunchTemplateId');
cat <<EoF > ~/asg-jenkins-host-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_HOST_ID}",
         "Version":"\$Latest"
      },
      "Overrides":[
         {
            "InstanceType":"t2.large"
         },
         {
            "InstanceType":"t3.large"
         },
         {
            "InstanceType":"m4.large"
         },
         {
            "InstanceType":"m5.large"
         },
         {
            "InstanceType":"c5.large"
         },
         {
            "InstanceType":"c4.large"
         }
      ]
   },
   "InstancesDistribution":{
      "OnDemandBaseCapacity": 0,
      "OnDemandPercentageAboveBaseCapacity": 0,
      "SpotAllocationStrategy":"capacity-optimized"
   }
}
EoF
```

Then, run the following command to create the Auto Scaling group. Notice that you might need to re-create the environment variables you created before.

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsHostASG --min-size 1 --max-size 1 --desired-capacity 1 --vpc-zone-identifier "${PUBLIC_SUBNETS}" --mixed-instances-policy file://asg-jenkins-host-policy.json;
```

To include the new instances into the Application Load Balancer, attach the Auto Scaling group to the Target Group by running the following command:

```bash
export EC2_TARGET_GROUP=$(aws cloudformation describe-stacks --stack-name SpotCICDWorkshop --query "Stacks[0].Outputs[?OutputKey=='JenkinsMasterEC2TargetGroup'].OutputValue" --output text);
aws autoscaling attach-load-balancer-target-groups \
    --auto-scaling-group-name EC2SpotJenkinsHostASG \
    --target-group-arns $EC2_TARGET_GROUP;
```

## Verify that the new Spot instance is running the Jenkins server
After a few moments, your Spot instance will start up and should attach itself the the Target Group being used by your Application Load Balancer. Determine if this registration has completed successfully and when it has done so, access Jenkins through your Load Balancer and fire off a build of Apache PDFBox to ensure that everything is still working as expected.

1. Go to the **EC2** console and click on the **Target Groups** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#TargetGroups));
2. Select the checkbox corresponding to the target group named **JenkinsMasterEC2TargetGroup**, then select the **Targets** tab. You should see your **Jenkins Master (On-demand)** instance with an unhealthy status (as a result of you stopping the Jenkins service on this host). Depending on how quickly you’ve got to this point, you might also see a second instance registered in the target group – the **Jenkins Master (Spot)** instance from the Auto Scaling group that you just created. If you don’t see it, it’s likely that your new spot instance isn't up and running yet – something that usually takes a minute or two to complete. Refresh the list of targets every minute or so until the **Jenkins Master (Spot)** instance appears in the list. While there are no healthy instances in the target group, your web browser should return a HTTP 502 error when you attempt to load Jenkins through your ALB;
3. When the **Jenkins Master (Spot)** instance is shown with a healthy status, you should then be able to reload Jenkins through the ALB's DNS name. Once you can do so, initiate a build of the **Apache PDFBox** project to ensure that everything is working as expected.

## Test the self-healing architecture running with Spot instances
At some point in time, you might receive a Spot interruption notice when On-Demand needs the capacity back. When this happens, your Spot instance will be provided with a two-minute notice of termination and after that time lapses, the instance will be terminated. At this point, the Auto Scaling group will observe that there are no running instances in the group and because the desired capacity is one, it will attempt to launch a replacement instance the pool with more capacity available (this is why diversification across many capacity pool is a best practice). The new instance will be launched and bootstrapped in exactly the same manner as your original instance.

Test this out by terminating the Spot instance with the **Jenkins Master (Spot)** name tag and verifying that a replacement instance comes up to take its place.

1. Go to the **EC2** console and click on the **Instances** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances));
2. Search for the EC2 instance with the Name tag of **Jenkins Master (Spot)**, right-click on it and select the **Instance State** > **Terminate** option. At the confirmation pop-up, click on the **Yes, Terminate** option. Within moments of terminating this instance, your Auto Scaling group should detect that the number of running instances is below the target that you’ve defined (that target being one instance) and therefore should launch a new, replacement spot instance. Refresh the list of EC2 instances every few seconds until you see the new instance be allocated. Whilst your Jenkins service will be unavailable until this new spot instance launches and bootstraps, service should automatically be restored in a couple of minutes.

## Terminate the On-Demand instance for Jenkins
Once you've verified that your new Auto Scaling group using Spot instances is self-healing, you no longer have any need for the On-demand instance. To prevent it from incurring unnecessary cost, it can be terminated.

1. Remain at the EC2 Instances screen and search for the EC2 instance with the Name tag of **Jenkins Master (On-demand)**. Right-click on the one instance that should come up and select the **Instance State** > **Terminate** option. At the confirmation pop-up, click on the **Yes, Terminate** option.