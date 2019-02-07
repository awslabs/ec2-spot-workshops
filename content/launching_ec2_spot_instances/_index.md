---
title: "Launching EC2 Spot Instances"
date: 2019-01-31T08:51:33Z
draft: true
---

# Overview

Amazon EC2 Spot instances are spare compute capacity in the AWS Cloud
available to you at steep discounts compared to On-Demand prices. EC2
Spot enables you to optimize your costs on the AWS cloud and scale your
application’s throughput up to 10X for the same budget.

This lab will walk you through creating an EC2 Launch Template, and then
using this Launch Template to launch EC2 Spot Instances the following 3
ways: the EC2 RunInstances API, EC2 Spot Fleet, and Amazon EC2 Auto
Scaling.

# Pre-Requisites

This lab requires:

  - A laptop with Wi-Fi running Microsoft Windows, Mac OS X, or Linux.

  - The AWS CLI installed and configured.

  - An Internet browser such as Chrome, Firefox, Safari, or Edge.

  - An AWS account. You will create AWS resources including IAM roles
    during the workshop.

# Creating a Launch Template 

You can create a *launch template* that contains the configuration
information to launch an instance. Launch templates enable you to store
launch parameters so that you do not have to specify them every time you
launch an instance. For example, a launch template can contain the AMI
ID, instance type, and network settings that you typically use to launch
instances. When you launch an instance using the Amazon EC2 console, an
AWS SDK, or a command line tool, you can specify the launch template to
use.

**To create a new launch template using the command line**

1.  You'll need to gather the following data
    
    1.  **AMI ID**: Specify an AMI ID from which to launch the instance.
        You can use an AMI that you own, or you can [find a suitable
        AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html).
    
    2.  **Instance type**: Choose the instance type. Ensure that the
        instance type is compatible with the AMI you've specified. For
        more information, see [Instance
        Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html).
    
    3.  **Subnet**: Specify the subnet in which to create a new network
        interface. For the primary network interface (eth0), this is the
        subnet in which the instance is launched.

2.  **Once you've gathered the data, create the launch template from the
    command line as follows (be sure to change the values in *bold
    italics*):**

$ aws ec2 create-launch-template --launch-template-name TemplateForSpot
--version-description TemplateForSpotVersion1 --launch-template-data
"{\\"NetworkInterfaces\\":\[{\\"DeviceIndex\\":0,\\"SubnetId\\":\\"***subnet-05ef7d72***\\"}\],\\"ImageId\\":\\"***ami-97785bed***\\",\\"InstanceType\\":\\"***c4.large***\\",\\"TagSpecifications\\":\[{\\"ResourceType\\":\\"instance\\",\\"Tags\\":\[{\\"Key\\":\\"Name\\",\\"Value\\":\\"***EC2SpotImmersionDay***\\"}\]}\]}"

**Example return**

{

"LaunchTemplate": {

"LaunchTemplateId": "lt-072835f1531b31e88",

"LaunchTemplateName": "TemplateForSpot",

"CreateTime": "2018-05-01T08:03:31.000Z",

"CreatedBy": "arn:aws:iam::123456789012:user/schmutze",

"DefaultVersionNumber": 1,

"LatestVersionNumber": 1

}

}

3.  Note the **LaunchTemplateId** (eg. "lt-0abcd290751193123") or
    **LaunchTemplateName** (eg. "TemplateForSpot") of the newly created
    Launch Template for the next steps.

# Launching an EC2 Spot Instance via the RunInstances API

To launch an EC2 Spot Instance from a launch template using the command
line, use the run-instances AWS CLI command and specify the
*--launch-template* parameter as well as the *--instance-market-options*
parameter.

$ aws ec2 run-instances --launch-template
LaunchTemplateName=TemplateForSpot,Version=1 --instance-market-options
MarketType=spot

That is all there is to it\! You can see your Spot Instance request in
the Spot console at <https://console.aws.amazon.com/ec2spot>.

![](media/image2.jpg)

# Launching EC2 Spot Instances via a Spot Fleet request

You can create a Spot Fleet request and specify a launch template in the
instance configuration. When Amazon EC2 fulfills the Spot Fleet request,
it uses the launch parameters defined in the associated launch template.

**To create a Spot Fleet request using the recommended settings**

1.  Open the Spot console at <https://console.aws.amazon.com/ec2spot>.

2.  If you are new to Spot, you see a welcome page; choose **Get
    started**. Otherwise, choose **Request Spot Instances**.

3.  For **Tell us your application or task need**, choose **Flexible
    workloads**.

