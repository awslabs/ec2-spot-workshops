---
title: "Fleet configuration options"
weight: 85
---

While our cluster is starting (7-8 minutes) and the step is running (4-10 minutes depending on the instance types that were selected) let's take the time to look at some of the EMR Instance Fleets configurations we didn't dive into when starting the cluster.

![fleetconfigs](/images/running-emr-spark-apps-on-spot/emrinstancefleets-core1.png)

#### Maximum Spot price 
Since Amazon EC2 Spot Instances [changed the pricing model and bidding is no longer required] (https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/), we have an optional "Max-price" field for our Spot requests, which would limit how much we're willing to pay for the instance. It is recommended to leave this value at 100% of the On-Demand price, in order to avoid limiting our instance diversification. We are going to pay the Spot market price regardless of the Maximum price that we can specify, and setting a higher max price does not increase the chance of getting Spot capacity nor does it decrease the chance of getting your Spot Instances interrupted when EC2 needs the capacity back. You can see the current Spot price in the AWS Management Console under EC2 -> Spot Requests -> **Pricing History**.

#### Each instance counts as X units
This configuration allows us to give each instance type in our diversified fleet a weight that will count towards our Total units. By default, this weight is configured as the number of YARN VCores that the instance type has by default (this would typically equate to the number of EC2 vCPUs) - this way it's easy to set the Total units to the number of vCPUs we want our cluster to run with, and EMR will select the best instances while taking into account the required number of instances to run. For example, if r4.xlarge is the instance type that EMR found to be the least likely to be interrupted, its weight is 4 and our total units (only Spot) is 32, then 8 * r4.xlarge instances will be launched by EMR in the fleet.
If my Spark application is memory driven, I can set the total units to the total amount of memory I want my cluster to run with, and change the "Each instance counts as" field to the total memory of the instance, leaving aside some memory for the operating system and other processes. For example, for the r4.xlarge I can set its weight to 25. If I then set up the Total units to 500 then EMR will bring up 20 * r4.xlarge instances in the fleet. Since our executor size is 18 GB, one executor will run on this instance type.

#### Defined duration
This option will allow you run your EMR Instance Fleet on Spot Blocks, which are uninterrupted Spot Instances, available for 1-6 hours, at a lower discount compared to Spot Instances.

#### Provisioning timeout
You can determine that after a set amount of minutes, if EMR is unable to provision your selected Spot Instances due to lack of capacity, it will either start On-Demand instances instead, or terminate the cluster. This can be determined according to the business definition of the cluster or Spark application - if it is SLA bound and should complete even at On-Demand price, then the "Switch to On-Demand" option might be suitable. However, make sure you diversify the instance types in the fleet when looking to use Spot Instances, before you look into failing over to On-Demand.