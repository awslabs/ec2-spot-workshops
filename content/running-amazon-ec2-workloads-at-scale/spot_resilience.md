+++
title = "Resilience with Spot Instances"
weight = 155
+++

### Handling Spot Interruptions
When EC2 needs the capacity back in a specific capacity pool (a combination of an instance type in an Availability Zone) it could start interrupting the Spot Instances that are running in that AZ, by sending a 2 minute interruption notification, and then terminating the instance. The 2 minute interruption notification is delivered via [EC2 instance meta-data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html#spot-instance-termination-notices) as well as CloudWatch Events. 

Let's deploy a Lambda function that would catch the CloudWatch event for `EC2 Spot Instance Interruption Warning` and automatically detach the soon-to-be-terminated instance from the EC2 Auto Scaling group. 
By calling the [DetachInstances](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DetachInstances.html) API you achieve two things:

  1. You can specify on the API call whether to keep the current desired capacity on the Auto Scaling group, or decrement it by the number of instances being detached. By keeping the same desired capacity, Auto Scaling will immediately launch a replacement instance.

  1. If the Auto Scaling group has a Load Balancer or a Target Group attached (as we have in this workshop), the instance is deregistered from it. Also, if connection draining is enabled for your Load Balancer (or Target Group), the Auto Scaling group waits for in-flight requests to complete (up to the configured timeout, which we have set up to 120 sec).

    You can learn more about the Detaching EC2 Instances from an Auto Scaling group [here](https://docs.aws.amazon.com/autoscaling/ec2/userguide/detach-instance-asg.html).


To save time, we will use a CloudFormation template to deploy the Lambda Function that will handle EC2 Spot interruptions, and the CloudWatch event rule to catch the Spot Interruption notifications, and subscribe the Lambda Function to it. 

  1. Take some time to review the CloudFormation template and understand what will be launched. Then, execute the following command to deploy the template: 

    ```
    aws cloudformation deploy --template-file spot-interruption-handler.yaml --stack-name spotinterruptionhandler --capabilities CAPABILITY_IAM
    ```

  1. When the CloudFormation deployment completes (under 2 minutes), open the [AWS Lambda console](https://console.aws.amazon.com/lambda/home) and click on the newly deployed Function name.
 
 1. Feel free to examine the code in the Inline code editor.


Now our infrastructure is ready to respond to Spot Interruptions by detaching Spot Instances from the Auto Scaling group when they receive a Spot interruption notification. We can't simulate an EC2 Spot Interruption, but we can invoke the Lambda Function with a simulation of a CloudWatch event for an EC2 Spot Instance Interruption Warning, and see the result.

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
    
  1. Replace both occurrences of **"\<instance-id>"** with the instance-id of one of the Spot Instances that are currently running in your EC2 Auto Scaling group (you can get an instance-id from the Instances tab in the bottom pane of the [EC2 Auto Scaling groups console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details) ). You don't need to change any of the other parameters in the event json.
  1. Click **Create**
  1. With your new test name (i.e TestSpotInterruption) selected in the dropdown menu, click the **Test** button.
  1. The execution result should be **succeeded** and you can expand the details to see the successful log message: "Instance i-01234567890123456 belongs to AutoScaling Group runningAmazonEC2WorkloadsAtScale. Detaching instance..."
  1. Go back to the [EC2 Auto Scaling groups console](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details), and under the **Activity History** tab in the bottom pane, you should see a **Detaching EC2 instance** activity, followed shortly after by a **Launching a new EC2 instance** activity.
  1. Go to the [EC2 ELB Target Groups console](https://console.aws.amazon.com/ec2/v2/home?1#TargetGroups:sort=targetGroupName) and click on the **runningAmazonEC2WorkloadsAtScale** Target Group, go to the Targets tab in the bottom pane, you should see the instance in `draining` mode.

Great result! by leveraging the EC2 Spot Instance Interruption Warning, the Lambda Function detached the instance from the Auto Scaling group and the ELB Target Group, thus draining existing connections, and launching a replacement instance before the current instance is terminated.

{{% notice warning %}} 
In a real scenario, EC2 would terminate the instance after two minutes, however in this case we simply mocked up the interruption so the EC2 instance will keep running outside the Auto Scaling group. Go to the EC2 console and terminate the instance that you used on the mock up event.
{{% /notice %}}


### Increasing the application's resilience when using Spot Instances

In a previous step in this workshop, you learned that the EC2 Auto Scaling group is configured to fulfill the 4 lowest-priced instance types (out of a list of 9 types) in each Availability Zone. Since Spot is spare EC2 capacity, its supply and demand vary. By diversifying your usage of capacity pools (a combination of an instance type in an Availability Zone), you increase your chances of getting the desired capacity, and decrease the potential number of interrupted instances in case Spot Instances are interrupted (when EC2 needs the capacity back for On-Demand).

#### Knowledge check
How can you increase the resilience of the Koel music streaming application that you deployed in this workshop, when using EC2 Spot Instances?

{{%expand "Click here for the answer" %}}
1. Add an Availability Zone - the EC2 Auto Scaling group is currently deployed in two AZs. By adding an AZ to your application, you will tap into more EC2 Spot capacity pools, further diversifying your usage and decreasing the blast radius in case a Spot interruption occurs in one of the Spot capacity pools.
2. Add Instance Types - the 9 instance types that are configured in the Auto Scaling group have small performance variability, so it's possible to run all these instance types in a single ASG and scale on the same dynamic scaling policy. Are there any other instance types that can be added?
3. Increase SpotInstancePools - The ASG is configured to fulfill the 4 lowest-priced instance types. Increase this number to further diversify the usage of capacity pools and decrease the blast radius.
{{% /expand %}}

#### Challenge 
What other Spot allocation strategy can you choose, would it be suitable for this workload? if not, when will you use it?\
Hint: read or skim through the following [article] (https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/)

{{%expand "Click here for the answer" %}}
If you have workloads that are not stateless and fault-tolerant like the Web application that you deployed in this workshop, you can use the capacity-optimized allocation strategy, in order to instruct the ASG to launch instances in the capacity pools which are least likely to be interrupted.
{{% /expand %}}
