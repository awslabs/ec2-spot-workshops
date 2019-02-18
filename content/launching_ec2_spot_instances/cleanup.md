+++
title = "Clean Up"
weight = 60
+++

### Delete Your Auto Scaling Group

**To delete your Auto Scaling group using the console**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
1. On the navigation pane, under **Auto Scaling**, choose **Auto Scaling Groups**.
1. On the Auto Scaling groups page, select your Auto Scaling group, 
and choose **Actions**, **Delete**.
1. When prompted for confirmation, choose **Yes, Delete**.

### Delete your EC2 Fleet

When you are finished using your EC2 Fleet, you can delete the EC2 Fleet
and terminate all of the running instances.

**To delete your EC2 Fleet and terminate the running instances**

```bash
$ aws ec2 delete-fleets --fleet-ids fleet-e678bfc6-c2b5-4d9f-8700-03b2db30b183 --terminate-instances
```

### Canceling your Spot Fleet Request

When you are finished using your Spot Fleet, you can cancel the Spot
Fleet request. This cancels all Spot requests associated with the Spot
Fleet, so that no new Spot Instances are launched for your Spot Fleet.
You must specify whether the Spot Fleet should terminate its Spot
Instances. If you terminate the instances, the Spot Fleet request enters
the cancelled\_terminating state. Otherwise, the Spot Fleet request
enters the cancelled\_running state and the instances continue to run
until they are interrupted or you terminate them manually.

**To cancel a Spot Fleet request using the console**

1.  Open the Spot console at <https://console.aws.amazon.com/ec2spot/home/fleet>.
1.  Select your Spot Fleet request.
1.  Choose **Actions**, and then choose **Cancel spot request**.
1.  In **Cancel spot request**, choose **Confirm**.

### Terminating a Spot Instance

**To terminate a Spot Instance using the console**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
1. In the navigation pane, choose **Instances**.
1. Select the instance, and choose **Actions**, **Instance State**, **Terminate**.
1. Choose **Yes, Terminate** when prompted for confirmation.

### Deleting a Launch Template

If you no longer require a launch template, you can delete it. Deleting
a launch template deletes all of its versions.

**To delete a launch template**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
1. In the navigation pane, choose **Launch Templates** and select the launch template.
1. Choose **Actions**, **Delete template**.
1. Choose **Delete launch template**.
