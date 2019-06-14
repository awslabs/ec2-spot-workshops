---
title: "Instance Fleet configuration options"
weight: 85
---

While our cluster is starting (7-8 minutes) and the job is running (~5 minutes) let's take the time to look at some of the EMR Instance Fleets configurations we didn't dive into when starting the cluster.

![FleetSelection2](/images/running-emr-spark-apps-on-spot/emrinstancefleets-core.png)

#### Maximum Spot price 
Since Amazon EC2 Spot Instances [changed the pricing model and bidding is no longer required] (https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/), we have an optional "Max-price" field for our Spot reuqests, which would limit how much we're willing to pay for the instance. It is recommended to leave this value at 100% of the On-Demand price, in order to avoid limiting our instance diversification. We are going to pay the Spot market price regardless of the Maximum price that we can specify, and setting a higher max price does not increase the chance of getting Spot capacity. You can see the current Spot price in the EC2 Spot console under **Pricing History**.

#### Each instance counts as X units
This configuration allows us give each instance type in our diversified fleet a weight that will count towards our Total units. By default, this weight is configured as the number of vCPUs that the instance type has - this way it's easy to set the Total units to the number of vCPUs we want our cluster to run with, and EMR will select the best instances while taking into account the required number of instances to run. For example, if r4.xlarge is the instance type that EMR found to be the least likely to be interrupted and has the lowest price out of our selection, its weight is 4 and our total units (only Spot) are 64, then 16 * r4.xlarge instances will be launched by EMR for our Core fleet.
If my Spark application is memory driven, I can set the total units to the total amount of memory I want my cluster to run with, and change the "Each instance counts as" field to the total memory of the instance, leaving aside some memory for the operating system and other processes. For example, for the r4.xlarge I can set its weight to 25. If I then set up the Total units to 500 then EMR will bring up 20 * r4.xlrage instances in the Core fleet. Since our executor size is 18 GB, one executor will run on this instance type.