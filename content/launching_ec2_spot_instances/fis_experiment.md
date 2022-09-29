+++
title = "Creating a Spot Interruption Experiment"
weight = 90
+++

When using Spot Instances, you need to be prepared to be interrupted. You can trigger the interruption of an Amazon EC2 Spot Instance using AWS Fault Injection Simulator (FIS). With (FIS), you can test the resiliency of your workload and validate that your application is reacting to the interruption notices that EC2 sends before terminating your instances. You can target individual Spot Instances or a subset of instances in clusters managed by services that tag your instances such as ASG, EC2 Fleet and EMR.

**Prerequisites**

Before you can use AWS FIS to interrupt a Spot Instance, complete the prerequisites of creating an IAM role. Create a role and attach a policy that enables AWS FIS to perform the aws:ec2:send-spot-instance-interruptions action on your behalf. For more information, see [Create an IAM role for AWS FIS experiments](https://docs.aws.amazon.com/fis/latest/userguide/getting-started-iam-service-role.html).

**Create an experiment template**

**Start the experiment**



