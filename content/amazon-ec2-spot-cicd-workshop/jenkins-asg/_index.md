+++
title = "Jenkins with Amazon EC2 Auto Scaling Groups"
weight = 100
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