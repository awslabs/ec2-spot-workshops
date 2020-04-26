#!/bin/bash 

echo "Hello World from EC2 Spot Team..."


#yum update -y
yum -y install jq amazon-efs-utils


#Global Settings
MY_NAME=""
SECONDARY_VOLUME_ID=""
SECONDARY_PRIVATE_IP=""


EFS_FS_ID=fs-2b2540aa
EFS_MOUNT_POINT=/jp
SPOT_IP_STATUS_FILE=spot_ip_status.txt
SPOT_VOLUME_STATUS_FILE=spot_volume_status.txt
SPOT_STATE_FILE=spot_state.txt
SPOT_INSTANCE_STATUS_FILE=spot_instance_status.txt


#EBS Settings

EBS_TYPE=gp2
EBS_SIZE=8
EBS_DEV=/dev/xvdb

#SECONDARY_PRIVATE_IP="172.31.81.24"
MAC=$(curl -s http://169.254.169.254/latest/meta-data/mac)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
AWS_AVAIALABILITY_ZONE=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.availabilityZone')
AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
INTERFACE_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/interface-id)

aws configure set default.region ${AWS_REGION}

#aws autoscaling create-launch-configuration --cli-input-json file://demo-launchconfig.json --user-data file://demo-userdata.txt

#aws autoscaling create-auto-scaling-group --auto-scaling-group-name demo-asg --cli-input-json file://demo-asgconfig.json

#aws ecs create-capacity-provider --cli-input-json file://demo-capacityprovider.json

#aws ecs create-cluster --cluster-name demo-news-blog-scale --capacity-providers demo-capacityprovider --default-capacity-provider-strategy capacityProvider=demo-capacityprovider,weight=1

#aws ecs describe-clusters --clusters demo-news-blog-scale --include ATTACHMENTS

#aws ecs register-task-definition --cli-input-json file://demo-sleep-taskdef.json

aws ecs run-task --cluster demo-news-blog-scale --count 5 --task-definition demo-sleep-taskdef:1

