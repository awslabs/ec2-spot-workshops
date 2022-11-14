---
title: "Launch a cluster - Steps 3&4"
weight: 80
---

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