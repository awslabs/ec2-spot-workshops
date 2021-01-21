---
title: "Examining the cluster"
weight: 95
---

In this section we will look at the utilization of our EC2 Spot Instances while the application is running, and examine how many Spark executors are running.

### EMR Management Console
To get started, let's check that your EMR cluster and Spark application are running.  
1. In our EMR Cluster page, the status of the cluster will either be Starting (in which case you can see the status of the hardware in the Summary or Hardware tabs) or Running.  
2. Move to the Steps tab, and your Spark application will either be Pending (for the cluster to start) or Running.

{{% notice note %}}
In this step, when you look at the utilization of the EMR cluster, do not expect to see full utilization of vCPUs and Memory on the EC2 instances, as the wordcount Spark application we are running is not very resource intensive and is just used for demo purposes.
{{% /notice %}}

### Using Ganglia, YARN ResourceManager and Spark History Server
The recommended approach to connect to the web interfaces running on our EMR cluster is to use SSH tunneling. [Click here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-web-interfaces.html) to learn more about connecting to EMR interfaces.  
For the purpose of this workshop, and since we started our EMR cluster in a VPC public subnet, we can allow access in the EC2 Security Group in order to reach the TCP ports on which the web interfaces are listening on.

{{% notice warning %}}
Normally you would not run EMR in a public subnet and open TCP access to the master instance, this faster approach is just used for the purpose of the workshop.
{{% /notice %}}

To allow access to your IP address to reach the EMR web interfaces via EC2 Security Groups:  
1. In your EMR cluster page, in the AWS Management Console, go to the **Summary** tab  
2. Click on the ID of the security under **Security groups for Master**  
3. Check the Security Group with the name **ElasticMapReduce-master**  
4. In the lower pane, click the **Inbound tab** and click the **Edit**  
5. Click **Add Rule**. Under Type, select **All Traffic**, under Source, select **My IP**  
6. Click **Save**

{{% notice note %}}
While the Ganglia web interface uses TCP port 80, the YARN ResourceManager web interface uses TCP port 8088 and the Spark History Server uses TCP port 18080, which might not allowed for outbound traffic on your Internet connection. If you are using a network connection that blocks these ports (or in other words, doesn't allow non-well known ports) then you will not be able to reach the YARN ResourceManager web interface and Spark History Server. You can either skip that part of the workshop, use a different Internet connection (i.e mobile hotspot) or consider using the more complex method of SSH tunneling described [here] (https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-web-interfaces.html)
{{% /notice %}}

Go back to the Summary tab in your EMR cluster page, and you will see links to tools in the **Connections** section (you might need to refresh the page).  
1. Click **Ganglia** to open the web interface.  
2. Have a look around. Take notice of the heatmap (**Server Load Distribution**). Notable graphs are:  
* **Cluster CPU last hour** - this will show you the CPU utilization that our Spark application consumed on our EMR cluster. you should see that utilization varied and reached around 70%.  
* **Cluster Memory last hour** - this will show you how much memory we started the cluster with, and how much Spark actually consumed.  
3. Go back to the Summary page and click the **Resource Manager** link.  
4. On the left pane, click **Nodes**, and in the node table, you should see the number of containers that each node ran.  
5. Go back to the Summary page and click the **Spark History Server** link.  
6. Click on the App ID in the table (where App Name = Amazon reviews word count) and go to the **Executors** tab  
7. You can again see the number of executors that are running in your EMR cluster under the **Executors table**


### Using CloudWatch Metrics
EMR emits several useful metrics to CloudWatch metrics. You can use the AWS Management Console to look at the metrics in two ways:  
1. In the EMR console, under the Monitoring tab in your Cluster's page  
2. By browsing to the CloudWatch service, and under Metrics, searching for the name of your cluster (copy it from the EMR Management Console) and clicking **EMR > Job Flow Metrics**

{{% notice note %}}
The metrics will take a few minutes to populate.
{{% /notice %}}

Some notable metrics:  
* **AppsRunning** - you should see 1 since we only submitted one step to the cluster.  
* **ContainerAllocated** - this represents the number of containers that are running on your cluster, on the Core and Task Instance Fleets. These would the be Spark executors and the Spark Driver.  
* **MemoryAllocatedMB** & **MemoryAvailableMB** - you can graph them both to see how much memory the cluster is actually consuming for the wordcount Spark application out of the memory that the instances have.  

#### Terminate the cluster
When you are done examining the cluster and using the different UIs, terminate the EMR cluster from the EMR management console. This is not the end of the workshop though - we still have some interesting steps to go.

#### Number of executors in the cluster
With 32 Spot Units in the Task Instance Fleet, EMR launched either 8 * xlarge (running one executor) or 4 * 2xlarge instances (running 2 executors) or 2 * 4xlarge instances (running 4 executors), so the Task Instance Fleet provides 8 executors / containers to the cluster.  
The Core Instance Fleet launched one xlarge instance, able to run one executor.
{{%expand "Question: Did you see more than 9 containers in CloudWatch Metrics and in YARN ResourceManager? if so, do you know why? Click to expand the answer" %}}
Your Spark application was configured to run in Cluster mode, meaning that the **Spark driver is running on the Core node**. Since it is counted as a container, this adds a container to our count, but it is not an executor.
{{% /expand%}}
