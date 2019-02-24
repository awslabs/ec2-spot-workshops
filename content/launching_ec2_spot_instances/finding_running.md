+++
title = "Finding Running Spot Instances"
weight = 60
+++

## Finding Running Spot Instances

A Spot Instance runs until it is interrupted or you terminate it
yourself.

Now that we've launched Spot Instances via RunInstances, Spot Fleet, EC2
Fleet, and an Auto Scaling group, let's go check them out.

**To find running Spot Instances using the console**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
1. In the navigation pane, choose **Spot Requests**.
1. You can see both Spot Instance requests and Spot Fleet requests. If 
a Spot Instance request has been fulfilled, **Capacity** is the ID of 
the Spot Instance. For a Spot Fleet, **Capacity** indicates how much of the
requested capacity has been fulfilled. To view the IDs of the instances in 
a Spot Fleet, choose the expand arrow, or select the fleet and then select 
the **Instances** tab.
1. Alternatively, in the navigation pane, choose **Instances**. In the
    top right corner, choose the **Show/Hide** icon, and then select
    **Lifecycle**. For each instance, **Lifecycle** is either *normal*,
    *spot*, or *scheduled*.


