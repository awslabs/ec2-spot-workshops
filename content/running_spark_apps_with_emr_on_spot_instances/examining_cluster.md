---
title: "Examining the cluster"
weight: 95
---

In this section we will look at the utilization of our instances while the application is running, to examine how many Spark executors we are running and what is the instances utilization.

{{% notice note %}}
Do not expect to see full utilization of vCPUs and Memory on the EC2 instances, the wordcount Spark application we are running is not very intensive and is just used for demo purposes.
{{% /notice %}}

### Using CloudWatch Metrics
EMR emits several useful metrics to CloudWatch metrics. You can use the AWS Management Console to look at the metrics in two ways:\
1. In the EMR console, under the Monitoring tab in your Cluster's page\
2. By browsing to the CloudWatch service, and under Metrics, searching for the name of your cluster (copy it from the EMR Management Conosle) and clicking **EMR > Job Flow Metrics**

Some notable metrics:

* AppsRunning - you should see 1 since we only submitted one step to the cluster.\
* ContainerAllocated - this represents the number of container Spark executors that are running on your cluster, on the Core and Task Instance Fleets.\
* MemoryAllocatedMB * MemoryAvailableMB - you can graph them both to see how much memory the cluster is actually consuming for the wordcount Spark application out of the memory that the instances have.\

### Using Ganglia and YARN ResourceManager	
The recommended approach to connect to the web interfaces running on our EMR cluster is to use SSH tunneling. [Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-web-interfaces.html) to learn more about connecting to EMR interfaces.\
For the purpose of this workshop, and since we started our EMR cluster in a VPC public subnet, we can allow access in the EC2 Security Group in order to reach the TCP ports on which the web interfaces are listening on.

{{% notice warning %}}
Normally you would not run EMR in a public subnet and open TCP access to the master instance, this is just for educational purposes.
{{% /notice %}}

To allow access to your IP address to reach the EMR web interfaces via EC2 Security Groups:\
1. In your EMR cluster page, in the AWS Management Console, go to the Summary tab\
2. Click on the ID of the security under **Security groups for Master**\
3. Check the Security Group with the name **ElasticMapReduce-master**\
4. In the lower pane, click the **Inbound tab** and click the Edit button\
5. Click **Add Rule**. Under Type, select **All Traffic**, under Source, select **My IP**\
6. Click **Save**.

Go back to the Summary tab in your EMR cluster page, and you will see links to tools in the **Connections** section (you might need to refresh the page).\
1. Click **Ganglia** to open the web interface.\
2. Have a look around. Take notice of the heatmap (**Server Load Distribution**). Notable graphs are:\
* **Cluster CPU last hour** - this will show you the CPU utilization that our Spark application consumed on our EMR cluster. you should see that utilization varied and reached around 70%.\
* **Cluster Memory last hour** - this will show you how much memory we started the cluster with, and how much Spark actually consumed.\
3. Go back to the Summary page and click the **Resource Manager** link.\
4. On the left pane, click **Nodes**, and in the node table, you should see the number of Containers (Spark executors) that each node ran. This will correspond to the ContainerAllocated metric you saw in CloudWatch.\