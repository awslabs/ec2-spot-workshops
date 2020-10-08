---
title: "Explore the service"
weight: 65
---

In this step, we check that our application is available, and how our tasks got distributed on our ECS instances.

Get the DNS name of the Applicaton Load Balancer from the output section of the CloudFormation stack.

![Get DNS](/images/ecs-spot-capacity-providers/CFN.png)

Open a brower tab and enter this URL. You should see a simple web page displaying various useful info about the underlyong infrastucture used to run this application inside a docker container.

![Application](/images/ecs-spot-capacity-providers/app.png)

As you keep refreshing the web page, you will notice some of the above data changing as ALB keeps routing the requests to different tasks across the instances in the ECS Cluster.

Now let's check if the tasks are distributed on On-Demand and Spot Capacity Providers according to the Capacity Provider Strategy that we configured.

Run the below command to see how tasks are distributed across the Capacity Providers.

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

Does the split between CP-OD and CP-SPOT adhere to our Capacity Provider Strategy? move to the next step in the workshop to dive deeper into the result.