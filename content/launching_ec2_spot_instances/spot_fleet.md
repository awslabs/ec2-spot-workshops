+++
title = "Spot instances via EC2 Spot Fleet"
weight = 40
+++

## Launching EC2 Spot Instances via a Spot Fleet request

You can create a Spot Fleet request and specify a launch template in the
instance configuration. When Amazon EC2 fulfills the Spot Fleet request,
it uses the launch parameters defined in the associated launch template.

**To create a Spot Fleet request using the recommended settings**

1. Open the Spot console at <https://console.aws.amazon.com/ec2spot>.

1. If you are new to Spot, you see a welcome page; choose **Get started**. 
Otherwise, choose **Request Spot Instances**.

1. For **Tell us your application or task need**, choose **Flexible workloads**.

1. Under **Configure your instances:**
    - For **Launch template**, select the Launch template you created earlier.
    - Leave the **Minimum compute** unit values as default.
    - For **Network**, select the VPC in which the subnet used in the launch template belongs.
    - Under **Availability Zone**, check all of the availability zones that have an available subnet.

1. Under **Tell us how much capacity you need**, for **Total target capacity**, 
specify **6 vCPUs**, and for **Optional On-Demand
    portion**, specify **2 vCPUs**.

1. Check the box for **Maintain target capacity**. Leave the **Interruption behavior** as **Terminate**.

1. Review the recommended **Fleet request settings** based on your application or task selection, 
and choose **Launch**.

The request type is fleet. When the request is fulfilled, requests of
type instance are added, where the state is active and the status
is fulfilled.

![Spot Fleet Request](/images/launching_ec2_spot_instances/spot_fleet_request_image_2.png)


## Monitoring Your Spot Fleet

The Spot Fleet launches Spot Instances when your maximum price exceeds
the Spot price and capacity is available. The Spot Instances run until
they are interrupted or you terminate them.

**To monitor your Spot Fleet using the console**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
1. In the navigation pane, choose **Spot Requests**.
1. Select your Spot Fleet request. The configuration details are
available in the **Description** tab.
1. To list the Spot Instances for the Spot Fleet, choose the **Instances** tab.
1.  To view the history for the Spot Fleet, choose the **History** tab.