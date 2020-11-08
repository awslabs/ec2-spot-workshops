---
title: "Test application and check Task distribution in the Cluster"
weight: 65
---

In this section, let us first check if our web application deployed successfully and working as expected. We will also check if ECS spreads our tasks across CP-OD and CP-SPOT capacity provides in accordance with the strategy we used during the service configuration.

Get the DNS name of the Application Load Balancer from the output section of the CloudFormation stack.

![Get DNS](/images/ecs-spot-capacity-providers/CFN.png)

Open a browser tab and enter this URL. You should see a simple web page displaying various useful info about the task such IP address, availability zone, lifecycle of the EC2 instance. 

![Application](/images/ecs-spot-capacity-providers/app.png)

As you keep refreshing the web page, you will notice the content of the page changes as the Application Load Balancer keeps routing the requests to different tasks across the instances in the ECS Cluster.

Now let's check if the tasks distributed on On-Demand and Spot capacity providers according to the capacity provider strategy that we configured.

Run below command to see the task distribution across the ECS cluster.

```bash
export cluster_name=EcsSpotWorkshop 
export service_name=ec2-service-split
aws ecs describe-tasks \
--tasks $(aws ecs list-tasks --cluster $cluster_name \
--service-name $service_name --query taskArns[*] --output text) \
--cluster $cluster_name \
--query 'sort_by(tasks,&capacityProviderName)[*].{TaskArn:taskArn,CapacityProvider:capacityProviderName,Instance:containerInstanceArn,AZ:availabilityZone,Status:lastStatus}' \
--output table
```

You will see the result in table similar to the below:

![Results Table](/images/ecs-spot-capacity-providers/table.png)

What did you observe? Did ECS spread your tasks between CP-OD and CP-SPOT capacity providers according to the capacity provider strategy?  Let us move to next step to see what happened.


