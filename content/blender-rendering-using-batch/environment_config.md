---
title: "Preparing the environment"
date: 2021-07-07T08:51:33Z
weight: 60
---

We need to store some data in environment variables that we will reference later and replace some of the entries in the commands with their values.

## Gathering subnet information

{{% notice info %}}
Note: During this workshop, we will use your account's default VPC to create the instances. If your account does not have a default VPC you can create or nominate one following [this link](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html#create-default-vpc)
{{% /notice %}}

Run the following commands to retrieve your default VPC and then its subnets.
    To learn more about these APIs, see [describe-vpcs CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html) and [describe-subnets CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html).

```bash
export VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true | jq -r '.Vpcs[0].VpcId')
export SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="${VPC_ID}")
export SUBNET_1=$((echo $SUBNETS) | jq -r '.Subnets[0].SubnetId')
export SUBNET_2=$((echo $SUBNETS) | jq -r '.Subnets[1].SubnetId')
export SUBNET_3=$((echo $SUBNETS) | jq -r '.Subnets[2].SubnetId')
```

## Gathering the default security group ID

To retrieve the identifier of the default security group you can perform the following call. To learn more about this API, see [describe-security-groups CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html).

```bash
export SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values="default" | jq -r '.SecurityGroups[0].GroupId')
```

You have gathered all the data you need to start working with Batch. Next, you will create a Launch Template that will be used when launching EC2 instances.
