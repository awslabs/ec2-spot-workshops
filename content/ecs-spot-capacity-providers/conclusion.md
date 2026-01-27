---
title: "Conclusion"
chapter: false
weight: 90
---

**Congratulations!** you have reached the end of the workshop. We covered a lot of ground learning how to apply EC2 Spot best practices such as diversification, as 
well as the use of capacity providers.

In the session, we have:

- Deployed a CloudFormation Stack that prepared our environment, including our VPC and a Cloud9 environment.
- Created and configured an ECS cluster from the scratch.
- Created Auto Scaling Groups and Capacity Providers associated with them for OnDemand and Spot instances, and applied EC2 Spot Diversification srategies. 
- Configured a Capacity provider strategy that mixes OnDemand and Spot
- Learned how ECS Cluster Scaling works with Capacity Providers
- Deployed Services both on Fargate Capacity Providers and EC2 Capacity providers

 
# EC2 Spot Savings 

There is one more thing that we've accomplished!

  * Log into the **[EC2 Spot Request](https://console.aws.amazon.com/ec2sp/v1/spot/home)** page in the Console.
  * Click on the **Savings Summary** button.

![EC2 Spot Savings](/images/spot_savings_summary.png)

{{% notice note %}}
We have achieved a significant cost saving over On-Demand prices that we can apply in a controlled way and at scale. We hope this savings will help you try new experiments or build other cool projects. **Now Go Build** !
{{% /notice %}}

[Watch: Workshop Conclusion Video](https://www.youtube.com/watch?v=3wGeqmSwz9k)