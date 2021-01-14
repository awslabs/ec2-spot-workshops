---
title: "event"
chapter: false
disableToc: true
hidden: true
---

1. In the EMR Management Console, check that the cluster is in the **Terminated** state. If it isn't, then you can terminate it from the console.
2. Go to the [Cloud9 Dashboard](https://console.aws.amazon.com/cloud9/home) and delete your environment.
3. Delete the VPC you deployed via CloudFormation, by going to the CloudFormation service in the AWS Management Console, selecting the VPC stack (default name is Quick-Start-VPC) and click the Delete option. Make sure that the deletion has completed successfully (this should take around 1 minute), the status of the stack will be DELETE_COMPLETE (the stack will move to the Deleted list of stacks).
4. Delete your S3 bucket from the AWS Management Console - choose the bucket from the list of buckets and hit the Delete button. This approach will also empty the bucket and delete all existing objects in the bucket.
5. Delete the Athena table by going to the Athena service in the AWS Management Console, find the **emrworkshopresults** Athena table, click the three dots icon next to the table and select **Delete table**.