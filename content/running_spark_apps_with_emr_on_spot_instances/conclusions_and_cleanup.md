---
title: "Conclusions and cleanup"
weight: 150
---

**Congratulations!** you have reached the end of the workshop. In this workshop, you learned about the need to be flexible with EC2 instance types when using Spot Instances, and how to size your Spark executors to allow for this flexibility. You ran a Spark application solely on Spot Instances using EMR Instance Fleets, you verified the results of the application, and saw the cost savings that you achieved by running the application on Spot Instances.

#### Cleanup

1. Our EMR cluster has already been terminated after the Spark application we submitted finished running. Just to be on the safe side, you can visit the EMR console and check that the cluster is in the **Terminated** state.
2. Delete the VPC you deployed via CloudFormation, by going to the CloudFormation service in the AWS Management Console, selecting the VPC stack (default name is Quick-Start-VPC) and click the Delete option. Make sure that the deletion has completed successfully (this should take around 1 minute), the status of the stack will be DELETE_COMPLETE (the stack will move to the Deleted list of stacks).
3. Delete your S3 bucket from the AWS Management Console - choose the bucket from the list of buckets and hit the Delete button. This approach will also empty the bucket and delete all existing objects in the bucket.
4. Delete the Athena table by going to the Athena service in the AWS Management Console, find the **emrworkshopresults** Athena table, click the three dots icon next to the table and select **Delete table**.

#### Thank you

We hope this workshop was educational, and that it will help you adopt Spot Instances into your Spark applications running on Amazon EMR in order to optimize your costs.\
If you have any feedback or questions, click the "**Feedback / Questions?**" link in the left pane to reach out to the authors of the workshop.