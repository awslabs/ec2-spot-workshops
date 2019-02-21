+++
title = "Lab 1: Reduce the cost of builds using Amazon EC2 Spot Fleet"
weight = 20
+++
The Jenkins server that was launched by the CloudFormation template has a number of build projects preconfigured. However by default, all builds will be executed on the same instance that Jenkins is running on. This results in a couple of less-than-desirable behaviours:
* When CPU-intensive builds are being executed, there may not be sufficient system resources to display the Jenkins server interface; and
* The Jenkins server is often provisioned with more resources than the server interface requires in order to allow builds to execute. When builds are not being executed, these server resources are essentially going to waste.

To address these behaviours, Jenkins provides the capability to execute builds on external hosts (called build agents). Further, AWS provides a Jenkins plugin to allow Jenkins to scale out a fleet of EC2 instances in order to execute build jobs on. This lab will focus on implementing EC2 Spot build agents, showcasing what a batch processing workload typically looks like when using Amazon EC2 Spot instances.

## PROVISION A SPOT FLEET FOR YOUR BUILD AGENTS
Before configuring the EC2 Fleet Jenkins Plugin, create a Spot Fleet that will be used by the plugin to perform your application builds. As this is a batch processing use case, remember the best practices for this type of workload - leverage per-second billing (catered for through the use of an Amazon Linux AMI defined in the Launch Template); optimize for lowest cost; determine job completion and retry failed jobs (the former is handled by the Jenkins EC2 Fleet plugin); and be instance flexible.

1. Go to the **EC2** console and click on the **Spot Requests** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2sp/v1/spot/home?region=eu-west-1#));
2. Click on the **Request Spot Instances** button;
3. At the first screen of the Spot instance launch wizard:
    1. Under the Tell us your application or task need heading, ensure that the **Load balancing workloads** option selected (Note: do NOT select the Flexible workloads option as this will deploy a Spot Fleet with weightings applied to some of the EC2 instance types which will adversely impact how the plugin scales out);
    2. In the Configure your instances section, select the **JenkinsBuildAgentLaunchTemplate** template from the Launch template dropdown (if this option is not present in the dropdown, please verify that the CloudFormation template that you launched during the Workshop Preparation has deployed successfully). Change the Network to be the **Spot CICD Workshop VPC**. After making this selection, enable the check boxes for all three Availability Zones and then select the **Amazon EC2 Spot CICD Workshop Public Subnet** associated with each availability zone as the subnet to launch instances in;
    3. At the Tell us how much capacity you need section, keep the Total target capacity at **1** instance and the Optional On-Demand portion set to **0**, and then tick the **Maintain target capacity** checkbox. Once selected, leave the Interruption behavior set to **Terminate**;
    4. While the new Spot Instances wizard makes some good recommendations to you on how best to add diversity to the fleet that you're creating, the recommended instance types provide more resources than we strictly need in this workshop - so to the right of the Fleet request settings heading, clear the tick from **Apply recommendations** checkbox. Click on each of the **Remove** links associated with the all of the instance types initially defined to remove them from the fleet configuration. Then click on the **Select instance types** button and add the **t2.medium**, **t2.large**, **t3.medium** and **t3.large** instance types to the fleet definition (Hint: you may need to adjust the **vCPUs** and **Memory (GiB)** filters to reveal all of these instance types). Once the checkboxes for the required instance types have been ticked, click on the **Select** button. Once you have the four desired instance types listed in the fleet request, select the **Lowest Price** Fleet allocation strategy (since we’re interested in keeping cost to an absolute minimum for this use case);
    5. Review the Your fleet request as a glance section - it should indicate that your Fleet strength is Strong as a result of being able to draw instances from 12 instance pools, and your Estimated price should indicate that you're expecting to make a 70% saving compared to the cost of equivalent on-demand resources;
    6. Lastly, click on the **Launch** button.
4. Make a note of the Request ID of the Spot Fleet that you’ve just created.

