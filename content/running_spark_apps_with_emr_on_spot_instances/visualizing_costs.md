---
title: "Visualizing costs"
weight: 130
---

In this section we will use AWS Cost explorer to look at the costs of our EMR cluster, including the underlying EC2 Spot Instances.
{{% notice note %}}
It will take 24-48 hours for your usage to appear in Cost Explorer, so you can plan to come back to this step later to check the costs of running the workshop. If your organization administrator has not granted you access to Billing information, then you will not be able to access Cost Explorer, but you can look at the examples provided below.
{{% /notice %}}

In Step 4 of the EMR cluster launch, we tagged the cluster with the following Tag: Key=Name, Value=EMRTransientCluster1. These tags can be used to identify resources in your AWS accounts, and can also be used to identify the costs associated with usage in case the tag Key has been enabled as a Cost Allocation Tag. [Click here] (https://aws.amazon.com/answers/account-management/aws-tagging-strategies/) to learn more about tagging in AWS.


### Analyzing costs with AWS Cost Explorer
[AWS Cost Explorer] (https://aws.amazon.com/aws-cost-management/aws-cost-explorer/) has an easy-to-use interface that lets you visualize, understand, and manage your AWS costs and usage over time. Get started quickly by creating custom reports (including charts and tabular data) that analyze cost and usage data, both at a high level (e.g., total costs and usage across all accounts) and for highly-specific requests (e.g., m2.2xlarge costs within account Y that are tagged “project: secretProject”). Using AWS Cost Explorer, you can dive deeper into your cost and usage data to identify trends, pinpoint cost drivers, and detect anomalies.

Let's use Cost Explorer to analyze the costs of running our EMR application.\
1. Navigate to Cost Explorer by opening the AWS Management Console -> Click your username in the top right corner -> click **My Billing Dashboard** -> click **Cost Explorer in the left pane**. or [click here] (https://console.aws.amazon.com/billing/home#/costexplorer) for a direct link.\
2. We know that we gave our EMR cluster a unique Name tag, so let's filter according to it. In the right pane, click Tags -> Name -> enter "**MyWorkshopEMRTransientCluster1**"
3. To 