4.  Under **Configure your instances:**
    
      - For **Launch template**, select the Launch template you created
        earlier.
    
      - Leave the **Minimum compute** unit values as default.
    
      - For **Network**, select the VPC in which the subnet used in the
        launch template belongs.
    
      - Under **Availability Zone**, check all of the availability zones
        that have an available subnet.

5.  Under **Tell us how much capacity you need**, for **Total target
    capacity**, specify **6 vCPUs**, and for **Optional On-Demand
    portion**, specify **2 vCPUs**.

6.  Check the box for **Maintain target capacity**. Leave the
    **Interruption behavior** as **Terminate**.

7.  Review the recommended **Fleet request settings** based on your
    application or task selection, and choose **Launch**.

The request type is fleet. When the request is fulfilled, requests of
type instance are added, where the state is active and the status
is fulfilled.

![](media/image3.jpg)

# Monitoring Your Spot Fleet

The Spot Fleet launches Spot Instances when your maximum price exceeds
the Spot price and capacity is available. The Spot Instances run until
they are interrupted or you terminate them.

**To monitor your Spot Fleet using the console**

1.  Open the Amazon EC2 console at
    <https://console.aws.amazon.com/ec2/>.

2.  In the navigation pane, choose **Spot Requests**.

3.  Select your Spot Fleet request. The configuration details are
    available in the **Description** tab.

4.  To list the Spot Instances for the Spot Fleet, choose the
    **Instances** tab.

5.  To view the history for the Spot Fleet, choose the **History** tab.

# Launching EC2 Spot Instances with On-Demand Instances via an EC2 Fleet

An *EC2 Fleet* contains the configuration information to launch a
fleet—or group—of instances. In a single API call, a fleet can launch
multiple instance types across multiple Availability Zones, using the
On-Demand Instance, Reserved Instance, and Spot Instance purchasing
models together. Using EC2 Fleet, you can define separate On-Demand and
Spot capacity targets, specify the instance types that work best for
your applications, and specify how Amazon EC2 should distribute your
fleet capacity within each purchasing model.

**To create a new EC2 Fleet using the command line, run the following**

$ aws ec2 create-fleet --launch-template-configs
LaunchTemplateSpecification="{LaunchTemplateName=TemplateForSpot,Version=1}"
--target-capacity-specification
TotalTargetCapacity=4,OnDemandTargetCapacity=1,DefaultTargetCapacityType=spot

**Example return**

{

"FleetId": "fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183"

}

This EC2 Fleet has requested a total capacity of 4 instances- 1
On-Demand and 3 Spot.

**Check them out by running**

$ aws ec2 describe-fleets --fleet-ids
fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183

and

$ aws ec2 describe-fleet-instances --fleet-id
fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183

# Launching EC2 Spot Instances via an EC2 Auto Scaling Group

When you create an Auto Scaling group, you must specify the information
needed to configure the Auto Scaling instances and the minimum number of
instances your group must maintain at all times.

To configure Auto Scaling instances, you must specify a launch template,
a launch configuration, or an EC2 instance. We recommend that you use a
launch template to ensure that you can use the latest features of Amazon
EC2.

In order to configure Auto Scaling to use EC2 Spot Instances, you'll
need to create a new version of the launch template to add the
*InstanceMarketOptions* setting.

**To create a new version of the launch template, run**

$ aws ec2 create-launch-template-version --launch-template-name
TemplateForSpot --version-description TemplateForSpotVersion2
--source-version 1 --launch-template-data
"{\\"InstanceMarketOptions\\":{\\"MarketType\\":\\"spot\\"}}"

**Example output**

{

"LaunchTemplateVersion": {

"LaunchTemplateId": "lt-0243ab7ff9821424b",

"LaunchTemplateName": "TemplateForSpot",

"VersionNumber": 2,

"VersionDescription": "TemplateForSpotVersion2",

"CreateTime": "2018-06-26T05:53:19.000Z",

"CreatedBy": "arn:aws:iam::123456789012:user/schmutze",

"DefaultVersion": false,

"LaunchTemplateData": {

"NetworkInterfaces": \[

{

"DeviceIndex": 0,

"SubnetId": "subnet-05ef7d72"

}

\],

"ImageId": "ami-97785bed",

"InstanceType": "c4.large",

"TagSpecifications": \[

{

"ResourceType": "instance",

"Tags": \[

{

"Key": "Name",

"Value": "EC2SpotImmersionDay"

}

\]

}

\],

"InstanceMarketOptions": {

"MarketType": "spot"

}

}

}

}

**To create an Auto Scaling group using a launch template**

1.  Open the Amazon EC2 console
    at <https://console.aws.amazon.com/ec2/>.

2.  On the navigation bar at the top of the screen, select the same
    region that you used when you created the launch template.

