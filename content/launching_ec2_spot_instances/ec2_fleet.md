+++
title = "Launching EC2 Spot Instances via an EC2 Fleet"
weight = 80
+++

## Launching EC2 Spot Instances with On-Demand Instances via an EC2 Fleet

An *EC2 Fleet* contains the configuration information to launch a
fleet—or group—of instances. In a single API call, a fleet can launch
multiple instance types across multiple Availability Zones, using the
On-Demand Instance, Reserved Instance, and Spot Instance purchasing
models together. Using EC2 Fleet, you can define separate On-Demand and
Spot capacity targets, specify the instance types that work best for
your applications, and specify how Amazon EC2 should distribute your
fleet capacity within each purchasing model.

**To create a new EC2 Fleet using the command line, run the following**

```bash
$ aws ec2 create-fleet --launch-template-configs LaunchTemplateSpecification="{LaunchTemplateName=TemplateForSpot,Version=1}" --target-capacity-specification TotalTargetCapacity=4,OnDemandTargetCapacity=1,DefaultTargetCapacityType=spot
```

**Example return**

```bash
{
"FleetId": "fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183"
}
```

This EC2 Fleet has requested a total capacity of 4 instances- 1 On-Demand and 3 Spot.

**Check them out by running**

```bash
$ aws ec2 describe-fleets --fleet-ids fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183
```


and

```
$ aws ec2 describe-fleet-instances --fleet-id fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183
```

<!--
## Launching EC2 Spot Instances via an EC2 Auto Scaling Group

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

```bash
$ aws ec2 create-launch-template-version --launch-template-name TemplateForSpot --version-description TemplateForSpotVersion2 --source-version 1 --launch-template-data "{\\"InstanceMarketOptions\\": \\"MarketType\\":\\"spot\\"}}"
```

**Example output**

```bash
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
            "NetworkInterfaces": [
                {
                    "DeviceIndex": 0,
                    "SubnetId": "subnet-05ef7d72"
                }
            ],
            "ImageId": "ami-97785bed",
            "InstanceType": "c4.large",
            "TagSpecifications": [
                {
                    "ResourceType": "instance",
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "EC2SpotImmersionDay"
                        }
                    ]
                }
            ],
            "InstanceMarketOptions": {
                "MarketType": "spot"
            }
        }
    }
}
```

**To create an Auto Scaling group using a launch template**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
1. On the navigation bar at the top of the screen, select the same
    region that you used when you created the launch template.
1. In the navigation pane, choose **Launch Templates**.
1. Select the launch template and choose **Actions**, **Create Auto Scaling group**.
1.  On the **Configure Auto Scaling group details** page, do the following:
    1.  For **Group name**, type a name for your Auto Scaling group.
    1.  For **Launch template version**, choose the version you just made that includes the *InstanceMarketOptions* configured (this should be 2).    
    1.  For **Fleet Composition**, select **Adhere to the launch template**.
    1.  For **Group size**, type 1.
    1.  For **Network**, choose the VPC in which the subnet used in the launch template belongs.
    1.  For **Subnet**, choose the subnet used in the launch template.
    1.  Leave the **Advanced Details** set to default settings.
    1.  Choose **Next: Configure scaling policies**.
1.  On the **Configure scaling policies** page, select **Keep this group at its initial size**, and then choose **Review**.
1.  On the **Review** page, choose **Create Auto Scaling group**.
1.  On the **Auto Scaling group creation status** page,
    choose **Close**.

You have now created an Auto Scaling group configured to launch EC2 Spot
Instances.

-->
