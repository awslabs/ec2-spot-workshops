---
title: "Launch a cluster - Steps 3&4"
weight: 80
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}


### Step 3: General Cluster Settings

For the **Cluster name** field, use `emr-spot-workshop` as there are subsequent commands in the workshop that use this name for the cluster.

Under "**Tags**", tag your instance with a recognizable `Name` tag so that you'll be able to see it later in the cost reports. 

For this workshop, use the following values:  
* Key=Name  
* Value (optional)=`emr-spot-workshop`

![tags](/images/running-emr-spark-apps-on-spot/emrtags.png)

Click **Next** to go to **Step 4: Security**. 

### Step 4: Security

On the **EC2 key pair** drop-down, select `emr-workshop-key-pair`.
![key_pair](/images/running-emr-spark-apps-on-spot/keypair.png)

 {{% notice note %}} 
 The key par was created when the Cloud9 environment was launched through CloudFormation.
 {{% /notice %}}

Leave all the other settings as-is and click "**Create cluster**"