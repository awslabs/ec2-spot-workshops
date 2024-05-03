+++
title = "Setup AWS CLI and other tools"
weight = 50
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Amazon EC2 Auto Scaling Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/0a0fe16c-8693-4d23-8679-4f1701dbd2b0/en-US)**.

{{% /notice %}}


1. Uninstall the AWS CLI 1.x by running:
	```bash
	sudo pip uninstall -y awscli
	```   

1. Install the AWS CLI 2.0 by running:

	```bash
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install
	```   
1. Confirm the CLI version with the following command:
	```bash
	aws --version
	```   

1. Install dependencies for use in the workshop by running:

	```bash
	sudo yum -y install jq
	```   