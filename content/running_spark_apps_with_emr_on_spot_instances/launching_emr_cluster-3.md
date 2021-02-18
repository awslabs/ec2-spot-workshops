---
title: "Launch a cluster - Steps 3&4"
weight: 80
---

Under "**Tags**", tag your instance with a recognizable Name tag so that you'll be able to see it later in the cost reports. For example:  
Key=Name  
Value (Optional)=EMRTransientCluster1  
![tags](/images/running-emr-spark-apps-on-spot/emrtags.png)

Click **Next** to go to **Step 4: Security**. On the **EC2 key pair** drop-down, select *emr-workshop-key-pair*.
![key_pair](/images/running-emr-spark-apps-on-spot/keypair.png)

Leave all the other settings as-is and click "**Create cluster**"