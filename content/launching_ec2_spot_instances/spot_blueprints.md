+++
title = "Spot Blueprints"
weight = 130
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Launching EC2 Spot Instances](https://catalog.us-east-1.prod.workshops.aws/workshops/36a2c2bb-b92d-4428-8626-3a75df01efcc/en-US)**.

{{% /notice %}}


Spot Blueprints is a functionality provided within the AWS Web Console, in the Spot Request section, that helps to create a few architectures that are most common for Spot, using Infrastructure as code and adhering to Spot Best practices. There are Spot Blueprints for the most popular services including Amazon EC2 Auto Scaling, Amazon EMR, AWS Batch, and Amazon Elastic Kubernetes Service (Amazon EKS).

Spot Blueprints gives you a jump start in using Spot architectures by providing a simple-to-follow infrastructure code template generator that is designed to gather your workload requirements while explaining and configuring Spot best practices along the way. The output of the process is a Cloudformation or Terraform IaaC (Infrastructure as Code) file that you can use and adapt for your projects.

**Getting started with Spot Blueprints**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. Choose **Spot Blueprints** in the top right corner.

![Spot Blueprints](/images/launching_ec2_spot_instances/spot_blueprints.png)

You will see different categories to get you started. From there, you can either download a pre-configured blueprint in AWS CloudFormation or Terraform format, or choose to configure it.
You can learn more about Spot Blueprints by reading the [launch blog post](https://aws.amazon.com/blogs/compute/introducing-spot-blueprints-a-template-generator-for-frameworks-like-kubernetes-and-apache-spark/). If you don’t find a blueprint that you need, feel free to provide us feedback using the [Spot Blueprints Feedback link](https://console.aws.amazon.com/ec2sp/v2/home?region=us-east-1#/spot/blueprints?show_feedback=true).
