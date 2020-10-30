---
title: "Setup c3vis (Cloud Container Cluster Visualizer)  Tool"
weight: 35
---

The [C3vis](https://github.com/ExpediaDotCom/c3vis) opensource tool is useful to show the visual representation of the tasks placements across instances in an ECS Cluster.  

Open a new terminal in your Cloud9 Environment.

![c3vis](/images/ecs-spot-capacity-providers/cloud9_new_terminal.png)

To access the application in your browser, you need to enable port 8080 in the Security Group associated with this Cloud9 Instance.

```bash

export SECURITY_GROUP=$( aws ec2 describe-security-groups --filters Name=group-name,Values='aws-cloud9-EcsSpotWorkshop*' | jq -r '.SecurityGroups[0].GroupId')
echo "Cloud9 Instance Security group is $SECURITY_GROUP"

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0

```



Clone the c3vis tool repo 

```bash
cd ~/environment/
git clone https://github.com/ExpediaDotCom/c3vis.git
cd c3vis 
```

Build the c3is application docker image and run the container.

```bash
docker build -t c3vis .
docker run -e "AWS_REGION=$AWS_REGION" -p 8080:3000 c3vis
```

Open the preview application in your cloud9 environment and click on the arrow on the top right to open the application in the browser

![c3vis](/images/ecs-spot-capacity-providers/c3vs_tool.png)

The initial screen will look like the below, since there are no tasks or instances running in the cluster for now.

![c3vis](/images/ecs-spot-capacity-providers/c3vis2.png)

Since our EC Cluster is empty and does not have any instances, the c3vis application shows an empty page.
