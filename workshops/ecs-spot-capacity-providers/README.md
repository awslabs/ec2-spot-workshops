## EC2 Spot Workshop : ECS_Cluster_Auto_Scaling



In this workshop, you will deploy the following:

### Step1 :  Create a Launch Template with ECS optimized AMI and with user data configuring ECS Cluster  
TBD
### Step2 : Create a ASG for only OD instances i.e. ecs-fargate-cluster-autoscale-asg-od with MIN 0 and MAX 10
TBD
### Step3 : Create a Capacity Provider using this ASG i.e. od-capacity_provider_3  with Managed Scaling Enabled with target capacity of 100
TBD
### Step4 : Create a ASG for pnly Spot instances i.e. ecs-fargate-cluster-autoscale-asg-spot)  with MIN 0 and MAX 10
TBD

### Step5 : Create a Capacity Provider using this ASG i.e. spot-capacity_provider_3 with Managed Scaling Enabled with target capacity of 100

### Step6 : Create an ECS cluster (i.e. EcsFargateCluster) with above two capacity providers and with a default capacity provider strategy

The default strategy is od-capacity_provider_3,base=1,weight=1  which means any tasks/services will be deployed in OD if strategy is not explicitly specified while launching them

### Step7 : Add default fargate capacity providers i.e. FARGATE and FARGATE-SPOT to the above cluster
TBD
### Step8 :Create a task definition for fargate i.e. webapp-fargate-task
TBD
### Step9 :Create a task definition for EC2 i.e. webapp-ec2-task
TBD
### Step10 : Deployed 6 Services as follows
TBD
Deploy a service i.e. webapp-ec2-service-od (with 2 tasks) to launch tasks ONLY on OD Capacity Providers
a.	2 tasks gets deployed on OD instances launched from od-capacity_provider_3  
Deploy a service i.e. webapp-ec2-service-spot (with 2 tasks) to launch tasks ONLY on Spot Capacity Providers
a.	2 tasks gets deployed on Spot instances launched from spot-capacity_provider_3
Deploy a service i.e. webapp-ec2-service-mix (with 6 tasks) to launch tasks on both OD(weight=1)  and Spot (weight=3) Capacity Providers
a.	2 tasks on OD instances from od-capacity_provider_3  and 4 tasks on Spot instances from spot-capacity_provider_3
Deploy a service i.e. webapp-fargate-service-fargate (with 2 tasks) to launch tasks ONLY on FARGATE Capacity Provider
a.	2 tasks gets deployed on FARGATE
Deploy a service i.e. webapp-fargate-service-fargate-spot (with 2 tasks) to launch tasks ONLY FARGATE-SPOT Capacity Provider
a.	2 tasks gets deployed on FARGATE
Deploy a service i.e. webapp-fargate-service--mix (with 4 tasks) to launch tasks on both FARGATE(weight=3) and FARGATE-SPOT (weight=1)
a.	3 tasks gets deployed on FARGATE  and 1 tasks on FARGATE-SPOT

### Workshop Cleanup
