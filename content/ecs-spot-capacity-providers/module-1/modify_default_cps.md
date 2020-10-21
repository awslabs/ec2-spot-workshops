---
title: "Setup default capacity provider strategy"
weight: 25
---

To modify the CP, follow these steps:

* Click on the *Capacity Providers* tab
* Click on the *Update Cluster* option on the top right
* For Capacity Provider name, enter *CP-SPOT*
* Click on *Add another provider*
* Click on *Add another provider* one more time
* For Provider 1, select *CP-OD*, set base value to *2* and leave weight to default value of *1*
* For Provider 2, select *CP-SPOT*, leave base to default value of *0* and set weight to *3*
* Click on *Update* on bottom right


![Capacity Provider Strategy](/images/ecs-spot-capacity-providers/CPS.png)

Also note the default capacity provider strategy used in the above command. It sets base=2 and weight=1 for On-demand ASG CP and weight of 3 for CP-SPOT. That means, ECS will first place 2 tasks (since base=2) on CP-OD and split the remaining tasks between CP-OD and CP-SOT in 1:3 ratio, which means that for every 1 task on CP-OD, 3 will be placed on CP-SPOT.

You can override this default Capacity Provider strategy and specify a different strategy for each service independently. 
