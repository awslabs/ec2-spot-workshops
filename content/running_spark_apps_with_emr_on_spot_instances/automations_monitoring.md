---
title: "Automations and monitoring"
weight: 110
---

When adopting EMR into your analytics flows and data processing pipelines, you will want to launch EMR clusters and run jobs in a programmatic manner. There are many ways to do so with AWS SDKs that can run in different environments like Lambda Functions, invoked by AWS Data Pipeline or AWS Step Functions, with third party tools like Apache Airflow, and more.

#### (Optional) Examine the JSON configuration for EMR Instance Fleets
In this section we will simply look at a CLI command that can be used to start an identical cluster to the one we started from the console. This makes it easy to configure your EMR clusters with the AWS Management Console and get a CLI runnable command with one click.

1. In the AWS Management Console, under the EMR service, go to your cluster, and click the **AWS CLI export** button.
2. Find the --instance-fleets parameter, and copy the contents of the parameter including the brackets:
![cliexport](/images/running-emr-spark-apps-on-spot/cliexport.png)
3. Paste the data into a JSON validator like [JSON Lint] (https://jsonlint.com/) and validate the JSON file. this will make it easy to see the Instance Fleets configuration we configured in the console, in a JSON format, that can be re-used when you launch your cluster programmatically. 

#### (Optional) Set up CloudWatch Events for Cluster and/or Step failures
Much like we set up a CloudWatch Event rule for EC2 Spot Interruptions to be sent to our email via an SNS notification, we can also set up rules to send out notifications or perform automations when an EMR cluster fails to start, or a Task on the cluster fails. This is useful for monitoring purposes.

In this example, let's set up a notification for when our EMR step failed.  
1. In the AWS Management Console, go to Cloudwatch -> Events -> Rules and click **Create Rule**.  
2. Under Service Name select EMR, and under Event Type select **State Change**.  
3. Check **Specific detail type(s)** and from the dropdown menu, select **EMR Step Status Change**  
4. Check **Specific states(s)** and from the dropdown menu, select **FAILED**.  
![cwemrstep](/images/running-emr-spark-apps-on-spot/emrstatechangecwevent.png)
5. In the targets menu, click **Add target**, select **SNS topic** and from the dropdown menu, select the SNS topic you created and click **Configure details**.  
6. Provide a name for the rule and click **Create rule**.  
7. You can test that the rule works by following the same steps to start a cluster, but providing a bad parameter when submitting the step, for example - a non existing location for the Spark application or results bucket.