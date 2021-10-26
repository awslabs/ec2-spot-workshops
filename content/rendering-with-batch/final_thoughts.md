---
title: "Final Thoughts"
date: 2021-09-06T08:51:33Z
weight: 150
---

**Congratulations!** You have successfully completed the workshop. Today you have:

1. Learned the principles of graphics rendering and what programs you can use to do it.
2. Built and published in ECR a Docker image that runs those programs.
3. Learned about AWS Batch, its use cases and components.
4. Learned the different types of jobs you find in AWS Batch (array and single). Also, you have learned how to define dependencies between them and how to work with the AWS_BATCH_JOB_ARRAY_INDEX environment variable.
5. Seen how to follow Spot best practices when working with Batch, by defining several compute environments with the appropriate allocation strategies for EC2 and Spot instances.

## Savings

You can check how much you have saved with Spot instances by going to the Savings Summary panel. To view your savings do the following:

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. In the top right corner of the screen, select **Savings summary**

![Savings with Spot](/images/rendering-with-batch/savings.png)
