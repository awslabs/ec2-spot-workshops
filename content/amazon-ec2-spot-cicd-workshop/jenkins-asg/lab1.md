+++
title = "Jenkins with Amazon EC2 Auto Scaling Groups"
weight = 110
+++
By default, all job builds will be executed on the same instance that Jenkins is running on. This results in a couple of less-than-desirable behaviours:
* When CPU-intensive builds are being executed, there may not be sufficient system resources to display the Jenkins server interface; and
* The Jenkins server is often provisioned with more resources than the server interface requires in order to allow builds to execute. When builds are not being executed, these server resources are essentially going to waste.

To address these behaviours, Jenkins provides the capability to execute builds on external hosts (called build agents). Further, AWS provides a Jenkins plugin to allow Jenkins to scale out a fleet of EC2 instances in order to execute build jobs on. This lab will focus on implementing EC2 Spot build agents, showcasing what a batch processing workload typically looks like when using Amazon EC2 Spot instances.

## Setting Up environment variables

```bash
export VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values='Amazon EC2 Spot CICD Workshop VPC' | jq -r '.Vpcs[0].VpcId');
export SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="${VPC_ID}" --filters Name=tag:Type,Values='Private');
export SUBNET_1=$((echo $SUBNETS) | jq -r '.Subnets[0].SubnetId');
export SUBNET_2=$((echo $SUBNETS) | jq -r '.Subnets[1].SubnetId');
export SUBNET_3=$((echo $SUBNETS) | jq -r '.Subnets[2].SubnetId');
export LAUNCH_TEMPLATE_ID=$(aws ec2 describe-launch-templates --filters Name=launch-template-name,Values=JenkinsBuildAgentLaunchTemplate | jq -r '.LaunchTemplates[0].LaunchTemplateId');
```

## Provision an Auto Scaling Group for your build agents
Before configuring the EC2 Fleet Jenkins Plugin, create an Auto Scaling Group (ASG) that will be used by the plugin to perform your application builds. As this is a batch processing use case, remember the best practices for this type of workload - leverage per-second billing (catered for through the use of an Amazon Linux AMI defined in the Launch Template); determine job completion and retry failed jobs (the former is handled by the Jenkins EC2 Fleet plugin); and be instance flexible.

First, you are going to create the configuration file that will be used to launch the EC2 Fleet. Run the following commands:

