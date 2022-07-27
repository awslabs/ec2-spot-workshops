+++
title = "Lab 1: Reduce the cost of builds using Amazon EC2 Spot Fleet"
weight = 20
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
aws autoscaling create-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsASG --min-size 0 --max-size 2 --desired-capacity 0 --vpc-zone-identifier "${SUBNET_1},${SUBNET_2},${SUBNET_3}" --mixed-instances-policy file://asg-policy.json
```

## Sign-in to Jenkins
The CloudFormation template deployed during the Workshop Preparation stage deployed a Jenkins server on to an on-demand instance within your VPC and configured an Application Load Balancer (ALB) to proxy requests from the public Internet to the server. You can obtain the DNS name for the ALB from the Output tab of your CloudFormation template. Point your web browser to this DNS name and sign in using **spotcicdworkshop** as the Username and the password that you supplied to the CloudFormation template as the password.
{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1));
2. Click on the checkbox associated with the **SpotCICDWorkshop** stack, then click on the **Outputs** tab toward the bottom of the screen;
3. Make a note of the DNS name for the Application Load Balancer, which is associated with the **JenkinsDNSName** key;
4. Open up a new tab in your browser and enter the DNS name in the address bar. You should be greeted with a Jenkins Sign In screen:
    1. Enter in **spotcicdworkshop** as the Username;
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
13. Change the Maximum Cluster Size from **1** to **2** (so that you can test fleet scale-out);
14. Finally, click on the **Save** button.

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

## Proceed to lab 2
Once you've verified that builds are succeeding and that your ASG is capable of scaling out to handle queued build jobs, you may proceed with [Lab 2](/amazon-ec2-spot-cicd-workshop/lab2.html).
