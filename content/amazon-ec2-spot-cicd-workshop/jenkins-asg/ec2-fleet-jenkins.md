+++
title = "Configure EC2 Fleet plugin"
weight = 115
+++
The [EC2 Fleet Plugin](https://plugins.jenkins.io/ec2-fleet/) launches EC2 Spot or On Demand instances as worker nodes for Jenkins CI server, automatically scaling the capacity with the load. The EC2 FLeet plugin will request EC2 instances when excess jobs are detected. You can configure the plugin to use an Auto Scaling Group to launch instances instead of directly launching them by itself. This gives theh plugin all the benefits from Auto Scaling groups like allocation strategies, configure multiple instance types and availability zones, etc. Moreover, the EC2 Fleet plugin can automatically resubmit failed jobs caused by a Spot interruption. 

To start using this plugin, you need to configure it in Jenkins, so let's do it.

## Sign-in to Jenkins
The CloudFormation template deployed during the Workshop Preparation stage deployed a Jenkins server on to an on-demand instance within your VPC and configured an Application Load Balancer (ALB) to proxy requests from the public Internet to the server. You can obtain the DNS name for the ALB from the Output tab of your CloudFormation template. Point your web browser to this DNS name and sign in using **admin** as the Username and the password that you supplied to the CloudFormation template as the password.

1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1));
2. Click on the checkbox associated with the **SpotCICDWorkshop** stack, then click on the **Outputs** tab toward the bottom of the screen;
3. Make a note of the DNS name for the Application Load Balancer, which is associated with the **JenkinsDNSName** key;
4. Open up a new tab in your browser and enter the DNS name in the address bar. You should be greeted with a Jenkins Sign In screen:
    1. Enter in **admin** as the Username;
    2. Enter in the password that you supplied to the CloudFormation template as the Password.

## Configure the EC2 Fleet Jenkins plugin
The EC2 Fleet Jenkins Plugin was installed on the Jenkins server during the CloudFormation deployment - but now the plugin needs to be configured. You'll need to get the plugin to **Launch slave agents via SSH** and provide valid SSH credentials (don't forget to consider how Host Key Verification should be set when using Spot instances).

When configuring the plugin, think about how you could force build processes to run on the spot instances (use the **spot-agents** label), and consider how you can verify that the fleet scales out when there is a backlog of build jobs waiting to be processed.

1. From the Jenkins home screen, click on the **Manage Jenkins** link on the left side menu, and then the **Manage Nodes and Clouds** link;
2. Click on the **Configure Clouds** link on the left side menu, then click on the **Add a new cloud** dropdown, followed by the **Amazon EC2 Fleet** option;
3. **You don't need to configure any AWS Credentials** as the plugin will use the IAM Role attached to the instance;
4. Select **eu-west-1 EU (Ireland)** from the Region dropdown - the plugin will now attempt to obtain a list of Auto Scaling groups in the selected region;
6. Select the Auto Scaling group that you created earlier (`Auto Scaling Group - EC2SpotJenkinsASG`) from the **EC2 Fleet** dropdown (though it might already be selected) and then select the **Launch slave agents via SSH** option from the Launcher dropdown - this should reveal additional SSH authentication settings;
7. Click the **Add** button next to the Credentials dropdown and select the **Jenkins** option. This will pop up another **Jenkins Credentials Provider: Jenkins** sub-form. Fill out the form as follows:
    1. Change the Kind to **SSH Username with private key**;
    2. Change the Scope to **System (Jenkins and nodes only)** – you also don’t want your builds to have access to these credentials;
    3. At the Username field, enter **ec2-user**;
    4. For the Private Key, select the **Enter directly** radio button. Open the .pem file that you downloaded during the workshop setup in a text editor and copy the contents of the file to the Key field including the *BEGIN RSA PRIVATE KEY* and *END RSA PRIVATE KEY* fields;
    5. Click on the **Add** button.
8. Select the **ec2-user** option from the Credentials dropdown;
9. Given that Spot instances will have a random SSH host fingerprint, select the **Non verifying Verification Strategy** option from the Host Key Verification Strategy dropdown;
10. Mark the **Private IP** checkbox to ensure that your Jenkins Master will always communicate with the Agents via their internal VPC IP addresses (in real-world scenarios, your build agents would likely not be publicly addressable);
11. Change the Label field to be **spot-agents** - you'll shortly configure a build job to run on slave instances featuring this label;
12. Set the **Max Idle Minutes Before Scaledown** to **5**. There's no need to keep a build agent running for too much longer than it's required;
13. Change the Minimum Cluster Size from **1** to **0** (so that it can scale-in to zero instances);
14. Change the Maximum Cluster Size from **1** to **5** (so that you can test fleet scale-out);
15. Finally, click on the **Save** button.

For now, no instances are going to be launched as there are no pending jobs to run. So, let's configure an existing Jenkins job to use Spot instances.