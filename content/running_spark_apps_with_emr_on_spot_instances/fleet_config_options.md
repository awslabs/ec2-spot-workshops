---
title: "Fleet configuration options"
weight: 85
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



While our cluster is starting (7-8 minutes) and the step is running (4-10 minutes depending on the instance types that were selected) let's take the time to look at some of the EMR instance fleets configurations we didn't dive into when starting the cluster.

![fleetconfigs](/images/running-emr-spark-apps-on-spot/emrinstancefleets-core.png)

#### Maximum Spot price 
Since Nov 2017, Amazon EC2 Spot Instances [changed the pricing model and bidding was eliminated](https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/). We have an optional "Max-price" field for our Spot requests, which would limit how much we're willing to pay for the instance. It is recommended to leave this value at 100% of the On-Demand price, in order to avoid limiting our instance diversification. We are going to pay the Spot market price regardless of the Maximum price that we can specify, and setting a higher max price does not increase the chance of getting Spot capacity nor does it decrease the chance of getting your Spot Instances interrupted when EC2 needs the capacity back. You can see the current Spot price in the AWS Management Console under **EC2 >> Spot Requests >> Pricing History**.

#### Each instance counts as X units
 This configuration allows us to give each instance type in our diversified fleet a weight that will count towards our **Target capacity**. By default, this weight is configured as the number of YARN VCores that the instance type has by default, this would typically equate to the number of EC2 vCPUs. For example, r4.xlarge has a default weight set to 4 units and you have set the **Target capacity** for task fleet to 32. If EMR picks r4.xlarge as the most available Spot Instance, then 8 * r4.xlarge instances will be launched by EMR in the task fleet.

If your Spark application is memory driven, you can set the **Target capacity** to the total amount of memory you want the cluster to run with. You can change the **Each instance counts as** field to the total memory of the instance, leaving aside some memory for the operating system and other processes. For example, for the r4.xlarge you can set **Each instance counts as** 18 units and set **Target capacity** to 144.  If EMR picks r4.xlarge as the most available Spot Instance, then 8 * r4.xlarge instances will be launched by EMR in the task fleet. Since your executor size is 18 GB, one executor will run on each r4.xlarge instance.

#### Provisioning timeout
You can determine that after a set amount of minutes, if EMR is unable to provision your selected Spot Instances due to lack of capacity, it will either start On-Demand instances instead, or terminate the cluster. This can be determined according to the business definition of the cluster or Spark application - if it is SLA bound and should complete even at On-Demand price, then the "Switch to On-Demand" option might be suitable. However, make sure you diversify the instance types in the fleet when looking to use Spot Instances, before you look into failing over to On-Demand.