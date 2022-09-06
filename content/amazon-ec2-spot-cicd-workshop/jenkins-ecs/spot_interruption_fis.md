---
title: "Interrupting a Spot Instance"
weight: 150
---

In this section, you're going to launch a Spot Interruption using FIS and then verify that the capacity has been replenished and Jenkins is still working. This will help you to confirm the low impact of your workloads when implementing Spot effectively.

#### Launch the Spot Interruption Experiment
After creating the experiment template in FIS, you can start a new experiment to interrupt one Spot instance. Run the following command:

```
FIS_EXP_TEMP_ID=$(aws cloudformation describe-stacks --stack-name fis-spot-interruption --query "Stacks[0].Outputs[?OutputKey=='FISExperimentID'].OutputValue" --output text)
FIS_EXP_ID=$(aws fis start-experiment --experiment-template-id $FIS_EXP_TEMP_ID --no-cli-pager --query "experiment.id" --output text)
```

Wait around 30 seconds, and you should see that the experiment completes. Run the following command to confirm:

```
aws fis get-experiment --id $FIS_EXP_ID --no-cli-pager
```

At this point, FIS has triggered a Spot interruption notice, and in two minutes the instance will be terminated.

Go to CloudWatch Logs group `/aws/events/spotinterruptions` to confirm that instance received the termination notice. 

You should see a log message like this one:

![SpotInterruptionLog](/images/amazon-ec2-spot-cicd-workshop/spotinterruptionlog.png)

#### Verify the actions taken by Jenkins Auto Scaling group

You are running a Jenkins instance launched by an Auto Scaling group that will launch a new instance if the desired capacity is not compliant.

You can run the following command to see the list of instances with the date and time when they were launched.

```
aws ec2 describe-instances --filters\
 Name='tag:Name',Values='Jenkins Master (Spot)'\
 Name='instance-state-name',Values='running'\
 | jq '.Reservations[].Instances[] | "Instance with ID:\(.InstanceId) launched at \(.LaunchTime)"'
```

You should see a list of instances with the date and time when they were launched. You'll also see the new instance launched after the interruption.

```output
"Instance with ID:i-04c6ced30794e965b launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-0136152e14053af81 launched at 2022-04-06T14:11:25+00:00"
```

#### Verify that Jenkins is still working

Login to the Jenkins server again and start running some jobs as [you did previously](/amazon-ec2-spot-cicd-workshop/jenkins-asg/test-persistence.html#verify-that-the-new-spot-instance-is-running-the-jenkins-server). 

You should see that the EC2 Fleet plugin is still working and is launching Spot instances as build agents.