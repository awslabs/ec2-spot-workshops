+++
title = "Workshop Cleanup"
weight = 1000
+++
Congratulations, you have completed this workshop! Your next challenge is to remove all of the resources that were provisioned in your account so as to ensure that no additional cost can be incurred. Please note that the steps below should be implemented in order - some later steps have dependencies on earlier ones!

## DELETE ALL OBJECTS WITHIN THE S3 BUCKET CREATED BY CLOUDFORMATION
When you attempt to delete the CloudFormation template that you deployed during the Workshop Preparation, the S3 bucket that it provisioned will not be able to be removed unless it is empty. Delete all objects in this bucket (note, you don't need to remove the bucket itself).

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **S3** console (or [click here](https://s3.console.aws.amazon.com/s3/home?region=us-east-1));
2. Click on the name of the S3 bucket that you noted in Lab 2 (it should have a name of spotcicdworkshop-deploymentartifactss3bucket-random_chars);
3. Mark the checkbox next to the **gameoflife-web** directory, then click on the **Actions** dropdown and select **Delete**. At the confirmation screen, click on the **Delete** button.
{{% /expand%}}

## MODIFY THE JENKINS MASTER ECS SERVICE SO THAT 0 TASKS ARE DESIRED
Before the EC2 instances that comprise your ECS cluster can be terminated, you'll need to ensure that no containers are running in the cluster. The containers hosting your build agents are likely already stopped as they only remain online for a few seconds after your build jobs have completed - but the container running Jenkins needs to be stopped.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **ECS** console (or [click here](https://eu-west-1.console.aws.amazon.com/ecs/home?region=eu-west-1#/clusters)) and click on the **SpotCICDWorkshopECSCluster** link;
2. Click on the checkbox of the service with a Service Name that begins with **SpotCICDWorkshop-ECSServiceJenkinsMaster**, then click on the **Update** button;
3. Change the Number of tasks from **1** back to **0**, then click on the **Next Step** button;
4. At the Configure network screen, click on the **Next Step** button. Repeat the same action at the Set Auto Scaling (optional) screen. Finally at the Review screen, click on the **Update Service** button. Once the service has been updated, click on the **View Service** button.
{{% /expand%}}

## DELETE ALL AUTO SCALING GROUPS;
As was the case with EC2 instances created by Spot Fleet requests, you won't be able to terminate an EC2 instance that belongs to the Auto Scaling Group that you created without the Auto Scaling Group re-launching a new instance to replace the one that you terminated. Therefore, the Auto Scaling Group that you created in Lab 4 must be deleted.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **EC2** console and click on the **Auto Scaling Groups** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/autoscaling/home?region=eu-west-1#AutoScalingGroups));
2. Mark the checkbox next to the Auto Scaling Group with the name of **Spot CICD Workshop ECS Auto Scaling Group** and from the **Actions** dropdown, click **Delete**. In the confirmation, select **Yes, Delete**.
{{% /expand%}}

## CANCEL ALL REMAINING SPOT REQUESTS
The CloudFormation template will not be able to delete subnet and VPC resources if there are EC2 resources still running. Spot fleets are an interesting case though - if you terminate an EC2 instance belonging to a fleet, the fleet will attempt to re-launch it (as shown in Lab 3). Therefore you will need to ensure that all of the Spot Fleets that you created in this workshop have been cancelled.


{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **EC2** console and click on the **Spot Requests** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2sp/v1/spot/home?region=eu-west-1#));
2. Select the checkboxes corresponding to the Spot Fleet request that you created during this workshop that still remain (it should be noted that if you followed every step in the Lab guides, all of these Spot Fleets should already have been removed);
3. Click the Actions dropdown at the top of the screen and select the **Cancel spot request** option. At the confirmation dialogue, ensure that the **Terminate instances** checkbox is selected and click on the **Confirm** button.
{{% /expand%}}

## ENSURE THAT ALL EC2 INSTANCES HAVE BEEN TERMINATED
Having removed all of the Spot Fleets and Auto Scaling groups from the VPC that was created by the CloudFormation template deployed during the Workshop Preparation, you should double-check that all EC2 instances used during the workshop have been terminated.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **EC2** console and click on the **Instances** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances:sort=instanceId));
    * If there is a running instance with a Name of **Jenkins Master (On-Demand)**, mark the checkbox associated with this instance and from the **Actions** dropdown, select **Instance State** > **Terminate**. At the confirmation dialog, click on the **Yes, Terminate** button;
    * If there are running instances with a name of **Jenkins Master (Spot)** or **Jenkins Build Agent**, you still have open Spot Fleet requests - repeat the **Cancel all remaining Spot Requests** section above;
    * If there are running instances with a name of **Spot CICD Workshop ECS Instance**, you still have an active Auto Scaling Group - repeat the **Delete all Auto Scaling Groups** section above;
    * If there are running instances with a name of **Game of Life Test Instance**, you still have the test environment that you created in Lab 2 running - it's fine for these instances to be running, though you will have to delete the CloudFormation stack associated with this test environment prior to deleting the main stack in the next section.
{{% /expand%}}

## DELETE ALL CLOUDFORMATION STACKS
Once you've checked that all EC2 instances have been terminated and there are no objects present in the S3 bucket used for deployment artifacts, you can remove the CloudFormation template that you deployed during the Workshop Preparation.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **CloudFormation** console (or [click here](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1));
2. If you see a Stack named **GameOfLife**, mark the checkbox associated with this stack and from the **Actions** dropdown, select the **Delete Stack** option. At the confirmation pop-up, click on the **Yes, Delete** button. Note, you must wait for this stack to be deleted before proceeding on to the next step.
3. Mark the checkbox associated with the stack named **SpotCICDWorkshop** and from the **Actions** dropdown, select the **Delete Stack** option. At the confirmation dialog, click on the **Yes, Delete** button.
{{% /expand%}}

## DELETE ALL CLOUDWATCH LOG GROUPS RELATED TO THE SPOTCICDWORKSHOP
The Lambda functions used throughout the workshop (notably, to create and tear down the testing environment in Lab 2, and to look up the latest version of various AMIs throughout the workshop) wrote log entries to CloudWatch Logs. These should be removed.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **CloudWatch** console and click on the **Logs** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logs:));
2. For each of the Log Groups that start with **/aws/lambda/SpotCICDWorkshop**:
    1. Select the radio box associated with the Log Group;
    2. From the **Actions** dropdown, select the **Delete log group** option. From the resulting dialog, click on the **Yes, Delete** button.
{{% /expand%}}

## REMOVE THE AMAZON EC2 KEYPAIR CREATED DURING THE WORKSHOP PREPARATION
The final resource that needs to be removed was the first one that you created - the EC2 Key Pair that you created prior to launching the CloudFormation stack.

{{%expand "Click to reveal detailed instructions" %}}
1. Go to the **EC2** console and click on the **Key Pairs** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs));
2. Mark the check box associated with the Key Pair named **Spot CICD Workshop Key Pair** and click on the **Delete** button. At the resulting pop-up, confirm this action by clicking on the **Yes** button.
{{% /expand%}}

## THANK YOU
At this point, we would like to than you for attending this workshop.
