+++
title = "Savings Summary"
weight = 90
+++

## To view the savings summary of this workshop

You can check how much you have saved with Spot instances by going to the Savings Summary panel. To view your savings do the following:

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. In the navigation pane, choose **Spot Requests**.
3. In the top right corner of the screen, select **Savings summary**

![Savings summary](/images/launching_ec2_spot_instances/savings.png)

## Spot pricing

There are several resources that you can use to check the current Spot price and how it has fluctuated over time:

1. To view the current Spot instance prices, see [Amazon EC2 Spot Instances Pricing](https://aws.amazon.com/ec2/spot/pricing/).
2. To view the Spot price history:
  1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
  2. In the navigation pane, choose **Spot Requests**.
  3. Choose **Pricing history** in the top right corner.
3. You can use the *describe-spot-price-history* API to retrieve only the information that you need. More information on that here: [describe-spot-price-history](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-spot-price-history.html).
