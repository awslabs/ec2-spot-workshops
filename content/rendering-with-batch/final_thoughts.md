---
title: "Final Thoughts"
date: 2021-09-06T08:51:33Z
weight: 180
---

**Congratulations!** You have successfully completed the workshop. Today you have:

1. Learned about AWS Batch, its fault tolerance, use cases, and components.
2. Seen how easy it is to adopt Spot best practices when using AWS Batch, by defining several compute environments with the appropriate allocation strategies.
3. Simulated a Spot Instance interruption using AWS Fault Injection Simulator.
4. Learned the different types of jobs you find in AWS Batch (array and single). Also, you have learned how to define dependencies between them and how to work with the AWS_BATCH_JOB_ARRAY_INDEX environment variable.
5. Learned the concepts required to create a rendering pipeline using Blender and FFmpeg.
6. Used AWS Step Functions to orchestrate the workflow of the pipeline.
7. Built and published in ECR a Docker image that runs Blender and FFmpeg.


## Savings

You can check how much you have saved with Spot Instances by going to the Savings Summary panel. To view your savings do the following:

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. In the top right corner of the screen, select **Savings summary**

![Savings with Spot](/images/rendering-with-batch/savings.png)
