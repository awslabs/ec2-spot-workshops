+++
title = "Clean Up"
weight = 50
+++

Hopefully you've enjoyed the workshop and learned a few new things. Now follow these steps to make sure everything is cleaned up.

1. In the EC2 Console > Spot Requests, click **Cancel Spot request** under **Actions**. Make sure **Terminate instances** is checked.

2. In the SQS Console, delete the queue that you created earlier. This is located under **Queue Actions**.

3. In the S3 Console, locate the resultsBucket that was created for your workshop. Click on the bucket and select **Empty bucket**. You will need to copy and paste the bucket name in to confirm the action. 

4. Under AWS Batch, click on your running job and click **Terminate job**. Under **Job definitions**, click on your job definition and select **deregister**. Go to **Job queues**, then disable, and delete the configured job queue.

5. In the CloudFormation template, select the workshop stack and select **Actions** and then **Delete stack**.

{{% notice warning %}}
The estimated cost for running this 2.5 hour workshop will be less than $5.
{{% /notice %}}
