---
title: "Explore ECS Service"
chapter: true
weight: 65
---

Test web application
---

Let’s first check if our application is up and running fine.  Go to the Target Group in the AWS console. check click on the targets. Ensure that all the targets are healthy.

Get the DNS name of the Applicaton Load Balancer from the output section of the Cloud formation stack.

![Get DNS](/images/ecs-spot-capacity-providers/CFN.png)

Open a brower tab and enter this DNS Name. You should see a simple web page displaying various useful info about the underlyong infrastucture used to run this application inside a docker container.

![Application](/images/ecs-spot-capacity-providers/app.png)

As you keep refresh the web page, you will notice that some of the above data changing as ALB keeps routing the requests to different docker containers across the CPs in the ECS Cluster.

Now let’s check if the tasks are distributed on on-demand and spot Capacity Providers as per the strategy.

Run the below command to see how tasks are distributed across the Capacity Providers.

```
export cluster_name=EcsSpotWorkshop 
export service_name=ec2-service-split
aws ecs describe-tasks \
--tasks $(aws ecs list-tasks --cluster $cluster_name \
--service-name $service_name --query taskArns[*] --output text) \
--cluster $cluster_name \
--query 'sort_by(tasks,&capacityProviderName)[*].{TaskArn:taskArn,CapacityProvider:capacityProviderName,Instance:containerInstanceArn,AZ:availabilityZone,Status:lastStatus}' \
--output table
```

The output of the above command should display a table like this below.

![Results Table](/images/ecs-spot-capacity-providers/table.png)

What did you notice? Do you have an explanation for the above distribution of 4 tasks on CP-OD and 6 on CP-SPOT? Take a guess before reading further.

Alternative let’s look at the C3VIS dashboard to see the visual representation of the ECS cluster and the distribution of tasks on different CPs.  Before you see the visual representation, try calculating yourself what the task distribution would be as per the CPS? Notice the CPS used for this service is CP-OD,base=2,weight=1, CP-SPOT,weight=3