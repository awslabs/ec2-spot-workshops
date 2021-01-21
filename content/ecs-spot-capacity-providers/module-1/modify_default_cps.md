---
title: "Setup default capacity provider strategy"
weight: 60
---

Once that we have defined the ECS Cluster Capacity Providers, we can setup a default strategy. New services and tasks launched to this cluster will use this strategy by default. You can create however specific strategies different from the default for each service.

For our default capacity provider we have considered the following application requirements:

* There should be at least 2 tasks running on On-Demand instances to serve the normal traffic. The **base=2** configuration satisfies this requirement.
* Tasks deployed to On-Demand and Spot Instances, follow a 1:3 ratio to handle any additional traffic

With this requirements we can set **EcsSpotWorkshopUpdate** cluster default capacity provider strategy, follow these steps:

* Go to the ECS Cluster console and select the **EcsSpotWorkshopUpdate** ECS Cluster.
* Click on the **Update Cluster** option on the top right, and click **Add Another Provider**
* For Provider 1: select **CP-OD**, set base value to **2** and weight to **1**
* Click on **Add another provider** one more time
* For Provider 2: select **CP-SPOT**, leave base to default value of **0** and set weight to **3**
* Click on **Update** on bottom right


![Capacity Provider Strategy](/images/ecs-spot-capacity-providers/CPS.png)

{{% notice note %}}
Checkout the strategy configuration; it sets **`base=2`** and **`weight=1`** for CP-OD and **`weight=3`** for CP-SPOT. That means, ECS first places 2 tasks (since base=2) to CP-OD and then splits the remaining tasks between CP-OD and CP-SOT in 1:3 ratio, so for every 1 task on CP-OD, 3 tasks placed on CP-SPOT.
{{% /notice %}}