3.  In the navigation pane, choose **Launch Templates**.

4.  Select the launch template and choose **Actions**, **Create Auto
    Scaling group**.

5.  On the **Configure Auto Scaling group details** page, do the
    following:
    
    1.  For **Group name**, type a name for your Auto Scaling group.
    
    2.  For **Launch template version**, choose the version you just
        made that includes the *InstanceMarketOptions* configured (this
        should be 2).
    
    3.  For **Fleet Composition**, select **Adhere to the launch
        template**.
    
    4.  For **Group size**, type 1.
    
    5.  For **Network**, choose the VPC in which the subnet used in the
        launch template belongs.
    
    6.  For **Subnet**, choose the subnet used in the launch template.
    
    7.  Leave the **Advanced Details** set to default settings.
    
    8.  Choose **Next: Configure scaling policies**.

6.  On the **Configure scaling policies** page, select **Keep this group
    at its initial size**, and then choose **Review**.

<!-- end list -->

1.  On the **Review** page, choose **Create Auto Scaling group**.

2.  On the **Auto Scaling group creation status** page,
    choose **Close**.

You have now created an Auto Scaling group configured to launch EC2 Spot
Instances.

# Finding Running Spot Instances

A Spot Instance runs until it is interrupted or you terminate it
yourself.

Now that we've launched Spot Instances via RunInstances, Spot Fleet, EC2
Fleet, and an Auto Scaling group, let's go check them out.

**To find running Spot Instances using the console**

1.  Open the Amazon EC2 console at
    <https://console.aws.amazon.com/ec2/>.

2.  In the navigation pane, choose **Spot Requests**.

3.  You can see both Spot Instance requests and Spot Fleet requests. If
    a Spot Instance request has been fulfilled, **Capacity** is the ID
    of the Spot Instance. For a Spot Fleet, **Capacity** indicates how
    much of the requested capacity has been fulfilled. To view the IDs
    of the instances in a Spot Fleet, choose the expand arrow, or select
    the fleet and then select the **Instances** tab.

4.  Alternatively, in the navigation pane, choose **Instances**. In the
    top right corner, choose the **Show/Hide** icon, and then select
    **Lifecycle**. For each instance, **Lifecycle** is either *normal*,
    *spot*, or *scheduled*.

# Cleanup

## Delete Your Auto Scaling Group

**To delete your Auto Scaling group using the console**

1.  Open the Amazon EC2 console
    at <https://console.aws.amazon.com/ec2/>.

2.  On the navigation pane, under **Auto Scaling**, choose **Auto
    Scaling Groups**.

3.  On the Auto Scaling groups page, select your Auto Scaling group. and
    choose **Actions**, **Delete**.

4.  When prompted for confirmation, choose **Yes, Delete**.

## Delete your EC2 Fleet

When you are finished using your EC2 Fleet, you can delete the EC2 Fleet
and terminate all of the running instances.

**To delete your EC2 Fleet and terminate the running instances**

$ aws ec2 delete-fleets --fleet-ids
fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183 --terminate-instances

## Canceling your Spot Fleet Request

When you are finished using your Spot Fleet, you can cancel the Spot
Fleet request. This cancels all Spot requests associated with the Spot
Fleet, so that no new Spot Instances are launched for your Spot Fleet.
You must specify whether the Spot Fleet should terminate its Spot
Instances. If you terminate the instances, the Spot Fleet request enters
the cancelled\_terminating state. Otherwise, the Spot Fleet request
enters the cancelled\_running state and the instances continue to run
until they are interrupted or you terminate them manually.

**To cancel a Spot Fleet request using the console**

1.  Open the Spot console
    at <https://console.aws.amazon.com/ec2spot/home/fleet>.

2.  Select your Spot Fleet request.

3.  Choose **Actions**, and then choose **Cancel spot request**.

4.  In **Cancel spot request**, choose **Confirm**.

## Terminating a Spot Instance

**To terminate a Spot Instance using the console**

1.  Open the Amazon EC2 console
    at <https://console.aws.amazon.com/ec2/>.

2.  In the navigation pane, choose **Instances**.

3.  Select the instance, and choose **Actions**, **Instance
    State**, **Terminate**.

4.  Choose **Yes, Terminate** when prompted for confirmation.

## Deleting a Launch Template

If you no longer require a launch template, you can delete it. Deleting
a launch template deletes all of its versions.

**To delete a launch template**

1.  Open the Amazon EC2 console
    at <https://console.aws.amazon.com/ec2/>.

2.  In the navigation pane, choose **Launch Templates** and select the
    launch template.

3.  Choose **Actions**, **Delete template**.

4.  Choose **Delete launch template**.
