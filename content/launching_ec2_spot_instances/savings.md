+++
title = "Savings Summary"
weight = 80
+++

## Spot Savings

So far we have launched Spot instances in a few ways. Here is a question: How much do you think we saved on these workloads?

You can check how much you have saved with Spot instances by going to the Savings Summary panel. To view your savings do the following:

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. In the top right corner of the screen, select **Savings summary**

![Savings summary](/images/launching_ec2_spot_instances/savings.png)

## Spot price history & Spot notifications

There are more APIs that you can use to learn more about Spot.

Some projects, like [the EC2 Spot Interruption Dashboard](https://github.com/aws-samples/ec2-spot-interruption-dashboard) can be used as the initial point to understand which Spot Instances are being terminated and adjust your configuration by increasing diversification.

Some other APIs might be useful to understand how the Spot price changes over time, which you can also see in the AWS Console by:

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. Choose **Pricing history** in the top right corner.


If you are interested in how to use the Spot API programmatically, You can use the **[describe-spot-price-history](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-spot-price-history.html)** API to retrieve the information that you need.
