---
title: "Scaling EMR cluster"
weight: 95
---

While you can always manually adjust the number of core or task nodes (EC2 instances) in your Amazon EMR cluster, you can also use the power of EMR auto-scaling to automatically adjust the cluster size in response to changing workloads without any manual intervention.

In this section, we are going to enable automatic scaling for the cluster using **[Amazon EMR Managed Scaling](https://aws.amazon.com/blogs/big-data/introducing-amazon-emr-managed-scaling-automatically-resize-clusters-to-lower-cost/)**. With EMR Managed scaling you specify the minimum and maximum compute limits for your cluster and Amazon EMR automatically resizes EMR clusters for best performance and resource utilization. EMR Managed Scaling constantly monitors key metrics based on workload and optimizes the cluster size for best resource utilization. 

{{% notice note %}}
EMR Managed Scaling is supported for Apache Spark, Apache Hive and YARN-based workloads on Amazon EMR versions 5.30.1 and above.
{{% /notice %}}

### Enable Managed Scaling

1. In your EMR cluster page, in the AWS Management Console, go to the **Summary** tab.
1. Copy the **ID** from the **Summary** tab.
1. Open the shell terminal in your Cloud9 enivronment that you created at the beginning of this workshop.
1. Run the command after replacing the **CLUSTER-ID** with the one you copied earlier.

```Bash
aws emr put-managed-scaling-policy \
    --cluster-id CLUSTER-ID  \
    --managed-scaling-policy "ComputeLimits={
            UnitType=InstanceFleetUnits,
            MinimumCapacityUnits=8,
            MaximumCapacityUnits=16,
            MaximumOnDemandCapacityUnits=0,
            MaximumCoreCapacityUnits=8
        }"
```

In the command above, we have set the :

* Mimumum and maximum capacity for the worker nodes to 8 and 16 respectively.
* **MaximumOnDemandCapacityUnits** to 0 to only use EC2 Spot instances.
* **MaximumCoreCapacityUnits** to 8 to allow scaling of core nodes.


### Managed Scaling in Action

Now we want to post more jobs to the cluster and to trigger scaling.

1. In your EMR cluster page, in the AWS Management Console, go to the **Steps** tab.
1. Select the Spark application that you created during cluster creation and click **Clone step**
![jobCloning](/images/running-emr-spark-apps-on-spot/emrsparkjobcloning.png)
1. On the next screen, click **Add**. Wait for couple of moments so that step is in **Running** state.
1. Go to the **Events** tab to see the scaling events.
![scalingEvent](/images/running-emr-spark-apps-on-spot/emrsparkscalingevent.png)

With this configuration, Your EMR cluster with automatically scale based on compute requirements of the job and add EC2 spot instances while keeping the limits into consideration.

{{% notice note %}}
Managed Scaling now also has the capability to prevent scaling down instances that store intermediate shuffle data for Apache Spark. Intelligently scaling down clusters without removing the instances that store intermediate shuffle data prevents job re-attempts and re-computations, which leads to better performance, and lower cost.
**[Click here](https://aws.amazon.com/about-aws/whats-new/2022/03/amazon-emr-managed-scaling-shuffle-data-aware/)** for more details.
{{% /notice %}}