+++
title = "Setup AWS CLI and other tools"
weight = 50
+++

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