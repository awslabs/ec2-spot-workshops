---
title: "ownaccount"
chapter: false
disableToc: true
hidden: true
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Cost efficient Spark applications on Amazon EMR](https://catalog.us-east-1.prod.workshops.aws/workshops/aaa003a7-9c9e-46ad-af28-477b0d906f47/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}


1. Create an S3 bucket - we will use this for our Spark application code (which will be provided later) and the Spark application's results.  
Refer to the **Create a Bucket** page in the [Amazon S3 Getting Started Guide] (https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html)

2. Deploy a new VPC that will be used to run your EMR cluster in the workshop.  
a. Open the *["Modular and Scalable VPC Architecture Quick stage"](https://aws.amazon.com/quickstart/architecture/vpc/)* page and go to the **How to deploy** tab, click the *["Launch the Quick Start"](https://fwd.aws/mm853)* link.  
b. Select your desired region to run the workshop from the top right corner of the AWS Management Console and click **Next**.  
c. Provide a name for the stack or leave it as **Quick-Start-VPC**.  
d. Under **Availability Zones**, select three availability zones from the list, and set the **Number of Availability Zones** to **3**.  
e. Under **Create private subnets** select **false**.  
f. click **Next** and again **Next** in the next screen.  
g. Click **Create stack**.  
The stack creation should take under 2 minutes and the status of the stack will be **CREATE_COMPLETE**.