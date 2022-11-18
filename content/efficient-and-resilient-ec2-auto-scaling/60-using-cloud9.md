+++
title = "Cloud9 Environment Setup"
weight = 60
+++

Now we have access to a **Cloud9** environment, let's start configuring it to use it for running this workshop steps.

**AWS Cloud9** comes with a terminal that includes sudo privileges to the managed Amazon EC2 instance that is hosting your development environment and a preauthenticated AWS Command Line Interface. This makes it easy for you to quickly run commands and directly access AWS services.


#### Configure Cloud9 environment:

1. From the last step, you should have a browser window open with the **Cloud9 IDE**, you can browse the directory structure in the **Environment** tab on the left, and even edit files directly there by double clicking on them.
2. Check the folders in left navigation, look for folder named **ec2-spot-workshops**.
{{% notice info %}}
You should expect the folder **ec2-spot-workshops** to be visible within **5 minutes** as the bootstrap script finishes the environment setup.
{{% /notice %}}
1. **Don't** proceed with next steps till folder **ec2-spot-workshops** shows in left navigation.
2. In the **Cloud9 IDE** terminal, change into the workshop directory

	```bash
	cd ec2-spot-workshops/workshops/efficient-and-resilient-ec2-auto-scaling
	```
