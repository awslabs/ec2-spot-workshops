+++
title = "Clean Up"
weight = 90
+++

Before closing this workshop, let's make sure we clean up all the resources we created so we do not incur in unexpected costs.

#### Delete Your Auto Scaling Group

**To delete your Auto Scaling group using the CLI**

```
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --force-delete
```

#### Deleting your Spot Fleet Request

Let's now cancel or delete the Spot Fleet request. You must specify whether the Spot Fleet should terminate its Spot Instances. If you terminate the instances, the Spot Fleet request enters
the cancelled\_terminating state. Otherwise, the Spot Fleet request
enters the cancelled\_running state and the instances continue to run
until they are interrupted or you terminate them manually.

**To cancel a Spot Fleet request and terminate the running instances using the CLI**

```
aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids "${SPOT_FLEET_REQUEST_ID}" --terminate-instances
```

#### Delete your EC2 Fleet

When you are finished using your EC2 Fleet, you can delete the EC2 Fleet
and terminate all of the running instances.

**To delete your EC2 Fleet and terminate the running instances using the CLI**

```
aws ec2 delete-fleets --fleet-ids "${FLEET_ID}" --terminate-instances
```

{{% notice note %}}
If you have created the EC2 Fleet that replaces the RunInstances API call, run as well this command: `aws ec2 delete-fleets --fleet-ids "${REPLACEMENT_FLEET_ID}" --terminate-instances`
{{% /notice %}}


#### Terminating the Spot instances created with RunInstance

You recall we created this instance with a specific Name tag. We will use the tag to search for the instance and then pass the instance-id to the `terminate-instances` EC2 call.

```
export INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag-value,Values=EC2SpotWorkshopRunInstance" --query "Reservations[0].Instances[0].InstanceId" | sed s/\"//g)
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
```

#### Deleting a Launch Template

Finally, now that all the instances have been terminated, let's delete the Launch Template.

```
aws ec2 delete-launch-template --launch-template-id "${LAUNCH_TEMPLATE_ID}"
```
