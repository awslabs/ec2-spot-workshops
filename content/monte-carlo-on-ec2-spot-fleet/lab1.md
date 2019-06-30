+++
title = "Set up the Environment"
weight = 10
+++

![Architecture](/images/monte-carlo-on-ec2-spot-fleet/lab1_arch.png) 

#### Create an SSH Key   

First, you'll need to select a [region](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). For this lab, you will need to choose either the Oregon or Ohio Region.

<details>
<summary><strong>SSH Key Pair Instructions (expand for details)</strong></summary><p>

At the top right hand corner of the AWS Console, you'll see a **Support** dropdown. To the left of that is the region selection dropdown.

2. Then you'll need to create an SSH key pair which will be used to login to the instances once provisioned.  Go to the EC2 Dashboard and click on **Key Pairs** in the left menu under Network & Security.  Click **Create Key Pair**, provide a name (can be anything, make it something memorable) when prompted, and click **Create**.  Once created, the private key in the form of .pem file will be automatically downloaded.  

3. If you're using linux or mac, change the permissions of the .pem file to be less open.  

```
$ chmod 400 PRIVATE_KEY.PEM
```

{{% notice tip %}}
If you're on windows you'll need to convert the .pem file to .ppk to work with putty.  Here is a link to instructions for the file conversion - [Connecting to Your Linux Instance from Windows Using PuTTY](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html)
{{% /notice %}}

</details>

#### Launch the Workshop template
For your convenience, we provide a CloudFormation template to stand up the core infrastructure.  

