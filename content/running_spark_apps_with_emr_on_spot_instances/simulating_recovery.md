---
title: "(Optional) simulating recovery"
weight: 149
---

EMR replenishes the target capacity if some EC2 Instances failed, were terminated/stopped, or received an EC2 Spot Interruption.

In this optional step, you will re-run the cluster and the Spark application, and terminate some of the Task Fleet instances in order to observe the recovery capabilities of EMR and Spark, and check that the application still completes successfully. Since it is not possible to simulate an EC2 Spot Interruption in an EMR cluster, we will have to manually terminate EC2 instances to receive a similar effect.

{{% notice note %}}
This is an optional step that will take approximately 20 minutes more than the original running time of the workshop. Feel free to skip this step and go directly to the **Conclusions and cleanup** step.
{{% /notice %}}

{{% notice info %}}
[Click here] (https://aws.amazon.com/blogs/big-data/spark-enhancements-for-elasticity-and-resiliency-on-amazon-emr/) For an in-depth blog post about Spark's resiliency in EMR 
{{% /notice %}}

#### Step objectives:  
1. Observe that EMR replenishes the target capacity if some EC2 Instances failed, were terminated/stopped, or received an EC2 Spot Interruption.
2. Observe that the Spark application running in your EMR cluster still completes successfully, despite losing executors due to instance terminations.

#### Re-launch your cluster and application
1. In the EMR console, select the cluster that you launched in this workshop, and click the **Clone** button.
2. In the popup dialog **"Would you like to include steps"** select **Yes** and click **Clone**.
3. EMR console duplicated all the cluster settings for you - click the **Create cluster** button.
4. Refresh the Summary tab in the EMR console until the status of the cluster is **Running step** and the Master, Core and Task fleets are all in the **Running** state.

#### Manually terminate some of the EMR Task Fleet nodes
1. Go to the EC2 console, and identify the instances in your Task Fleet. You can do so by using the following filter: **Key=aws:elasticmapreduce:instance-group-role & Value=TASK**. If you have other EMR clusters running in the account/region, make sure you identify your own cluster by further filtering according to its Name tag.
2. Randomly select half of the instances that were filtered, and click Actions -> Instance State -> Terminate -> **Yes, Terminate**

#### Verify that EMR replenished the capacity, and that the step completed successfully
1. Within 2-3 minutes, refresh the EC2 console as well as the Task Fleet in the EMR console under the Hardware tab, and you should see new Task Fleet instances created by EMR to replenish the capacity, after you terminated the previous instances.
2. In the EMR console, go to the Steps tab. Refresh the tab until your application has reached the **Completed** status. Because some instances were terminated mid-run, the Step will still complete, but will take longer than you previously observed in the workshop, because Spark had to repeat some of the work.
