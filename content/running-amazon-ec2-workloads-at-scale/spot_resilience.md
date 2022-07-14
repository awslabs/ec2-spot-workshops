+++
title = "Increasing resilience when using Spot Instances"
weight = 155
+++

### Handling Spot Interruptions
When EC2 needs the capacity back in a specific capacity pool (a combination of an instance type and Operating System in an Availability Zone) it could start interrupting the Spot Instances that are running in that AZ, by sending a 2 minute interruption notification, and then terminating the instance. The 2 minute interruption notification is delivered via [EC2 instance meta-data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html#spot-instance-termination-notices) as well as Amazon EventBridge (Amazon EventBridge builds upon and extends CloudWatch Events. It uses the same service API and endpoint, and the same underlying service infrastructure. You can find more details [here](https://aws.amazon.com/eventbridge/faqs/)). 

Let's deploy a Lambda function that would catch the event for `EC2 Spot Instance Interruption Warning` and automatically detach the soon-to-be-terminated instance from the EC2 Auto Scaling group. 
By calling the [DetachInstances](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DetachInstances.html) API you achieve two things:

  1. You can specify on the API call whether to keep the current desired capacity on the Auto Scaling group, or decrement it by the number of instances being detached. By keeping the same desired capacity, Auto Scaling will immediately launch a replacement instance.

  1. If the Auto Scaling group has a Load Balancer or a Target Group attached (as we have in this workshop), the instance is deregistered from it. Also, if a [deregistration delay](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#deregistration-delay) is configured for your Load Balancer (or Target Group), the Auto Scaling group waits the configured time to allow in-flight requests to complete (up to the configured timeout, which we have set up to 90 sec).

  You can learn more about the Detaching EC2 Instances from an Auto Scaling group [here](https://docs.aws.amazon.com/autoscaling/ec2/userguide/detach-instance-asg.html).

We provide you with a sample EC2 Spot Interruption handler [here](https://github.com/awslabs/ec2-spot-labs/tree/master/ec2-spot-interruption-handler) that you can easily deploy via the Serverless Application Repository.

  1. Go to the `Available applications` section of the [Serverless Application Repository console](https://console.aws.amazon.com/serverlessrepo/home#/available-applications)

  1. Under `Public applications` section, mark the checkbox *Show apps that create custom IAM roles or resource policies* and type `ec2-spot-interruption-handler`, then click on the application. You can also access the application directly clicking [this link](https://eu-west-1.console.aws.amazon.com/lambda/home?#/create/app?applicationId=arn:aws:serverlessrepo:eu-west-1:310006123715:applications/ec2-spot-interruption-handler)

  1. Scroll to the bottom and on the `Application settings`section, leave the default settings and mark the checkbox *I acknowledge that this app creates custom IAM roles and resource policies*. Then click `Deploy`.

  1. Allow a couple of minutes for the application to be deployed. Feel free to take this time to browse the solution details on [GitHub](https://github.com/awslabs/ec2-spot-labs/tree/master/ec2-spot-interruption-handler).


The serverless application has configured the following resources:

* An AWS Lambda function that receives Spot Interruption notifications, checks if the instance is part of an Auto Scaling group (and if it's been tagged with Key: `SpotInterruptionHandler/enabled` Value: `true`) and to then call the [DetachInstances API](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DetachInstances.html) of EC2 Auto Scaling to start connection draining and launch a replacement instance. Feel free to go to the [AWS Lambda console](https://eu-west-1.console.aws.amazon.com/lambda/home#/functions) and inspect the `SpotInterruptionHandler` function.
* An Amazon EventBridge event rule to capture Spot Instance interruption notifications and trigger the above Lambda function. Feel free to go to the [Amazon EventBridge console](https://console.aws.amazon.com/events/home#/rules) to inspect the rule.
* An IAM role for the Lambda function to be able to call the AWS API.

If you check the Auto Scaling group instances, you will see they've been already tagged appropriately for SpotInterruptionHandler to take actions if one of its Spot Instance is interrupted (check the asg.json file and you'll see the tag there). At this stage, our infrastructure is ready to respond to Spot Interruptions. 

We can't simulate an actual EC2 Spot Interruption, but we can invoke the Lambda Function with a simulated EC2 Spot Instance Interruption Warning event for one of or Auto Scaling group instances, and see the result.

  1. In the top right corner of the AWS Lambda console, click the dropdown menu **Select a test event** -> **Configure test events**
  1. With **Create a new test event** selected, provide an Event name (i.e TestSpotInterruption). In the event text box, paste the following:
  
    ```json
    {
      "version": "0",
      "id": "92453ca5-5b23-219e-8003-ab7283ca016b",
      "detail-type": "EC2 Spot Instance Interruption Warning",
      "source": "aws.ec2",
      "account": "123456789012",
      "time": "2019-11-05T11:03:11Z",
      "region": "eu-west-1",
      "resources": [
        "arn:aws:ec2:eu-west-1b:instance/<instance-id>"
      ],
      "detail": {
        "instance-id": "<instance-id>",
        "instance-action": "terminate"
      }
    }
    ```

  1. Replace both occurrences of **"\<instance-id>"** with the instance-id of one of the Spot Instances that are currently running in your EC2 Auto Scaling group (you can get an instance-id from the `Instance management` tab in the bottom pane of the [EC2 Auto Scaling groups console](https://console.aws.amazon.com/ec2autoscaling/home) ). You don't need to change any of the other parameters in the event json.
  1. Click **Create**
  1. With your new test name (i.e TestSpotInterruption) selected in the dropdown menu, click the **Test** button.
  1. The execution result should be **succeeded** and you can expand the details to see the successful log message: "Interruption response actions completed for instance i-0156bedcef61187e8 belonging to runningAmazonEC2WorkloadsAtScale"
  1. Go back to the [EC2 Auto Scaling groups console](https://console.aws.amazon.com/ec2autoscaling/home), click on the runningAmazonEC2WorkloadsAtScale Auto Scaling group and under the **Activity** tab in the bottom pane, you should see a **Detaching EC2 instance** activity, followed shortly after by a **Launching a new EC2 instance** activity. Notice the status `WaitingForELBConnectionDraining` on the detached instance. You will find the deregistration timeout configured on the `modify-target-group.json` file.
  1. Go to the [EC2 ELB Target Groups console](https://console.aws.amazon.com/ec2/v2/home#TargetGroups:sort=targetGroupName) and click on the **runningAmazonEC2WorkloadsAtScale** Target Group, go to the Targets tab in the bottom pane, you should see the instance in `draining` status.

Great result! by leveraging the EC2 Spot Instance Interruption Warning, the Lambda Function detached the instance from the Auto Scaling group and the ELB Target Group, thus draining existing connections, and launching a replacement instance before the current instance is terminated.

{{% notice warning %}} 
In a real scenario, EC2 would terminate the instance after two minutes, however in this case we simply mocked up the interruption so the EC2 instance will keep running outside the Auto Scaling group. Go to the EC2 console and terminate the instance that you used on the mock up event.
{{% /notice %}}


### Increasing the application's resilience when using Spot Instances

In this workshop, you learned that the EC2 Auto Scaling group is configured to fulfill the instance type with the most available spare capacity on each Availability Zone (out of a list of 9 types). Since Spot instances are spare EC2 capacity, its supply and demand vary. By being flexible to use multiple instance types you're allocating Spot instances from the optimal capacity pools (a combination of an instance type and Operating system in an Availability Zone) based on available spare capacity, you increase your chances of getting the desired capacity, and decrease the potential number of interrupted instances in case EC2 needs to reclaim Spot instances. 

In case of interruption or scale-out, Auto Scaling will launch a replacement Spot Instance from the optimal instance type based on available spare capacity at that time. This means that over time you'll keep provisioning capacity from optimal pools. You can learn how customers like Mobileye and Skyscanner have benefited of the capacity-optimized Spot Allocation strategy [here](https://aws.amazon.com/blogs/aws/capacity-optimized-spot-instance-allocation-in-action-at-mobileye-and-skyscanner/).

#### Knowledge check
How can you increase the resilience of the Koel music streaming application that you deployed in this workshop, when using EC2 Spot Instances?

{{%expand "Click here for the answer" %}}
  1. Add an Availability Zone - the EC2 Auto Scaling group is currently deployed in two AZs. By adding an AZ to your application, you will tap into more EC2 Spot capacity pools, further diversifying  your usage and decreasing the blast radius in case a Spot interruption occurs in one of the Spot capacity pools. 

  2. Add Instance Types - the 9 instance types that are configured in the Auto Scaling group have small performance variability, so it's possible to run all these instance types in a single ASG and scale on the same dynamic scaling policy. Are there any other instance types that can be added?
{{% /expand %}}

