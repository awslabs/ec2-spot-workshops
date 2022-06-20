---
title: "Launch a cluster - Step 2"
weight: 70
---

Under "**Instance group configuration**", select Instance Fleets. Under Network, select the VPC that you deployed using the CloudFormation template earlier in the workshop (or the default VPC if you're running the workshop in an AWS event), and select all subnets in the VPC. When you select multiple subnets, the EMR cluster will still be started in a single Availability Zone, but EMR Instance Fleets will make the best instance type selection based on available capacity and price across the multiple availability zones that you specified. Also, click on the checkbox "Apply allocation strategy" to leverage lowest-price allocation for On-Demand Instances and Capacity-Optimized allocation for Spot Instances; this will also allow you to configure up to 15 instance types on the Task Instance fleet.
![FleetSelection1](/images/running-emr-spark-apps-on-spot/emrinstancefleetsnetwork.png)


### Setting up our EMR Master node, and Core / Task Instance Fleets
{{% notice note %}}
The workshop focuses on running Spot Instances across all the cluster node types for cost savings. If you want to dive deeper into when to use On-Demand and Spot in your EMR clusters, **[click here](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-plan-instances-guidelines.html#emr-plan-spot-instances)**
{{% /notice %}}

#### **Master node**:
Unless your cluster is very short-lived and the runs are cost-driven, avoid running your Master node on a Spot Instance. We suggest this because a Spot interruption on the Master node terminates the entire cluster.  
For the purpose of this workshop, we will run the Master node on a Spot Instance as we simulate a relatively short lived job running on a transient cluster. There will not be business impact if the job fails due to a Spot interruption and later re-started.  
Click **Add / remove instance types to fleet** and select two relatively cheaper instance types - i.e c5.xlarge and m5.xlarge and check Spot under target capacity. EMR will only provision one instance, but will select the best instance type for the Master node from the Spot instance pools with the optimal capacity.
![FleetSelection1](/images/running-emr-spark-apps-on-spot/emrinstancefleets-master.png)


#### **Core Instance Fleet**:
Avoid using Spot Instances for Core nodes if your Spark applications use HDFS. That prevents a situation where Spot interruptions cause data loss for data that was written to the HDFS volumes on the instances. For short-lived applications on transient clusters, as is the case in this workshop, we are going to run our Core nodes on Spot Instances.  
When using EMR Instance Fleets, one Core node is mandatory. Since we want to scale out and run our Spark application on our Task nodes, let's stick to the one mandatory Core node. We will specify **4 Spot units**, and select instance types that count as 4 units and will allow to run one executor.  
Under the core node type, click **Add / remove instance types to fleet** and select instance types that you noted before as suitable to run an executor (given the 18G executor size), for example:  
![FleetSelection2](/images/running-emr-spark-apps-on-spot/emrinstancefleets-core1.png)

#### **Task Instance Fleet**:
Our task nodes will only run Spark executors and no HDFS DataNodes, so this is a great fit for scaling out and increasing the parallelization of our application's execution, to achieve faster execution times.
Under the task node type, click **Add / remove instance types to fleet** and select **up to 15 instance types** you noted before as suitable for your executor size.  
Since our executor size is 4 vCPUs, and each instance counts as the number of its vCPUs towards the total units, let's specify **32 Spot units** in order to run 8 executors, and allow EMR to select the best instance type in the Task Instance Fleet to run the executors on.

![FleetSelection3](/images/running-emr-spark-apps-on-spot/emrinstancefleets-task2.png)

### Enabling cluster scaling

While you can always manually adjust the number of core or task nodes (EC2 instances) in your Amazon EMR cluster, you can also use the power of EMR auto-scaling to automatically adjust the cluster size in response to changing workloads without any manual intervention.

Let's enable scaling for this cluster using **[Amazon EMR Managed Scaling](https://aws.amazon.com/blogs/big-data/introducing-amazon-emr-managed-scaling-automatically-resize-clusters-to-lower-cost/)**. With EMR Managed scaling you specify the minimum and maximum compute limits for your cluster and Amazon EMR automatically resizes EMR clusters for best performance and resource utilization. EMR Managed Scaling constantly monitors key metrics based on workload and optimizes the cluster size for best resource utilization

{{% notice note %}}
EMR Managed Scaling is supported for Apache Spark, Apache Hive and YARN-based workloads on Amazon EMR versions 5.30.1 and above.
{{% /notice %}}

1. Select the checkbox for **Enable Cluster Scaling** in **Cluster scaling** section.
1. Set **MinimumCapacityUnits** to **36**, which includes core node capacity units plus capacity units for 8 task executors.
1. Set **MaximumCapacityUnits** to **68**, keeping same capacity units for core nodes but allowing scaling for task nodes.
1. Set **MaximumOnDemandCapacityUnits** to **0**, use EC2 Spot instances only for both Code Nodes and Task Nodes.
1. Set **MaximumCoreCapacityUnits** to **4**, keeping same capacity units for core nodes.
![emrmanagedscaling](/images/running-emr-spark-apps-on-spot/emrmanagedscaling.png)

{{% notice note %}}
Managed Scaling now also has the capability to prevent scaling down instances that store intermediate shuffle data for Apache Spark. Intelligently scaling down clusters without removing the instances that store intermediate shuffle data prevents job re-attempts and re-computations, which leads to better performance, and lower cost.
**[Click here](https://aws.amazon.com/about-aws/whats-new/2022/03/amazon-emr-managed-scaling-shuffle-data-aware/)** for more details.
{{% /notice %}}

click **Next** to continue to the next steps of launching your EMR cluster.
