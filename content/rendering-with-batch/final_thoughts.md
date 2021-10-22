---
title: "Final Thoughts"
date: 2021-09-06T08:51:33Z
weight: 150
---

**Congratulations!** In this workshop you have learned the principles of graphics rendering and what programs you can use to do it. In addition, you have built step by step a Docker image that runs these programs.

Also, thanks to AWS Batch you have had a first contact with the execution of parallel jobs in a distributed environment. You have learned the different types of jobs (array and single) and how to establish dependencies between them.

Finally, you have seen the importance of choosing the right allocation strategy for both Spot and EC2, following the best practices such as instance diversification to minimise the probability of instance interruption.

## Savings

You can check how much you have saved with Spot instances by going to the Savings Summary panel. To view your savings do the following:

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. In the top right corner of the screen, select **Savings summary**

![Savings with Spot](/images/rendering-with-batch/savings.png)
