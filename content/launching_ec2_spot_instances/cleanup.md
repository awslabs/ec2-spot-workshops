+++
title = "Clean Up"
weight = 300
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Launching EC2 Spot Instances](https://catalog.us-east-1.prod.workshops.aws/workshops/36a2c2bb-b92d-4428-8626-3a75df01efcc/en-US)**.

{{% /notice %}}

Before closing this workshop, let's make sure we clean up all the resources we created so we do not incur in unexpected costs.

#### Delete the AWS FIS experiment template

When you are done with the FIS experiments, you can delete the experiment template.

```bash
aws fis delete-experiment-template --id $FIS_TEMPLATE_ID
```

#### Delete Your Auto Scaling Group

**To delete your Auto Scaling group using the CLI**

```bash
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name EC2SpotWorkshopASG --force-delete
```

#### Delete your EC2 Fleet

When you are finished using your EC2 Fleet, you can delete the EC2 Fleet(s)
and terminate all of the running instances.

**To delete your EC2 Fleet and terminate the running instances using the CLI**

```bash
aws ec2 delete-fleets --fleet-ids "${FLEET_ID}" --terminate-instances
```

#### Terminating the Spot instances created with RunInstance

You recall we created this instance with a specific Name tag. We will use the tag to search for the instance and then pass the `instance-id` to the terminate-instances EC2 call.

```bash
export INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag-value,Values=EC2SpotWorkshopRunInstance" --query "Reservations[0].Instances[0].InstanceId" | sed s/\"//g)
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
```

#### Deleting your Spot Fleet Request

Let’s now cancel or delete the Spot Fleet request. You must specify whether the Spot Fleet should terminate its Spot Instances. If you terminate the instances, the Spot Fleet request enters the cancelled_terminating state. Otherwise, the Spot Fleet request enters the cancelled_running state and the instances continue to run until they are interrupted or you terminate them manually.

**To cancel a Spot Fleet request and terminate the running instances using the CLI**

```bash
aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids "${SPOT_FLEET_REQUEST_ID}" --terminate-instances
```

#### Deleting a Launch Template

Finally, now that all the instances have been terminated, let's delete the Launch Template.

```
aws ec2 delete-launch-template --launch-template-id "${LAUNCH_TEMPLATE_ID}"
```
