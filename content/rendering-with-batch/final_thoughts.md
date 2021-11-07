---
title: "Final Thoughts"
date: 2021-09-06T08:51:33Z
weight: 160
---

**Congratulations!** You have successfully completed the workshop. Today you have:

1. Learned about AWS Batch, its use cases and components.
2. Seen how easy it is to adopt Spot best practices when using AWS Batch, by defining several compute environments with the appropriate allocation strategies.
3. Learned the different types of jobs you find in AWS Batch (array and single). Also, you have learned how to define dependencies between them and how to work with the AWS_BATCH_JOB_ARRAY_INDEX environment variable.
4. You learned the concepts required to create a rendering pipeline using Blender and ffmpeg.
5. Built and published in ECR a Docker image that runs Blender and ffmpeg.


## Savings

You can check how much you have saved with Spot instances by going to the Savings Summary panel. To view your savings do the following:

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. In the top right corner of the screen, select **Savings summary**

![Savings with Spot](/images/rendering-with-batch/savings.png)
