---
title: "Deploying c3vis (Cloud Container Cluster Visualizer)  Tool"
chapter: true
weight: 35
---

Cloud Container Cluster Visualizer(C3vis)
---

The [C3vis] (https://github.com/ExpediaDotCom/c3vis)   is a useful to show the visual representation of the tasks placements across instances in an ECS Cluster.

Run the following commands on a new terminal in the Cloud 9 environment.

```
git clone https://github.com/ExpediaDotCom/c3vis.git
cd c3vis 
docker build -t c3vis .
docker run -e "AWS_REGION=$AWS_REGION" -p 8080:3000 c3vis

export SECURITY_GROUP=$( aws ec2 describe-security-groups --filters Name=vpc-id,Values=$vpc  Name=group-name,Values='aws-cloud9-EcsSpotWorkshop*' | jq -r '.SecurityGroups[0].GroupId')
echo "Cloud9 Instance Security group is $SECURITY_GROUP"
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0

```

Open the application in a new window as follows

![c3vis](/images/ecs-spot-capacity-providers/c3vis3.png)

The initial screen looks  below since there are no tasks or instances running in the cluster.

![c3vis](/images/ecs-spot-capacity-providers/c3vis2.png)
