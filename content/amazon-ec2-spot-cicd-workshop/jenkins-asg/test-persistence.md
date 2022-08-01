+++
title = "Configure Persistence Storage when using Spot"
weight = 125
+++
You're now using Spot instances for your code builds – but your Jenkins server is still using an on-demand instance. Jenkins itself does not natively support running in high-availability configurations because it persists all data on a local file system. If you can store this data durably somewhere else than on the local file system, you can move your Jenkins Master instance to a self-healing Spot instance. To provide persistence for this file system data, you’ll move your Jenkins data to an Elastic File System (EFS) volume and mount this volume on instance spawned by an Auto Scaling group.

## Get the EFS Filesystem ID
As with the previous steps, the CloudFormation stack deployed during your Workshop Preparation has provisioned some of the resources required for this lab. You will need to determine and make a note of what the **EFS Filesystem ID** is.

1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#));
2. Click on the checkbox associated with the **SpotCICDWorkshop** stack;
3. From the Outputs tab of the SpotCICDWorkshop stack in the CloudFormation console, make note of values associated with the **EFSFileSystemID** key.

## COPY THE CONTENTS OF JENKINS_HOME TO YOUR EFS FILE SYSTEM
In order to copy the contents of the `JENKINS_HOME` directory to the EFS file system (for which the ID of which you determined in the previous step), you'll need to first mount the file system on the EC2 instance currently running your Jenkins server.

Once the file system has been mounted, stop the Jenkins service and set the file system permission of the root of your filesystem so that the jenkins user and group are owners. Finally, copy the contents of **/jenkins_home** (this is the `JENKINS_HOME` directory) across to the root of your EFS file system.

1. Go to the **EC2** console and select the **Instances** option from the left pane (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances:sort=instanceId));
2. Select the instance with the Name tag of **Jenkins Master (On-demand)** and make a note of it's current IPv4 Pubic IP;
3. Establish an SSH session to this IP address (For instructions on how to establish an SSH connection to your EC2 instance, please refer to [this link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html?icmpid=docs_ec2_console)) - you'll need to use the EC2 Key Pair that you generated during the Workshop Preparation to establish connectivity;
4. Mount the EFS file system that was created by the CloudFormation template at the /mnt mountpoint by entering the following command, replacing `%FILE-SYSTEM-ID%` with the **EFSFileSystemID** noted above:
 
```bash
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)\
.%FILE-SYSTEM-ID%.efs.eu-west-1.amazonaws.com:/ /mnt
```
5. Stop the Jenkins service by entering the following commands:

```bash
cd /usr/share/jenkins
sudo docker-compose stop
```

6. The content of `JENKINS_HOME` is stored under /jenkins_home – copy this content (whilst preserving permissions) to your EFS file system mount point (/mnt) using the following commands (note that this will take a couple of minutes - while it's progressing, commence the next section of this lab):

```bash
sudo cp -rpv /jenkins_home/* /mnt
```

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

1. Go to the **EC2** console and click on the **Target Groups** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#TargetGroups));
2. Select the checkbox corresponding to the target group named **JenkinsMasterEC2TargetGroup**, then select the **Targets** tab. You should see your **Jenkins Master (On-demand)** instance with an unhealthy status (as a result of you stopping the Jenkins service on this host). Depending on how quickly you’ve got to this point, you might also see a second instance registered in the target group – the **Jenkins Master (Spot)** instance from the fleet that you just launched. If you don’t see it, it’s likely that your new spot instance isn't up and running yet – something that usually takes a minute or two to complete after placing your Spot Fleet request. Refresh the list of targets every minute or so until the **Jenkins Master (Spot)** instance appears in the list. While there are no healthy instances in the target group, your web browser should return a HTTP 502 error when you attempt to load Jenkins through your ALB;
3. When the **Jenkins Master (Spot)** instance is shown with a healthy status, you should then be able to reload Jenkins through the ALB's DNS name. Once you can do so, initiate a build of the **Apache PDFBox** project to ensure that everything is working as expected.

## TEST THE SELF-HEALING ARCHITECTURE BY TERMINATING THE RUNNING EC2 SPOT INSTANCE
What happens when the market price for the capacity pool that your EC2 Spot instance is running in goes over your $0.0456 per instance-hour bid price?

When this happens, your EC2 Spot instance will be provided with a two-minute notice of termination and after that time lapses, the instance will be terminated. At this point, Spot Fleet will observe that there are no running instances in the fleet and because the desired capacity is one, it will attempt to launch a replacement instance in a capacity pool that is still below the per instance-hour bid price that you set (this is why diversification across many capacity pool is a best practice). If such an instance is available, a replacement instance will be launched and bootstrapped in exactly the same manner as your original instance.

Test this out by terminating the Spot instance with the **Jenkins Master (Spot)** name tag and verifying that a replacement instance comes up to take its place.

1. Go to the **EC2** console and click on the **Instances** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances));
2. Search for the EC2 instance with the Name tag of **Jenkins Master (Spot)**, right-click on it and select the **Instance State** > **Terminate** option. At the confirmation pop-up, click on the **Yes, Terminate** option. Within moments of terminating this instance, your Spot Fleet registration should detect that the number of running instances is below the target that you’ve defined (that target being one instance) and therefore should launch a new, replacement spot instance. Refresh the list of EC2 instances every few seconds until you see the new instance be allocated (while you're waiting, it might also be interesting to see what's happening under the History tab of your Spot Fleet). Whilst your Jenkins service will be unavailable until this new spot instance launches and bootstraps, service should automatically be restored in a couple of minutes.

## TERMINATE THE ON-DEMAND INSTANCE THAT WAS INITIALLY USED FOR YOUR JENKINS SERVER
Once you've verified that your Spot Fleet is self-healing, you no longer have any need for the On-demand instance. To prevent it from incurring unnecessary cost, it can be terminated.

1. Remain at the EC2 Instances screen and search for the EC2 instance with the Name tag of **Jenkins Master (On-demand)**. Right-click on the one instance that should come up and select the **Instance State** > **Terminate** option. At the confirmation pop-up, click on the **Yes, Terminate** option.