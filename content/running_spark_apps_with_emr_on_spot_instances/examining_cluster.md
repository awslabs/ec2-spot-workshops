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
To connect to the web interfaces running on our EMR cluster you need to use SSH tunneling. [Click here](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-web-interfaces.html) to learn more about connecting to EMR interfaces.  

First, we need to grant SSH access from the Cloud9 environment to the EMR cluster master node:  
1. In your EMR cluster page, in the AWS Management Console, go to the **Summary** tab  
2. Click on the ID of the security group in **Security groups for Master**  
3. Check the Security Group with the name **ElasticMapReduce-master**  
4. In the lower pane, click the **Inbound tab** and click the **Edit inbound rules**  
5. Click **Add Rule**. Under Type, select **SSH**, under Source, select **Custom**. As the Cloud9 environment and the EMR cluster are on the default VPC, introduce the CIDR of your Default VPC (e.g. 172.16.0.0/16). To check your VPC CIDR, go to the [VPC console](https://console.aws.amazon.com/vpc/home?#) and look for the CIDR of the **Default VPC**. 
6. Click **Save**

At this stage, we'll be able to ssh into the EMR master node. First we will access the Ganglia web interface to look at cluster metrics:

1. Go to the EMR Management Console, click on your cluster, and open the **Application user interfaces** tab. You'll see the list of on-cluster application interfaces. 
2. Copy the master node DNS name from one of the interface urls, it will look like ec2.xx-xxx-xxx-xxx.<region>.compute.amazonaws.com
3. Establish an SSH tunnel to port 80, where Ganglia is bound, executing the below command on your Cloud9 environment (update the command with your master node DNS name): 

    ```
    ssh -i ~/environment/emr-workshop-key-pair.pem -N -L 8080:ec2-###-##-##-###.compute-1.amazonaws.com:80 hadoop@ec2-###-##-##-###.compute-1.amazonaws.com
    ```

    You'll get a message saying the authenticity of the host can't be established. Type 'yes' and hit enter. The message will look similar to the following:

    ```
    The authenticity of host 'ec2-54-195-131-148.eu-west-1.compute.amazonaws.com (172.31.36.62)' can't be established.
    ECDSA key fingerprint is SHA256:Cmv0qkh+e4nm5qir6a9fPN5DlgTUEaCGBN42txhShoI.
    ECDSA key fingerprint is MD5:ee:63:d0:4a:a2:29:8a:c9:41:1b:a1:f0:f6:8e:68:4a.
    Are you sure you want to continue connecting (yes/no)? 
    ```
    
4. Now, on your Cloud9 environment, click on the "Preview" menu on the top and then click on "Preview Running Application". You'll see a browser window opening on the environment with an Apache test page. on the URL, append /ganglia/ to access the Ganglia Interface. The url will look like https://xxxxxx.vfs.cloud9.eu-west-1.amazonaws.com/ganglia/. 
![Cloud9-Ganglia](/images/running-emr-spark-apps-on-spot/cloud9-ganglia.png)
5. Click on the button next to "Browser" (arrow inside a box) to open Ganglia in a dedicated browser page.Have a look around. Take notice of the heatmap (**Server Load Distribution**). Notable graphs are:  
* **Cluster CPU last hour** - this will show you the CPU utilization that our Spark application consumed on our EMR cluster. you should see that utilization varied and reached around 70%.  
* **Cluster Memory last hour** - this will show you how much memory we started the cluster with, and how much Spark actually consumed.  

Now, let's look at the **Resource Manager** application user interface. 

1. Go to the Cloud9 terminal where you have established the ssh connection, and press ctrl+c to close it. 
1. Create an SSH tunnel to the cluster master node on port 8088 by running this command (update the command with your master node DNS name):

    ```
    ssh -i ~/environment/emr-workshop-key-pair.pem -N -L 8080:ec2-###-##-##-###.compute-1.amazonaws.com:8088 hadoop@ec2-###-##-##-###.compute-1.amazonaws.com
    ```

1. Now, on your browser, update the URL to "/cluster" i.e. https://xxxxxx.vfs.cloud9.eu-west-1.amazonaws.com/cluster
1. On the left pane, click Nodes, and in the node table, you should see the number of containers that each node ran.

Now, let's look at **Spark History Server** application user interface:

1. Go to the Cloud9 terminal where you have established the ssh connection, and press ctrl+c to close it.
1. Create an SSH tunnel to the cluster master node on port 18080 by running this command (update the command with your master node DNS name):

    ```
    ssh -i ~/environment/emr-workshop-key-pair.pem -N -L 8080:ec2-###-##-##-###.compute-1.amazonaws.com:18080 hadoop@ec2-###-##-##-###.compute-1.amazonaws.com
    ```

1. Now, on your browser, go to the base URL of your Cloud9 environment i.e. https://xxxxxx.vfs.cloud9.eu-west-1.amazonaws.com/
1. Click on the App ID in the table (where App Name = Amazon reviews word count) and go to the **Executors** tab  
1. You can again see the number of executors that are running in your EMR cluster under the **Executors table**


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

#### Number of executors in the cluster
With 32 Spot Units in the Task Instance Fleet, EMR launched either 8 * xlarge (running one executor) or 4 * 2xlarge instances (running 2 executors) or 2 * 4xlarge instances (running 4 executors), so the Task Instance Fleet provides 8 executors / containers to the cluster.  
The Core Instance Fleet launched one xlarge instance, able to run one executor.
{{%expand "Question: Did you see more than 9 containers in CloudWatch Metrics and in YARN ResourceManager? if so, do you know why? Click to expand the answer" %}}
Your Spark application was configured to run in Cluster mode, meaning that the **Spark driver is running on the Core node**. Since it is counted as a container, this adds a container to our count, but it is not an executor.
{{% /expand%}}
