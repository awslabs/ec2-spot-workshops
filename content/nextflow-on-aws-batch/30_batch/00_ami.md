---
title: "Create AMI"
chapter: false
weight: 01
---

AWS Batch uses ECS as an execution host and as such uses the official ECS-optimized image as a default.
As the nextflow container needs to run the AWS-Cli we need to update the AMI so that we have everything we need.

<!--
## Paste Credentials

In order to use packer, we need to paste the CLI credentials from the Event Engine Dashboard.
Click [1] to copy the credentials in your clipboard and paste them into your Cloud9 terminal.

![](/images/nextflow-on-aws-batch/batch/0_ee_dash.png)
-->

## Install Packer

To update the image we use Hashicorps [packer]().

```
sudo yum install -y bsdtar jq
curl -sLo - \
      https://releases.hashicorp.com/packer/1.5.4/packer_1.5.4_linux_amd64.zip \
      | sudo bsdtar xfz - -C /usr/bin/
sudo chmod +x /usr/bin/packer
```

### Build image

First we need to fetch the source AMI-ID.

```
export SOURCE_AMI=$(aws ec2 --region=us-east-1 describe-images --owners amazon \
        --filters 'Name=name,Values=amzn-ami-????.??.???????-amazon-ecs-optimized ' 'Name=state,Values=available' \
        --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' --output text)
echo $SOURCE_AMI
```


```
mkdir packer
cd packer
cat << \EOF > install-tools.sh
#!/bin/bash
set -x
yum install -y wget
wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh -b -f -p /home/ec2-user/miniconda
/home/ec2-user/miniconda/bin/conda install -c conda-forge awscli
/home/ec2-user/miniconda/bin/aws --version
EOF
```

```
cat << \EOF > packer.json
{
  "variables": {
        "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
        "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
        "aws_session_token": "{{env `AWS_SESSION_TOKEN`}}",
        "region":         "{{env `AWS_REGION`}}",
        "ami_name":       "ecs-batch-ami",
        "source_ami":     "ami-09dbd3d47a721cd07"
  },
  "provisioners": [
    {
      "type": "shell",
      "execute_command": "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'",
      "script": "install-tools.sh"
    }
  ],
  "builders": [{
    "type": "amazon-ebs",
    "access_key": "{{user `aws_access_key`}}",
    "secret_key": "{{user `aws_secret_key`}}",
    "token": "{{user `aws_session_token`}}",
    "region": "{{user `region`}}",
    "source_ami": "{{user `source_ami`}}",
    "instance_type": "m5.xlarge",
    "ssh_username": "ec2-user",
    "ami_name": "{{user `ami_name`}}-{{timestamp}}"
  }]
}
EOF
```

```
packer build -var "source_ami=${SOURCE_AMI}" packer.json
```

Fetch the AMI-ID.

```
aws ec2 --region=us-east-1 describe-images --owners $(aws sts get-caller-identity |jq -r '.Account') \
        --filters 'Name=name,Values=ecs-batch-ami*' \
        --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' --output text
```