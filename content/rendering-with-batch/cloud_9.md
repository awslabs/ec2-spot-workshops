---
title: "Set up Cloud9 environment"
date: 2021-07-07T08:51:33Z
weight: 30
---

You will create all the AWS resources running commands in AWS Cloud9, which is a cloud-based integrated development environment (IDE) that comes prepackaged with essential tools for popular programming languages, including JavaScript, Python, PHP, and more.

To run the environment, we will launch a new EC2 instance that Cloud9 will access via SSH. By default, said instance has attached an EBS volume of size 10GB that will run short when we build the Docker image, so we need to resize it.

To do accomplish all this, you are going to download and run a Python script. Execute the following lines of code:

```bash
wget "https://raw.githubusercontent.com/bperezme/ec2-spot-workshops/blender_rendering_using_batch/content/rendering-with-batch/cloud9_setup.py"
python3 cloud9_setup.py -n "RenderingWithBatch" -t "t2.micro" -s 40
echo "Navigate to this URL to access your development environment: https://console.aws.amazon.com/cloud9/ide/${C9_ENV_ID}"
```

Access your development environment by copy-pasting the URL that was output to the console. Exit CloudShell and execute this code block in Cloud9 to define your region and install one command line tool:

```bash
export AWS_DEFAULT_REGION="us-east-1"
sudo yum -y install jq
```

You are now ready to start creating the Docker image. As of this point you will work in **Cloud9**.