## CREATE A SECRET KEY AND ACCESS KEY FOR THE PLUGIN
The CloudFormation template that you deployed in Lab 1 created an IAM User called **SpotCICDWorkshopJenkins**. Jenkins will use this IAM User to control the spot fleet used for your build slaves. Generate a secret key and access key for this user.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **IAM** console and click on the **Users** option from the left frame (or [click here](https://console.aws.amazon.com/iam/home?region=eu-west-1#/users));
2. Click on the **SpotCICDWorkshopJenkins** user;
3. Click on the **Security credentials** tab, then click on the **Create access key** button – Make a note of the Access key ID and Secret access key, then click the **Close** button.
{{% /expand%}}

## SIGN IN TO YOUR JENKINS SERVER
The CloudFormation template deployed during the Workshop Preparation stage deployed a Jenkins server on to an on-demand instance within your VPC and configured an Application Load Balancer (ALB) to proxy requests from the public Internet to the server. You can obtain the DNS name for the ALB from the Output tab of your CloudFormation template. Point your web browser to this DNS name and sign in using **spotcicdworkshop** as the Username and the password that you supplied to the CloudFormation template as the password.
{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1));
2. Click on the checkbox associated with the **SpotCICDWorkshop** stack, then click on the **Outputs** tab toward the bottom of the screen;
3. Make a note of the DNS name for the Application Load Balancer, which is associated with the **JenkinsDNSName** key;
4. Open up a new tab in your browser and enter the DNS name in the address bar. You should be greeted with a Jenkins Sign In screen:
    1. Enter in **spotcicdworkshop** as the Username;
    2. Enter in the password that you supplied to the CloudFormation template as the Password.
{{% /expand%}}

## CONFIGURE THE EC2 FLEET JENKINS PLUGIN
The EC2 Fleet Jenkins Plugin was installed on the Jenkins server during the CloudFormation deployment - but now the plugin needs to be configured. You'll first need to supply the IAM Access Key ID and Secret Key that you created so that the plugin can find your Spot Fleet request. You'll then need to get the plugin to **Launch slave agents via SSH** and provide valid SSH credentials (don't forget to consider how Host Key Verification should be set when using Spot instances).

When configuring the plugin, think about how you could force build processes to run on the spot instances (use the **spot-agents** label), and consider how you can verify that the fleet scales out when there is a backlog of build jobs waiting to be processed.

{{%expand "Click to reveal detailed instructions" %}}
1. From the Jenkins home screen, click on the **Manage Jenkins** link on the left side menu, and then the **Configure System** link;
2. Scroll all the way down to the bottom of the page and under the **Cloud** section, click on the **Add a new cloud button**, followed by the **Amazon SpotFleet** option;
3. Under the Spot Fleet Configuration section, click on the **Add** button next to the AWS Crendentials [sic] dropdown, then click on the **Jenkins** option. This will pop up a new **Jenkins Credentials Provider: Jenkins** sub-form. Fill out the form as follows:
    1. Change the Kind to **AWS Credentials**;
    2. Change the Scope to **System (Jenkins and nodes only)** – you don’t want your builds to have access to these credentials!
    3. At the ID field, enter **SpotCICDWorkshopJenkins**;
    4. At the Access Key ID and Secret Access Key fields, enter in the information that you gathered earlier;
    5. Click on the **Add** button;
4. Once the sub-form disappears, select your Access Key ID from the AWS Credentials dropdown - the plugin will then issue a request to the AWS APIs and populate the list of regions;
5. Select **eu-west-1** from the Region dropdown - the plugin will now attempt to obtain a list of Spot Fleet requests made in the selected region;
6. Select the Request Id of the Spot Fleet that you created earlier from the Spot Fleet dropdown (though it might already be selected) and then select the **Launch slave agents via SSH** option from the Launcher dropdown - this should reveal additional SSH authentication settings;
7. Click the **Add** button next to the Credentials dropdown and select the **Jenkins** option. This will pop up another **Jenkins Credentials Provider: Jenkins** sub-form. Fill out the form as follows:
    1. Change the Kind to **SSH Username with private key**;
    2. Change the Scope to **System (Jenkins and nodes only)** – you also don’t want your builds to have access to these credentials;
    3. At the Username field, enter **ec2-user**;
    4. For the Private Key, select the **Enter directly** radio button. Open the .pem file that you downloaded during the workshop setup in a text editor and copy the contents of the file to the Key field including the BEGIN RSA PRIVATE KEY and END RSA PRIVATE KEY fields;
    5. Click on the **Add** button.
8. Select the ec2-user option from the Credentials dropdown;
9. Given that Spot instances will have a random SSH host fingerpint, select the **Non verifying Verification Strategy** option from the Host Key Verification Strategy dropdown;
10. Mark the **Connect Private** checkbox to ensure that your Jenkins Master will always communicate with the Agents via their internal VPC IP addresses (in real-world scenarios, your build agents would likely not be publicly addressable);
11. Change the Label field to be **spot-agents** - you'll shortly reconfigure your build job to run on slave instances featuring this label;
12. Set the Max Idle Minutes Before Scaledown to **5**. As AWS launched per-second billing in 2017, there's no need to keep a build agent running for too much longer than it's required;
13. Change the Maximum Cluster Size from **1** to **2** (so that you can test fleet scale-out);
14. Finally, click on the **Save** button.

Within sixty-seconds, the Jenkins Slave Agent should have been installed on to the Spot instance that was launched by your Spot fleet; you should see an EC2 instance ID appear underneath the Build Executor Status section on the left side of the Jenkins user interface. Underneath that, you should see that there is a single Build Executor on this host, which is in an idle state.
{{% /expand%}}

## RECONFIGURE YOUR BUILD JOBS TO USE THE NEW SPOT INSTANCE(S)
As alluded to in the previous section, you'll need to reconfigure your build jobs so that they are executed on the build agents running in your Spot fleet (again, use the **spot-agents** label). In addition, configure each job to execute concurrent builds if necessary - this will help you in testing the scale-out of your fleet.

{{%expand "Click to reveal detailed instructions" %}}
1. Go back to the Jenkins home screen and **repeat the following for each of the five Apache build projects** that are configured in your Jenkins deployment:
    1. Click on the title of the build job and then click on the **Configure** link toward the left side of the screen;
    2. In the General section, click on the **Execute concurrent builds if necessary** checkbox and the **Restrict where this project can be run** checkbox. Next, enter **spot-agents** as the Label Expression (Note: if you select the auto-complete option instead of typing out the full label, Jenkins will add a space to the end of the label - be sure to remove any trailling spaces from the label before proceeding);
    3. Click on the **Save** button towards the bottom of the screen.
{{% /expand%}}

## TEST SPOT BUILDS AND SCALE-OUT
Now it’s time to test out how Jenkins handles pushing builds to spot instances running build agents at scale. There are two things that you'll want to verify here; that your builds run successfully on the Spot instances, and that your Spot Fleet scales out when there are build jobs queued for more than a few minutes.

1. Back at the Jenkins home page, first click on the **ENABLE AUTO REFRESH** link that's located towards to top-right corner of the screen - this will enable a full refresh of the Jenkins user interface every 10 seconds allowing you to see regular updates to the status of each build. Next, click on the **Schedule a Build** icon (which looks like a play symbol superimposed over a clock) for each of the five Apache projects, starting from the **Apache PDFBox** project and working upward. This will queue up five build jobs, the first of which will be immediately assigned to the Spot instance to be worked on;
2. When any of the build jobs have been completed, click on the **Schedule a Build** icon corresponding to that job to re-add it back to the build queue - the intent here is to keep the build queue populated with a backlog of build jobs until your Spot Fleet has scaled out and build jobs are executing on both Spot instances;
3. After a couple of minutes (typically during the first **Apache Helix** build - around four minutes after you initiate the first build), the EC2 Fleet Status reported to the left of the screen will increment the **target** count to 2, indicating that the plugin has requested a scale-out action from the plugin. After a few moments, a second build instance will appear in the **Build Executor Status**, though this build agent will initially appear to be offline. Once the instance has had the chance to complete the launch and bootstrapping processes (which takes around two minutes), your Jenkins Master will deploy the build agent to it via SSH, and it will come online and process the next build job in the queue. Once you have concurrent builds being executed on two Spot instances, you can stop adding build jobs to the build queue;
4. After a period of around a five minutes after your builds have completed, one of the Spot instances should be terminated by the plugin - there's no need to wait for this to happen (take our word for it, but you can verify this later).

## PROCEED TO LAB 2
Once you've verified that builds are succeeding and that your Spot Fleet is capable of scaling out to handle queued build jobs, you may proceed with [Lab 2](/amazon-ec2-spot-cicd-workshop/lab2.html).