```bash
cat <<EoF > ~/asg-policy.json
{
   "LaunchTemplate":{
      "LaunchTemplateSpecification":{
         "LaunchTemplateId":"${LAUNCH_TEMPLATE_ID}",
         "Version":"1"
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

Copy and paste this command to create the EC2 Fleet and export its identifier to an environment variable to later monitor the status of the fleet.

```bash
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsASG --min-size 0 --max-size 2 --desired-capacity 1 --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --mixed-instances-policy file://asg-policy.json
```

## Sign-in to Jenkins
The CloudFormation template deployed during the Workshop Preparation stage deployed a Jenkins server on to an on-demand instance within your VPC and configured an Application Load Balancer (ALB) to proxy requests from the public Internet to the server. You can obtain the DNS name for the ALB from the Output tab of your CloudFormation template. Point your web browser to this DNS name and sign in using **admin** as the Username and the password that you supplied to the CloudFormation template as the password.
{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1));
2. Click on the checkbox associated with the **SpotCICDWorkshop** stack, then click on the **Outputs** tab toward the bottom of the screen;
3. Make a note of the DNS name for the Application Load Balancer, which is associated with the **JenkinsDNSName** key;
4. Open up a new tab in your browser and enter the DNS name in the address bar. You should be greeted with a Jenkins Sign In screen:
    1. Enter in **admin** as the Username;
    2. Enter in the password that you supplied to the CloudFormation template as the Password.
{{% /expand%}}

## Configure the EC2 Fleet Jenkins plugin
The EC2 Fleet Jenkins Plugin was installed on the Jenkins server during the CloudFormation deployment - but now the plugin needs to be configured. You'll need to get the plugin to **Launch slave agents via SSH** and provide valid SSH credentials (don't forget to consider how Host Key Verification should be set when using Spot instances).

When configuring the plugin, think about how you could force build processes to run on the spot instances (use the **spot-agents** label), and consider how you can verify that the fleet scales out when there is a backlog of build jobs waiting to be processed.

{{%expand "Click to reveal detailed instructions" %}}
1. From the Jenkins home screen, click on the **Manage Jenkins** link on the left side menu, and then the **Manage Nodes and Clouds** link;
2. Click on the **Configure Clouds** link on the left side menu, then click on the **Add a new cloud** dropdown, followed by the **Amazon EC2 Fleet** option;
3. You don't need to configure any AWS Credentials as the plugin will use the IAM Role attached to the instance;
4. Select **eu-west-1 EU (Ireland)** from the Region dropdown - the plugin will now attempt to obtain a list of EC2 Fleet requests made in the selected region;
6. Select the Request Id of the EC2 Fleet that you created earlier from the Spot Fleet dropdown (though it might already be selected) and then select the **Launch slave agents via SSH** option from the Launcher dropdown - this should reveal additional SSH authentication settings;
7. Click the **Add** button next to the Credentials dropdown and select the **Jenkins** option. This will pop up another **Jenkins Credentials Provider: Jenkins** sub-form. Fill out the form as follows:
    1. Change the Kind to **SSH Username with private key**;
    2. Change the Scope to **System (Jenkins and nodes only)** – you also don’t want your builds to have access to these credentials;
    3. At the Username field, enter **ec2-user**;
    4. For the Private Key, select the **Enter directly** radio button. Open the .pem file that you downloaded during the workshop setup in a text editor and copy the contents of the file to the Key field including the BEGIN RSA PRIVATE KEY and END RSA PRIVATE KEY fields;
    5. Click on the **Add** button.
8. Select the ec2-user option from the Credentials dropdown;
9. Given that Spot instances will have a random SSH host fingerprint, select the **Non verifying Verification Strategy** option from the Host Key Verification Strategy dropdown;
10. Mark the **Private IP** checkbox to ensure that your Jenkins Master will always communicate with the Agents via their internal VPC IP addresses (in real-world scenarios, your build agents would likely not be publicly addressable);
11. Change the Label field to be **spot-agents** - you'll shortly configure a build job to run on slave instances featuring this label;
12. Set the Max Idle Minutes Before Scaledown to **5**. There's no need to keep a build agent running for too much longer than it's required;
13. Change the Minimum Cluster Size from **1** to **0** (so that it can scale-in to zero instances);
14. Change the Maximum Cluster Size from **1** to **2** (so that you can test fleet scale-out);
15. Finally, click on the **Save** button.

Within sixty-seconds, the Jenkins Slave Agent should have been installed on to the Spot instance that was launched by your EC2 fleet; you should see an EC2 instance ID appear underneath the Build Executor Status section on the left side of the Jenkins user interface. Underneath that, you should see that there is a single Build Executor on this host, which is in an idle state.
{{% /expand%}}

## Configure a build job to use the new Spot instance(s)
As alluded to in the previous section, you'll need to configure your build jobs so that they are executed on the build agents running in your Spot instances. In addition, you could configure jobs to execute concurrent builds if necessary - this will help you in testing the scale-out of your fleet.

{{%expand "Click to reveal detailed instructions" %}}
1. Go back to the Jenkins home screen and **repeat the following for each of the five Apache build projects** that are configured in your Jenkins instance:
    1. Click on the title of the build job and then click on the **Configure** link toward the left side of the screen;
    2. In the General section, click on the **Execute concurrent builds if necessary** checkbox and the **Restrict where this project can be run** checkbox. Next, enter **spot-agents** as the Label Expression (Note: if you select the auto-complete option instead of typing out the full label, Jenkins will add a space to the end of the label - be sure to remove any trailing spaces from the label before proceeding);
    3. Click on the **Save** button towards the bottom of the screen.
{{% /expand%}}

## Test Spot Builds and Scale-out
Now it’s time to test out how Jenkins handles pushing builds to spot instances running build agents at scale. There are two things that you'll want to verify here; that your builds run successfully on the Spot instances, and that your ASG scales out when there are build jobs queued for more than a few minutes.

1. Go Back to the Jenkins home page, click on the **Schedule a Build** icon (which looks like a play symbol) for each of the five Apache projects, starting from the **Apache PDFBox** project and working upward. This will queue up five build jobs, the first of which will be immediately assigned to the Spot instance to be worked on;
2. When any of the build jobs have been completed, click on the **Schedule a Build** icon corresponding to that job to re-add it back to the build queue - the intent here is to keep the build queue populated with a backlog of build jobs until your Spot Fleet has scaled out and build jobs are executing on both Spot instances;
3. After a couple of minutes (typically during the first **Apache Helix** build - around four minutes after you initiate the first build), the EC2 Fleet Status reported to the left of the screen will increment the **target** count to 2, indicating that the plugin has requested a scale-out action from the plugin. After a few moments, a second build instance will appear in the **Build Executor Status**, though this build agent will initially appear to be offline. Once the instance has had the chance to complete the launch and bootstrapping processes (which takes around two minutes), your Jenkins Master will deploy the build agent to it via SSH, and it will come online and process the next build job in the queue. Once you have concurrent builds being executed on two Spot instances, you can stop adding build jobs to the build queue;
4. After a period of around a five minutes after your builds have completed, one of the Spot instances should be terminated by the plugin - there's no need to wait for this to happen (take our word for it, but you can verify this later).

-----

You're now using Spot instances for your code builds and for the environments that are built out for testing – but your Jenkins server is still using an on-demand instance. Jenkins itself does not natively support running in high-availability configurations because it persists all data on a local file system. If you can store this data durably somewhere else than on the local file system, you can move your Jenkins Master instance to a self-healing Spot instance. To provide persistence for this file system data, you’ll move your Jenkins data to an Elastic File System (EFS) volume and mount this volume on instance spawned by a Spot Fleet.

## OBTAIN THE RELEVANT INFORMATION FOR CLOUDFORMATION FOR THIS LAB
As with the previous labs, the CloudFormation stack deployed during your Workshop Preparation has provisioned some of the resources required for this lab (in order to allow us to focus on the aspects of the workshop that directly apply to EC2 Spot). You will need to determine and make a note of what the **EFS Filesystem ID** is.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#));
2. Click on the checkbox associated with the **SpotCICDWorkshop** stack;
3. From the Outputs tab of the SpotCICDWorkshop stack in the CloudFormation console, make note of values associated with the **EFSFileSystemID** key.
{{% /expand%}}

## COPY THE CONTENTS OF JENKINS_HOME TO YOUR EFS FILE SYSTEM
In order to copy the contents of the JENKINS_HOME directory to the EFS file system (for which the ID of which you determined in the previous step), you'll need to first mount the file system on the EC2 instance currently running your Jenkins server.

Once the file system has been mounted, stop the Jenkins service and set the file system permission of the root of your filesystem so that the jenkins user and group are owners. Finally, copy the contents of **/var/lib/jenkins** (this is the JENKINS_HOME directory) across to the root of your EFS file system.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **EC2** console and select the **Instances** option from the left pane (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances:sort=instanceId));
2. Select the instance with the Name tag of **Jenkins Master (On-demand)** and make a note of it's current IPv4 Pubic IP;
3. Establish an SSH session to this IP address (For instructions on how to establish an SSH connection to your EC2 instance, please refer to [this link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html?icmpid=docs_ec2_console)) - you'll need to use the EC2 Key Pair that you generated during the Workshop Preparation to establish connectivity;
4. Mount the EFS file system that was created by the CloudFormation template at the /mnt mountpoint by entering the following command, replacing %FILE-SYSTEM-ID% with the EFSFileSystemID noted above:
 
    ```bash
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)\
.%FILE-SYSTEM-ID%.efs.eu-west-1.amazonaws.com:/ /mnt
```
5. Stop the Jenkins service by entering the following command:

    ```bash