The template sets up a VPC, IAM roles, S3 bucket, and an EC2 Instance. The EC2 instance will run a Jupyter Notebook which we will leverage in Lab 2 and a small website that we will use in Lab 3. The idea is to provide a contained environment, so as not to interfere with any other provisioned resources in your account.  In order to demonstrate cost optimization strategies, the EC2 Instance is an [EC2 Spot Instance](https://aws.amazon.com/ec2/spot/) deployed by [Spot Fleet](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet.html).  If you are new to [CloudFormation](https://aws.amazon.com/cloudformation/), take the opportunity to review the [template](./templates/monte-carlo-workshop.yaml) during stack creation.

{{% notice warning %}}
Prior to launching a stack, be aware that a few of the resources launched need to be manually deleted when the workshop is over. When finished working, please review the "Workshop Cleanup" section to learn what manual teardown is required by you.
{{% /notice %}}

1. Click on one of these CloudFormation templates that matches the region you created your keypair in to launch your stack:  

<style>.my-table table { left: 10%; width: 80%; text-align: center !important; justify-content: center; }</style>

<div class="ox-hugo-table my-table">
<div></div>

| Region | Launch Template|
|------------ |:-------------:|
| **N. Virginia** (us-east-1) | [![Launch Monte Carlo Workshop into Ohio with CloudFormation](/images/monte-carlo-on-ec2-spot-fleet/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=spot-montecarlo-stack&templateURL=https://s3-us-west-2.amazonaws.com/reinvent2017-cmp316/monte-carlo-workshop.yaml) |
| **Ohio** (us-east-2) | [![Launch Monte Carlo Workshop into Ohio with CloudFormation](/images/monte-carlo-on-ec2-spot-fleet/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=spot-montecarlo-stack&templateURL=https://s3-us-west-2.amazonaws.com/reinvent2017-cmp316/monte-carlo-workshop.yaml) |
| **Oregon** (us-west-2) | [![Launch Monte Carlo Workshop into Oregon with CloudFormation](/images/monte-carlo-on-ec2-spot-fleet/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=spot-montecarlo-stack&templateURL=https://s3-us-west-2.amazonaws.com/reinvent2017-cmp316/monte-carlo-workshop.yaml) |
| **Dublin** (eu-west-1) | [![Launch Monte Carlo Workshop into Ireland with CloudFormation](/images/monte-carlo-on-ec2-spot-fleet/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/new?stackName=spot-montecarlo-stack&templateURL=https://s3-us-west-2.amazonaws.com/reinvent2017-cmp316/monte-carlo-workshop.yaml) |
| **Tokyo** (ap-northeast-1) | [![Launch Monte Carlo Workshop into Tokyo with CloudFormation](/images/monte-carlo-on-ec2-spot-fleet/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-1#/stacks/new?stackName=spot-montecarlo-stack&templateURL=https://s3-us-west-2.amazonaws.com/reinvent2017-cmp316/monte-carlo-workshop.yaml) |
| **Seoul** (ap-northeast-2) | [![Launch Monte Carlo Workshop into Seoul with CloudFormation](/images/monte-carlo-on-ec2-spot-fleet/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-2#/stacks/new?stackName=spot-montecarlo-stack&templateURL=https://s3-us-west-2.amazonaws.com/reinvent2017-cmp316/monte-carlo-workshop.yaml) |
| **Sydney** (ap-southeast-2) | [![Launch Monte Carlo Workshop into Sydney with CloudFormation](/images/monte-carlo-on-ec2-spot-fleet/deploy-to-aws.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/new?stackName=spot-montecarlo-stack&templateURL=https://s3-us-west-2.amazonaws.com/reinvent2017-cmp316/monte-carlo-workshop.yaml) |

</div>

2. The template will automatically bring you to the CloudFormation Dashboard and start the stack creation process in the specified region. Click **Next** on the page it brings you to. Do not change anything on the first screen.

	First Screen
	![CloudFormation PARAMETERS](/images/monte-carlo-on-ec2-spot-fleet/cf-initial.png)
	
	Parameters Screen
	![CloudFormation PARAMETERS](/images/monte-carlo-on-ec2-spot-fleet/cf-params.png)
  
3. Select a password to use for the Jupyter Notebook. You will use this password in Lab 2. 
4. The default port for the Jupyter Notebook is 8888. Some corporate firewalls and VPNs will block this port. You can change the **JupyterPort** to 443 to get around this. 
5. Select your ssh key. 
>**Important:** On the parameter selection page of launching your CloudFormation stack, make sure to choose the key pair that you created in step 1. If you don't see a key pair to select, check your region and try again.
6. After you've selected your ssh key pair, click **Next**.
7. On the **Options** page, accept all defaults - you don't need to make any changes. Click **Next**. 
8. On the **Review** page, under **Capabilities** check the box next to **"I acknowledge that AWS CloudFormation might create IAM resources."** and click **Create**. Your CloudFormation stack is now being created.
9. Periodically check on the stack creation process in the CloudFormation Dashboard.  Your stack should show status **CREATE\_COMPLETE** in roughly 10-15 minutes. In the Outputs tab, take note of the **Jupyter** and **Web Server** values; you will need these in the next two labs. 
	
	![CloudFormation Complete](/images/monte-carlo-on-ec2-spot-fleet/cf-complete.png)

10. Under the CloudFormation Outputs, click on the URLs for **Jupyter** and **Web Server**. Each should load a web page confirming that the environment has been deployed correctly. We have created a self-signed certificate for the Jupyter Notebook. You will see messages about an unsafe connection. It is safe to ignore these warnings and continue. The steps will differ depending on your browser.


	Certificate Warning
	
	![Certificate Warning](/images/monte-carlo-on-ec2-spot-fleet/cert_warning.png)
	
	Jupyter
	
	![CloudFormation Jupyter Complete](/images/monte-carlo-on-ec2-spot-fleet/jupyter.png)
	
	Web
	
	![CloudFormation Web Client Complete](/images/monte-carlo-on-ec2-spot-fleet/web.png)

If there was an error during the stack creation process, CloudFormation will rollback and terminate.  You can investigate and troubleshoot by looking in the Events tab.  Any errors encountered during stack creation will appear in the event log. 

**You've completed Lab 1, Congrats!**    


