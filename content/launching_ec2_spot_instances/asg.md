+++
title = "EC2 Spot via Auto Scaling Group"
weight = 20
+++

## Creating a Launch Template 

You can create a *launch template* that contains the configuration
information to launch an instance. Launch templates enable you to store
launch parameters so that you do not have to specify them every time you
launch an instance. For example, a launch template can contain the AMI
ID, instance type, and network settings that you typically use to launch
instances. When you launch an instance using the Amazon EC2 console, an
AWS SDK, or a command line tool, you can specify the launch template to
use.

**To create a new launch template using the command line**

1. You'll need to gather the following data
    1. **AMI ID**: Specify an AMI ID from which to launch the instance.
        You can use an AMI that you own, or you can [find a suitable
        AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html).
    2. **Instance type**: Choose the instance type. Ensure that the
        instance type is compatible with the AMI you've specified. For
        more information, see [Instance
        Types](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html).
    3. **Subnet**: Specify the subnet in which to create a new network
        interface. For the primary network interface (eth0), this is the
        subnet in which the instance is launched.

2. Once you've gathered the data, create the launch template from the
    command line as follows (be sure to change the following values: **SubnetId**,
    **ImageId**, **InstanceType**, **Tags** - **Value**):


```
aws ec2 create-launch-template --region ap-northeast-1 --launch-template-name TemplateForSpot --version-description TemplateForSpotVersion1 --launch-template-data "{\"NetworkInterfaces\":[{\"DeviceIndex\":0,\"SubnetId\":\"subnet-93d49ac8\"}],\"ImageId\":\"ami-06cd52961ce9f0d85\",\"InstanceType\":\"m4.large\",\"TagSpecifications\":[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"EC2SpotImmersionDay\"}]}]}"
```

**Example return**

```bash
{
    "LaunchTemplate": {
        "CreateTime": "2019-02-14T05:53:07.000Z",
        "LaunchTemplateName": "TemplateForSpot",
        "DefaultVersionNumber": 1,
        "CreatedBy": "arn:aws:iam::123456789012:user/xxxxxxxx",
        "LatestVersionNumber": 1,
        "LaunchTemplateId": "lt-00ac79500cbd56d11"
    }
}
```

{{% notice info %}}
Note the **LaunchTemplateId** (eg. "lt-00ac79500cbd56d11") or
**LaunchTemplateName** (eg. "TemplateForSpot") of the newly created 
Launch Template for the next steps.
{{% /notice %}}

## Launching EC2 Spot Instances via an EC2 Auto Scaling Group

Amazon EC2 Auto Scaling helps you ensure that you have the correct number of Amazon EC2 instances available to handle the load for your application.  You create collections of EC2 instances, called Auto Scaling groups.  You can specify the minimum number of instances in each Auto Scaling group, and Amazon EC2 Auto Scaling ensures that your group never goes below this size. You can specify the maximum number of instances in each Auto Scaling group, and Amazon EC2 Auto Scaling ensures that your group never goes above this size.

With launch templates, you can also provision capacity across multiple instance types using both On-Demand Instances and Spot Instances to achieve the desired scale, performance, and cost.

 **To create an Auto Scaling group using a launch template**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
2. On the navigation bar at the top of the screen, select the same region that you used when you created the launch template.
3. In the navigation pane, choose **Launch Templates**.
4. Select your launch template.
4. Choose **Create Auto Scaling group**.
6. On the Configure Auto Scaling group details page, for Group name, type a name for your Auto Scaling group. 
7. For Launch template version, select the **Default**.
8. For Fleet Composition, choose **Combine purchase options and instances** to launch instances across multiple instance types using both On-Demand and Spot purchase options. 
9. While you chose to combine purchase options and instance types:
    1. For **Instance Types**, choose the optimal instance types (such as m4.large and c4.large) that may be launched.
    2. For **Instance Destribution**, choose to replace the default instance settings.
    3. Provide the following information.
        1. For **Maximum Spot Price**, choose Use default to cap your maximum Spot price at the On-Demand price.
        2. For **Optional On-Demand Base**, you can specify the minimum amount of the Auto Scaling group's initial capacity that must be fulfilled by On-Demand Instances. Leave this field blank to launch On-Demand Instances as a percentage of the group's desired capacity.
        3. For **On-Demand Percentage Above Base**, specify the percentages of On-Demand Instances and Spot Instances for your additional capacity beyond the optional On-Demand base amount. Specify 50 here.
4.  For **Group size**, enter the initial number of instances for your Auto Scaling group. Specify 4 here.
5.  For **Network**, choose a VPC for your Auto Scaling group. 
5.  For **Subnet**, choose one or more subnets in the specified VPC.
6.  Choose **Next: Configure scaling policies**.
7.  On the **Configure scaling policies** page, select **Keep this group at its initial size**, and then choose **Review**.
8.  On the **Review** page, choose **Create Auto Scaling group**.
1.  On the **Auto Scaling group creation status** page, choose **Close**.

You have now created an Auto Scaling group configured to launch not only EC2 Spot Instances but EC2 On-Demand Instances with multiple instance types.