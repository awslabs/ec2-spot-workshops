+++
title = "Clean Up"
weight = 100
+++

### Deleting a Launch Template

If you no longer require a launch template, you can delete it. Deleting
a launch template deletes all of its versions.

**To delete a launch template using the CLI**

```bash
aws ec2 delete-launch-template --launch-template-id "${LAUNCH_TEMPLATE_ID}"
```

### Delete Your Auto Scaling Group

**To delete your Auto Scaling group using the CLI**

```bash
aws ec2 delete-launch-template --auto-scaling-group-name EC2SpotWorkshopASG --force-delete true
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

**To cancel a Spot Fleet request and terminate the running instances using the CLI**

```bash
aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids "${SPOT_FLEET_REQUEST_ID}" --terminate-instances true
```

### Delete your EC2 Fleet

When you are finished using your EC2 Fleet, you can delete the EC2 Fleet
and terminate all of the running instances.

**To delete your EC2 Fleet and terminate the running instances using the CLI**

```bash
$ aws ec2 delete-fleets --fleet-ids "${FLEET_ID}" --terminate-instances true
```

### Terminating a Spot Instance

Terminate any additional instances that you have launched with RunInstances API.

**To terminate a Spot Instance using the console**

1. Open the Amazon EC2 console at <https://console.aws.amazon.com/ec2/>.
1. In the navigation pane, choose **Instances**.
1. Select the instance, and choose **Actions**, **Instance State**, **Terminate**.
1. Choose **Yes, Terminate** when prompted for confirmation.
