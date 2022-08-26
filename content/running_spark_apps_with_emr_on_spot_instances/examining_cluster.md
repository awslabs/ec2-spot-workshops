---
title: "Examining the cluster"
weight: 90
---

In this section you will look at the utilization of instance fleets and examine Spark executors, while the Spark application is running.

### EMR Management Console
To get started, let's check that your EMR cluster and Spark application are running.  
1. In our EMR Cluster page, the status of the cluster will either be **Starting** or **Running**. If the status is **Starting** then you can see the status of instance fleets in the Hardware tab, while you wait for cluster to reach **Running** stage.
2. Move to the Steps tab, the Spark application will either be **Pending** or **Running**. If the status is **Pending** then Wait for Spark application to reach **Running** stage

### EMR On-cluster application user interfaces
To connect to the application user interfaces running on our EMR cluster you need to use SSH tunneling. [Click here](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-web-interfaces.html) to learn more about connecting to EMR interfaces.  

First, we need to grant SSH access from the Cloud9 environment to the EMR cluster master node:  
1. In your EMR cluster page, in the AWS Management Console, go to the **Summary** tab  
1. Click on the ID of the security group in **Security groups for Master**  
1. Check the Security Group with the name **ElasticMapReduce-master**  
1. In the lower pane, click the **Inbound tab** and click the **Edit inbound rules**  
1. Click **Add Rule**. Under Type, select **SSH**, under Source, select **Custom**. As the Cloud9 environment and the EMR cluster are on the default VPC, introduce the CIDR of your Default VPC (e.g. 172.16.0.0/16). To check your VPC CIDR, go to the [VPC console](https://console.aws.amazon.com/vpc/home?#) and look for the CIDR of the **Default VPC**. 
1. Click **Save**

At this stage, you will be able to ssh into the EMR master node. 

{{% notice note %}}
In the following steps, you might not see full utilization of vCPUs and Memory on the EC2 instances because the wordcount demo Spark application is not very resource intensive.
{{% /notice %}}

#### Access Resource Manager web interface

1. Go to the EMR Management Console, click on your cluster, and open the **Application user interfaces** tab. You'll see the list of on-cluster application interfaces. 
1. Copy the **Master public DNS** from the **Summary** section, it will look like ec2.xx-xxx-xxx-xxx.<region>.compute.amazonaws.com
1. Establish an SSH tunnel to port 8088, where Resource Manager is bound, by executing the below command on your Cloud9 environment (update the command with your master node DNS name): 

    ```
    ssh -i ~/environment/emr-workshop-key-pair.pem -N -L 8080:ec2-###-##-##-###.compute-1.amazonaws.com:8088 hadoop@ec2-###-##-##-###.compute-1.amazonaws.com
    ```

    You'll get a message saying the authenticity of the host can't be established. Type 'yes' and hit enter. The message will look similar to the following:

    ```
    The authenticity of host 'ec2-54-195-131-148.eu-west-1.compute.amazonaws.com (172.31.36.62)' can't be established.
    ECDSA key fingerprint is SHA256:Cmv0qkh+e4nm5qir6a9fPN5DlgTUEaCGBN42txhShoI.
    ECDSA key fingerprint is MD5:ee:63:d0:4a:a2:29:8a:c9:41:1b:a1:f0:f6:8e:68:4a.
    Are you sure you want to continue connecting (yes/no)? 
    ```
    
1. Now, on your Cloud9 environment, click on the **Preview** menu on the top and then click on **Preview Running Application**.
![Cloud9-preview-application](/images/running-emr-spark-apps-on-spot/cloud9-preview-application.png)

1. You'll see a browser window opening with in the Cloud9 environment with a **refused connection error** page. Click on the button next to **Browser** (arrow inside a box) to open web UI in a dedicated browser page.
![Cloud9-resource-manager-pop-out](/images/running-emr-spark-apps-on-spot/cloud9-resource-manager-pop-out.png)

1. On the left pane, click on **Nodes**:

* If the Spark App is **Running**, then in the **Cluster Metrics** table the **Containers Running** will be  **18**. In **Cluster Nodes Metrics** table, the number of **Active Nodes** will be **17** (1 core node with CORE Label and 16 task nodes without any Node Label). 

* If the Spark App is **Completed**, then **Containers Running** will be 0, **Active Nodes** will be  **1** (1 core node with CORE Label) and 16 **Decommissioned Nodes** (16 task nodes will be decommissioned by EMR managed cluster scaling).

![Cloud9-Resource-Manager](/images/running-emr-spark-apps-on-spot/cloud9-resource-manager-browser.png)

### Challenge 

Now that you are familiar with EMR web interfaces, can you try to access **Ganglia** and **Spark History Server** application user interfaces?

{{% notice tip %}}
Go to **Application user interfaces** tab to see the user interfaces URLs for  **Ganglia** and **Spark History Server**.
{{% /notice %}}

{{% expand "Show answers" %}}


#### Access Ganglia user interface

1. Go to the Cloud9 terminal where you have established the ssh tunnel, and press ctrl+c to close the tunnel used by the previous web UI. 
1. Establish an SSH tunnel to port 80, where Ganglia is bound, by executing the below command on your Cloud9 environment (update the command with your master node DNS name): 

    ```
    ssh -i ~/environment/emr-workshop-key-pair.pem -N -L 8080:ec2-###-##-##-###.compute-1.amazonaws.com:80 hadoop@ec2-###-##-##-###.compute-1.amazonaws.com
    ```

1. Now, go back to the browser where Resource Manager was running, and append /ganglia/ to the URL access the Ganglia Interface The URL should look like: https://xxxxxx.vfs.cloud9.eu-west-1.amazonaws.com/ganglia/


1. Take notice of the heatmap (**Server Load Distribution**). Notable graphs are:  

    * **Cluster CPU last hour** - this will show you the CPU utilization that our Spark application consumed on our EMR cluster. you should see that utilization varied and reached around 70%.  
    * **Cluster Memory last hour** - this will show you how much memory we started the cluster with, and how much Spark actually consumed.  
![Cloud9-Ganglia-Browser](/images/running-emr-spark-apps-on-spot/cloud9-ganglia-browser.png)
    

#### Access Spark History Server application user interface

1. Go to the Cloud9 terminal where you have established the ssh tunnel, and press ctrl+c to close the tunnel used by the previous web UI. 
1. Establish an SSH tunnel to port 18080, where Spark History Server is bound, by executing the below command on your Cloud9 environment (update the command with your master node DNS name): 


    ```
    ssh -i ~/environment/emr-workshop-key-pair.pem -N -L 8080:ec2-###-##-##-###.compute-1.amazonaws.com:18080 hadoop@ec2-###-##-##-###.compute-1.amazonaws.com
    ```

1. Now, on your browser, go to the base URL of your Cloud9 preview application i.e. https://xxxxxx.vfs.cloud9.eu-west-1.amazonaws.com/
1. Click on the App ID in the table (where App Name = Amazon reviews word count) and go to the **Executors** tab  
1. You can again see the number of executors that are running in your EMR cluster under the **Executors table**
    ![Cloud9-Spark-History-Server](/images/running-emr-spark-apps-on-spot/cloud9-spark-history-server.png)

{{% /expand %}}

### Using CloudWatch Metrics

EMR emits several useful metrics to CloudWatch metrics. You can use the AWS Management Console to look at the metrics in two ways:  

1. In the EMR console, under the **Monitoring** tab in your cluster's page  
1. By browsing to the CloudWatch service, and under Metrics, searching for the name of your cluster (copy it from the EMR Management Console) and clicking **EMR > Job Flow Metrics**

{{% notice note %}}
The metrics will take a few minutes to populate.
{{% /notice %}}

Some notable metrics:

* **AppsRunning** - you should see 1 since we only submitted one step to the cluster.  
* **ContainerAllocated** - this represents the number of containers that are running on core and task fleets. These would the be Spark executors and the Spark Driver.   
* **Memory allocated MB** & **Memory available MB** - you can graph them both to see how much memory the cluster is actually consuming for the wordcount Spark application out of the memory that the instances have.  

### Managed Scaling in Action

You enabled managed cluster scaling and EMR scaled out to 64 Spot units in the task fleet. EMR could have launched either 16 * xlarge (running one executor per xlarge) or 8 * 2xlarge instances (running 2 executors per 2xlarge) or 4 * 4xlarge instances (running 4 executors pe r4xlarge), so the task fleet provides 16 executors / containers to the cluster. The core fleet launched one xlarge instance and it will run one executor / container, so in total 17 executors / containers will be running in the cluster.


1. In your EMR cluster page, in the AWS Management Console, go to the **Steps** tab.
1. Go to the **Events** tab to see the scaling events.
![scalingEvent](/images/running-emr-spark-apps-on-spot/emrsparkscalingevent.png)

EMR Managed cluster scaling constantly monitors [key metrics](https://docs.aws.amazon.com/emr/latest/ManagementGuide/managed-scaling-metrics.html) and automatically increases or decreases the number of instances or units in your cluster based on workload.

{{%expand "Question: Did you see more than 17 containers in CloudWatch Metrics and in YARN ResourceManager? if so, do you know why? Click to expand the answer" %}}
Your Spark application was configured to run in Cluster mode, meaning that the **Spark driver is running on the Core node**. Since it is counted as a container, this adds a container to our count, but it is not an executor.
{{% /expand%}}