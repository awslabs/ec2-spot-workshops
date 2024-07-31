---
title: "Analyzing costs"
weight: 110
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}


In this section we will use AWS Cost explorer to look at the costs of our EMR cluster, including the underlying EC2 Spot Instances.

Select the correct tab, depending on where you are running the workshop:
{{< tabs name="EventorOwnAccount" >}}
    {{< tab name="In your own account" include="costs_ownaccount" />}}
    {{< tab name="In an AWS event" include="costs_event.md" />}}
{{< /tabs >}}

In Step 4 of the EMR cluster launch, we tagged the cluster with the following Tag: Key=**Name**, Value=**emr-spot-workshop**. This tag can be used to identify resources in your AWS account, and can also be used to identify the costs associated with usage in case the tag Key has been enabled as a Cost Allocation Tag. [Click here](https://aws.amazon.com/answers/account-management/aws-tagging-strategies/) to learn more about tagging in AWS.


### Analyzing costs with AWS Cost Explorer
[AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) has an easy-to-use interface that lets you visualize, understand, and manage your AWS costs and usage over time. You can analyze cost and usage data, both at a high level (e.g. how much did I pay for EMR) and for highly-specific requests (e.g. Cost for a specific instance type in a specific account with a specific tag). 

{{% notice note %}}
If the Name tag Key was not enabled as a Cost Allocation Tag, you will not be able to filter/group according to it in Cost Explorer, but you can still gather data like cost for the EMR service, instance types, etc.
{{% /notice %}}


Let's use Cost Explorer to analyze the costs of running our EMR application.  
1. Navigate to Cost Explorer by opening the AWS Management Console -> Click your username in the top right corner -> click **My Billing Dashboard** -> click **Cost Explorer in the left pane**. or [click here](https://console.aws.amazon.com/billing/home#/costexplorer) for a direct link.  
2. We know that we gave our EMR cluster a unique Name tag, so let's filter according to it. In the right pane, click Tags -> Name -> enter "**emr-spot-workshop**"  
3. Instead of the default 45 days view, let's narrow down the time span to just the day when we ran the cluster. In the data selection dropdown, mark that day as start and end.  
4. You are now looking at the total cost to run the cluster (**$0.30**), including: EMR, EC2, EBS, and possible AWS Cross-Region data transfer costs, depending on where you ran your cluster relative to where the S3 dataset is located (in N. Virginia).  
5. Group by **Usage Type** to get a breakdown of the costs

![costexplorer](/images/running-emr-spark-apps-on-spot/costexplorer1.png)

{{% notice note %}}
Above's screenshot references to a sample workload deployed at an European region. You'll get a similar graph regardless of the region.
{{% /notice %}}

* EU-SpotUsage:r5.xlarge: This was the instance type that ran in the EMR Task Instance fleet and accrued the largest cost, since EMR launched 10 instances ($0.17)  
* EU-BoxUsage:r5.xlarge: The EMR costs. [Click here](https://aws.amazon.com/emr/pricing/) to learn more about EMR pricing. ($0.06)  
* EU-EBS:VolumeUsage.gp2: EBS volumes that were attached to my EC2 Instances in the cluster - these got tagged automatically. ($0.03)  
* EU-SpotUsage:r5a.xlarge & EU-SpotUsage:m4.xlarge: EC2 Spot price for the other instances in my cluster (Master and Core) ($0.02 combined)  

If you have access to Cost Explorer, have a look around and see what you can find by slicing and dicing with filtering and grouping. For example, what happens if you filter by **Purchase Option = Spot** & **Group by = Instance Type**?

