eneccccbvglbjgetccgguuntcdtivunekhnnivjjvuvn
#!/bin/bash

echo "Creating the Infrastructure for ECS_Cluster_Auto_Scaling workshop ..."


yum update -y
yum -y install jq


#Global Defaults
export WORKSHOP_NAME=ecs-spot-workshop
export LAUNCH_TEMPLATE_NAME=ecs-spot-workshop-lt
export ASG_NAME_OD=ecs-spot-workshop-asg-od
export ASG_NAME_SPOT=ecs-spot-workshop-asg-spot
export OD_CAPACITY_PROVIDER_NAME=od-capacity_provider
export SPOT_CAPACITY_PROVIDER_NAME=ec2spot-capacity_provider
export ECS_FARGATE_CLUSTER_NAME=EcsFargateClusterTest1
export LAUNCH_TEMPLATE_VERSION=1

#IAM_INSTANT_PROFILE_ARN=arn:aws:iam::000474600478:instance-profile/ecsInstanceRole
export IAM_INSTANT_PROFILE_ARN=arn:aws:iam::000474600478:instance-profile/ecslabinstanceprofile
export SECURITY_GROUP=sg-4f3f0d1e



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

cp -Rfp templates/*.json .
cp -Rfp templates/*.txt .

aws ecs create-cluster \
--cluster-name $ECS_FARGATE_CLUSTER_NAME \
--capacity-providers FARGATE FARGATE_SPOT \
--region $AWS_REGION \
--default-capacity-provider-strategy capacityProvider=FARGATE,base=1,weight=1 \
                                     capacityProvider=FARGATE_SPOT,weight=0


exit 0



#export AMI_ID=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-ecs-hvm-2.0.????????-x86_64-ebs' 'Name=state,Values=available' --output json | jq -r '.Images |   sort_by(.CreationDate) | last(.[]).ImageId')
export AMI_ID=$(aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended | jq -r 'last(.Parameters[]).Value' | jq -r '.image_id')
echo "Latest ECS Optimized Amazon AMI_ID is $AMI_ID"



sed -i.bak -e "s#ECS_FARGATE_CLUSTER_NAME#$ECS_FARGATE_CLUSTER_NAME#g"  user-data.txt
sed -i.bak -e "s#%instanceProfile%#$IAM_INSTANT_PROFILE_ARN#g"  launch-template-data.json
sed -i.bak -e "s#%instanceSecurityGroup%#$SECURITY_GROUP#g"  launch-template-data.json
sed -i.bak -e "s#%workshopName%#$WORKSHOP_NAME#g"  launch-template-data.json
sed -i.bak  -e "s#%ami-id%#$AMI_ID#g" -e "s#%UserData%#$(cat user-data.txt | base64 --wrap=0)#g" launch-template-data.json

#LAUCH_TEMPLATE_ID=lt-07fdb20138ddf466c
LAUCH_TEMPLATE_ID=$(aws ec2 create-launch-template --launch-template-name $LAUNCH_TEMPLATE_NAME --version-description $LAUNCH_TEMPLATE_VERSION --launch-template-data file://launch-template-data.json | jq -r '.LaunchTemplate.LaunchTemplateId')
echo "Amazon LAUCH_TEMPLATE_ID is $LAUCH_TEMPLATE_ID"

export ASG_NAME=$ASG_NAME_OD
export OD_BASE=0
export OD_PERCENTAGE=100
export MIN_SIZE=0
export MAX_SIZE=10
export DESIREDS_SIZE=0
export PUBLIC_SUBNET_LIST="subnet-764d7d11,subnet-a2c2fd8c,subnet-cb26e686,subnet-7acbf626,subnet-93d490ad,subnet-313ad03f"
export INSTANCE_TYPE_1=c4.large
export INSTANCE_TYPE_2=c5.large
export INSTANCE_TYPE_3=m4.large
export INSTANCE_TYPE_4=m5.large
export INSTANCE_TYPE_5=r4.large
export INSTANCE_TYPE_6=r5.large
export SERVICE_ROLE_ARN="arn:aws:iam::000474600478:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

sed -i.bak -e "s#%ASG_NAME%#$ASG_NAME#g"  asg.json
sed -i.bak -e "s#%LAUNCH_TEMPLATE_NAME%#$LAUNCH_TEMPLATE_NAME#g"  asg.json
sed -i.bak -e "s#%LAUNCH_TEMPLATE_VERSION%#$LAUNCH_TEMPLATE_VERSION#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_1%#$INSTANCE_TYPE_1#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_2%#$INSTANCE_TYPE_2#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_3%#$INSTANCE_TYPE_3#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_4%#$INSTANCE_TYPE_4#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_5%#$INSTANCE_TYPE_5#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_6%#$INSTANCE_TYPE_6#g"  asg.json
sed -i.bak -e "s#%OD_BASE%#$OD_BASE#g"  asg.json
sed -i.bak -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g"  asg.json
sed -i.bak -e "s#%MIN_SIZE%#$MIN_SIZE#g"  asg.json
sed -i.bak -e "s#%MAX_SIZE%#$MAX_SIZE#g"  asg.json
sed -i.bak -e "s#%DESIREDS_SIZE%#$DESIREDS_SIZE#g"  asg.json
sed -i.bak -e "s#%OD_BASE%#$OD_BASE#g"  asg.json
sed -i.bak -e "s#%PUBLIC_SUBNET_LIST%#$PUBLIC_SUBNET_LIST#g"  asg.json
sed -i.bak -e "s#%SERVICE_ROLE_ARN%#$SERVICE_ROLE_ARN#g"  asg.json

aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
ASG_ARN=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME_OD | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME_OD ARN=$ASG_ARN"

export TARGET_CAPACITY=100
export CAPACITY_PROVIDER_NAME=$OD_CAPACITY_PROVIDER_NAME
sed -i.bak -e "s#%CAPACITY_PROVIDER_NAME%#$CAPACITY_PROVIDER_NAME#g"  ecs-capacityprovider.json
sed -i.bak -e "s#%ASG_ARN%#$ASG_ARN#g"  ecs-capacityprovider.json
sed -i.bak -e "s#%MAX_SIZE%#$MAX_SIZE#g"  ecs-capacityprovider.json
sed -i.bak -e "s#%TARGET_CAPACITY%#$TARGET_CAPACITY#g"  ecs-capacityprovider.json

CAPACITY_PROVIDER_ARN=$(aws ecs create-capacity-provider --cli-input-json file://ecs-capacityprovider.json | jq -r '.capacityProvider.capacityProviderArn')
echo "$OD_CAPACITY_PROVIDER_NAME ARN=$CAPACITY_PROVIDER_ARN"



cp -Rfp templates/asg.json .

export ASG_NAME=$ASG_NAME_SPOT
expport OD_PERCENTAGE=0

sed -i.bak -e "s#%ASG_NAME%#$ASG_NAME#g"  asg.json
sed -i.bak -e "s#%LAUNCH_TEMPLATE_NAME%#$LAUNCH_TEMPLATE_NAME#g"  asg.json
sed -i.bak -e "s#%LAUNCH_TEMPLATE_VERSION%#$LAUNCH_TEMPLATE_VERSION#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_1%#$INSTANCE_TYPE_1#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_2%#$INSTANCE_TYPE_2#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_3%#$INSTANCE_TYPE_3#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_4%#$INSTANCE_TYPE_4#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_5%#$INSTANCE_TYPE_5#g"  asg.json
sed -i.bak -e "s#%INSTANCE_TYPE_6%#$INSTANCE_TYPE_6#g"  asg.json
sed -i.bak -e "s#%OD_BASE%#$OD_BASE#g"  asg.json
sed -i.bak -e "s#%OD_PERCENTAGE%#$OD_PERCENTAGE#g"  asg.json
sed -i.bak -e "s#%MIN_SIZE%#$MIN_SIZE#g"  asg.json
sed -i.bak -e "s#%MAX_SIZE%#$MAX_SIZE#g"  asg.json
sed -i.bak -e "s#%DESIREDS_SIZE%#$DESIREDS_SIZE#g"  asg.json
sed -i.bak -e "s#%OD_BASE%#$OD_BASE#g"  asg.json
sed -i.bak -e "s#%PUBLIC_SUBNET_LIST%#$PUBLIC_SUBNET_LIST#g"  asg.json
sed -i.bak -e "s#%SERVICE_ROLE_ARN%#$SERVICE_ROLE_ARN#g"  asg.json

aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
ASG_ARN=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME_SPOT | jq -r '.AutoScalingGroups[0].AutoScalingGroupARN')
echo "$ASG_NAME_SPOT ARN=$ASG_ARN"

cp -Rfp templates/ecs-capacityprovider.json .

export TARGET_CAPACITY=100
export CAPACITY_PROVIDER_NAME=$SPOT_CAPACITY_PROVIDER_NAME
sed -i.bak -e "s#%CAPACITY_PROVIDER_NAME%#$CAPACITY_PROVIDER_NAME#g"  ecs-capacityprovider.json
sed -i.bak -e "s#%ASG_ARN%#$ASG_ARN#g"  ecs-capacityprovider.json
sed -i.bak -e "s#%MAX_SIZE%#$MAX_SIZE#g"  ecs-capacityprovider.json
sed -i.bak -e "s#%TARGET_CAPACITY%#$TARGET_CAPACITY#g"  ecs-capacityprovider.json

CAPACITY_PROVIDER_ARN=$(aws ecs create-capacity-provider --cli-input-json file://ecs-capacityprovider.json | jq -r '.capacityProvider.capacityProviderArn')
echo "$SPOT_CAPACITY_PROVIDER_NAME ARN=$CAPACITY_PROVIDER_ARN"


aws ecs create-cluster --cluster-name $ECS_FARGATE_CLUSTER_NAME \
       --capacity-providers $OD_CAPACITY_PROVIDER_NAME $SPOT_CAPACITY_PROVIDER_NAME \
       --default-capacity-provider-strategy capacityProvider=$OD_CAPACITY_PROVIDER_NAME,base=1,weight=1 \
         capacityProvider=$SPOT_CAPACITY_PROVIDER_NAME,weight=0

sleep 10

aws ecs put-cluster-capacity-providers   --cluster $ECS_FARGATE_CLUSTER_NAME \
     --capacity-providers FARGATE FARGATE_SPOT $OD_CAPACITY_PROVIDER_NAME $SPOT_CAPACITY_PROVIDER_NAME  \
     --default-capacity-provider-strategy capacityProvider=$OD_CAPACITY_PROVIDER_NAME,base=1,weight=1 \
         capacityProvider=$SPOT_CAPACITY_PROVIDER_NAME,weight=0  \
     --region $AWS_REGION
     
aws ecs register-task-definition --cli-input-json file://webapp-fargate-task.json
WEBAPP_FARGATE_TASK_DEF=$(cat webapp-fargate-task.json | jq -r '.family')
aws ecs register-task-definition --cli-input-json file://webapp-ec2-task.json
WEBAPP_EC2_TASK_DEF=$(cat webapp-ec2-task.json | jq -r '.family')

# Deploy ECS Service only on the OD instances using EC2 autoscaling Capacity provider dedicated for OD

export ECS_SERVICE_NAME=webapp-ec2-service-od
export TASK_COUNT=2

aws ecs create-service \
     --capacity-provider-strategy capacityProvider=$OD_CAPACITY_PROVIDER_NAME,weight=1 \
     --cluster $ECS_FARGATE_CLUSTER_NAME \
     --service-name $ECS_SERVICE_NAME \
     --task-definition $WEBAPP_EC2_TASK_DEF:4 \
     --desired-count $TASK_COUNT \
     --region $AWS_REGION 
     
    
# Deploy ECS Service only on the Spot instances using EC2 autoscaling Capacity provider dedicated for spot

export ECS_SERVICE_NAME=webapp-ec2-service-spot
export TASK_COUNT=2

aws ecs create-service \
     --capacity-provider-strategy capacityProvider=$SPOT_CAPACITY_PROVIDER_NAME,weight=1 \
     --cluster $ECS_FARGATE_CLUSTER_NAME \
     --service-name $ECS_SERVICE_NAME \
     --task-definition $WEBAPP_EC2_TASK_DEF:4 \
     --desired-count $TASK_COUNT \
     --region $AWS_REGION 

# Deploy ECS Service  on both OD and  Spot instances using EC2 autoscaling Capacity providers for OD and spot

export ECS_SERVICE_NAME=webapp-ec2-service-mix
export TASK_COUNT=6

aws ecs create-service \
     --capacity-provider-strategy capacityProvider=$OD_CAPACITY_PROVIDER_NAME,weight=1 \
                                  capacityProvider=$SPOT_CAPACITY_PROVIDER_NAME,weight=3 \
     --cluster $ECS_FARGATE_CLUSTER_NAME \
     --service-name $ECS_SERVICE_NAME \
     --task-definition $WEBAPP_EC2_TASK_DEF:4 \
     --desired-count $TASK_COUNT \
     --region $AWS_REGION
     
     
# Deploy ECS Service only on the FARGATE using default FARGATE Capacity provider 

export ECS_SERVICE_NAME=webapp-fargate-service-fargate
export TASK_COUNT=2

aws ecs create-service \
     --capacity-provider-strategy capacityProvider=FARGATE,weight=1 \
     --cluster $ECS_FARGATE_CLUSTER_NAME \
     --service-name $ECS_SERVICE_NAME \
     --task-definition $WEBAPP_FARGATE_TASK_DEF:4 \
     --desired-count $TASK_COUNT \
     --region $AWS_REGION \
 	 --network-configuration "awsvpcConfiguration={subnets=[subnet-764d7d11],securityGroups=[sg-4f3f0d1e],assignPublicIp="ENABLED"}"


# Deploy ECS Service only on the FARGATE SPOT using default FARGATE-SPOT Capacity provider 

export ECS_SERVICE_NAME=webapp-fargate-service-fargate-spot
export TASK_COUNT=2

aws ecs create-service \
     --capacity-provider-strategy capacityProvider=FARGATE_SPOT,weight=1 \
     --cluster $ECS_FARGATE_CLUSTER_NAME \
     --service-name $ECS_SERVICE_NAME \
     --task-definition $WEBAPP_FARGATE_TASK_DEF:4 \
     --desired-count $TASK_COUNT \
     --region $AWS_REGION \
 	 --network-configuration "awsvpcConfiguration={subnets=[subnet-764d7d11],securityGroups=[sg-4f3f0d1e],assignPublicIp="ENABLED"}"


# Deploy ECS Service both on the FARGATE and FARGATE SPOT using default FARGATE and FARGATE-SPOT Capacity provider 

export ECS_SERVICE_NAME=webapp-fargate-service-mix
export TASK_COUNT=4

aws ecs create-service \
     --capacity-provider-strategy capacityProvider=FARGATE,weight=3 capacityProvider=FARGATE_SPOT,weight=1 \
     --cluster $ECS_FARGATE_CLUSTER_NAME \
     --service-name $ECS_SERVICE_NAME \
     --task-definition $WEBAPP_FARGATE_TASK_DEF:4 \
     --desired-count $TASK_COUNT \
     --region $AWS_REGION \
 	 --network-configuration "awsvpcConfiguration={subnets=[subnet-764d7d11],securityGroups=[sg-4f3f0d1e],assignPublicIp="ENABLED"}"