sudo service jenkins stop
```

6. The content of JENKINS_HOME is stored under /var/lib/jenkins – copy this content (whilst preserving permissions) to your EFS file system mount point (/mnt) using the following commands (note that this will take a couple of minutes - while it's progressing, commence the next section of this lab):

    ```bash
sudo chown jenkins:jenkins /mnt
sudo cp -rpv /var/lib/jenkins/* /mnt
```
{{% /expand%}}

## PROVISION AN EC2 SPOT FLEET FOR YOUR NEW JENKINS HOST
The Spot Fleet that you'll provision for your Jenkins server will be configured in a similar manner to what you did for the build agents - though this time you'll be a bit more aggressive with the bid price to ensure that you see an overall saving over what you would have spent on an on-demand t3.medium instance. Additionally, you'll configure this Spot Fleet so that the instances are associated with the Target Group used by the Application Load Balancer that you've been using to access Jenkins.

1. Go to the **EC2** console and click on the **Spot Requests** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2sp/v1/spot/home?region=eu-west-1#));
2. Click on the **Request Spot Instances** button;
3. At the first screen of the Spot instance launch wizard:
    1. Under the Tell us your application or task need heading, switch to the **Load balancing workloads** option;
    2. In the Configure your instances section, select the **JenkinsMasterLaunchTemplate** template from the Launch template dropdown. Change the Network to be the **Spot CICD Workshop VPC**. After making this selection, enable the check boxes for all three Availability Zones and then select the **Amazon EC2 Spot CICD Workshop Public Subnet** associated with each availability zone as the subnet to launch instances in;
    3. At the Tell us how much capacity you need section, keep the Total target capacity at **1** instance and the Optional On-Demand portion set to **0**, and then tick the **Maintain target capacity** checkbox. Once selected, leave the Interruption behavior set to **Terminate**;
    4. Again, you'll override the recommendations made by the console, so clear the tick from **Apply recommendations** checkbox. Click on the **Remove** links associated with the all of the instance types initially defined to remove them from the fleet configuration. Then click on the **Select instance types** button and add the **m3.large**, **m4.large**, **t2.medium** and **t3.medium** instance types to the fleet definition. Once the checkboxes for the required instance types have been ticked, click on the **Select** button. Once you have the four desired instance types listed in the fleet request, select the **Lowest Price** Fleet allocation strategy (since we’re interested in keeping cost to an absolute minimum for this use case, and it makes little sense to diversify a single instance across any number of instance pools);
    5. At the Additional request details section, remove the tick from the **Apply defaults** checkbox. As you want to keep the cost of running your Jenkins server below that for which you're currently paying, select the **Set your max price (per instance/hour)** option, and set the price to be the on-demand price of a t3.medium instance in the Ireland region, which is **$0.0456**. In order to ensure that the server can receive HTTP requests from the Application Load Balancer you've been using, tick the checkbox labelled **Receive traffic from one or more load balancers** and from the Target groups dropdown, select **JenkinsMasterEC2TargetGroup**.
    6. Review the Your fleet request as a glance section - it should indicate that your Fleet strength is strong as a result of being able to draw instances from 12 instance pools, and your Estimated price should indicate that you're expecting to make a 73% saving compared to the cost of equivalent on-demand resources;
    7. Lastly, click on the **Launch** button.

## VERIFY THAT YOUR EC2 SPOT INSTANCE IS ATTACHED TO YOUR ALB TARGET GROUP
After a few moments, your Spot instance will start up and should attach itself the the Target Group being used by your Application Load Balancer. Determine if this registration has completed successfully and when it has done so, access Jenkins through your Load Balancer and fire off a build of Apache PDFBox to ensure that everything is still working as expected.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **EC2** console and click on the **Target Groups** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#TargetGroups));
2. Select the checkbox corresponding to the target group named **JenkinsMasterEC2TargetGroup**, then select the **Targets** tab. You should see your **Jenkins Master (On-demand)** instance with an unhealthy status (as a result of you stopping the Jenkins service on this host). Depending on how quickly you’ve got to this point, you might also see a second instance registered in the target group – the **Jenkins Master (Spot)** instance from the fleet that you just launched. If you don’t see it, it’s likely that your new spot instance isn't up and running yet – something that usually takes a minute or two to complete after placing your Spot Fleet request. Refresh the list of targets every minute or so until the **Jenkins Master (Spot)** instance appears in the list. While there are no healthy instances in the target group, your web browser should return a HTTP 502 error when you attempt to load Jenkins through your ALB;
3. When the **Jenkins Master (Spot)** instance is shown with a healthy status, you should then be able to reload Jenkins through the ALB's DNS name. Once you can do so, initiate a build of the **Apache PDFBox** project to ensure that everything is working as expected.
{{% /expand%}}

## TEST THE SELF-HEALING ARCHITECTURE BY TERMINATING THE RUNNING EC2 SPOT INSTANCE
What happens when the market price for the capacity pool that your EC2 Spot instance is running in goes over your $0.0456 per instance-hour bid price?

When this happens, your EC2 Spot instance will be provided with a two-minute notice of termination and after that time lapses, the instance will be terminated. At this point, Spot Fleet will observe that there are no running instances in the fleet and because the desired capacity is one, it will attempt to launch a replacement instance in a capacity pool that is still below the per instance-hour bid price that you set (this is why diversification across many capacity pool is a best practice). If such an instance is available, a replacement instance will be launched and bootstrapped in exactly the same manner as your original instance.

Test this out by terminating the Spot instance with the **Jenkins Master (Spot)** name tag and verifying that a replacement instance comes up to take its place.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **EC2** console and click on the **Instances** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances));
2. Search for the EC2 instance with the Name tag of **Jenkins Master (Spot)**, right-click on it and select the **Instance State** > **Terminate** option. At the confirmation pop-up, click on the **Yes, Terminate** option. Within moments of terminating this instance, your Spot Fleet registration should detect that the number of running instances is below the target that you’ve defined (that target being one instance) and therefore should launch a new, replacement spot instance. Refresh the list of EC2 instances every few seconds until you see the new instance be allocated (while you're waiting, it might also be interesting to see what's happening under the History tab of your Spot Fleet). Whilst your Jenkins service will be unavailable until this new spot instance launches and bootstraps, service should automatically be restored in a couple of minutes.
{{% /expand%}}

## TERMINATE THE ON-DEMAND INSTANCE THAT WAS INITIALLY USED FOR YOUR JENKINS SERVER
Once you've verified that your Spot Fleet is self-healing, you no longer have any need for the On-demand instance. To prevent it from incurring unnecessary cost, it can be terminated.

{{%expand "Click to reveal detailed instructions" %}}
1. Remain at the EC2 Instances screen and search for the EC2 instance with the Name tag of **Jenkins Master (On-demand)**. Right-click on the one instance that should come up and select the **Instance State** > **Terminate** option. At the confirmation pop-up, click on the **Yes, Terminate** option.
{{% /expand%}}