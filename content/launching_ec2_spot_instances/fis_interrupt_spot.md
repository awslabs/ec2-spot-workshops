+++
title = "Interrupting the Spot Instances"
weight = 100
+++

To use AWS FIS, you setup an experiment and run the experiment on the AWS resources. We setup an experiment in the earlier section to interrupt the EC2 Spot instances launched via the Auto Scaling group. In this section, we will run the experiment and review the results.

#### Run the Spot interruption experiment

To run the experiment, we will use `start-experiment` command to run the template created earlier. The experiment can be run multiple times to validate the results of running your application on EC2 Spot.

```bash
aws fis start-experiment --experiment-template-id $FIS_TEMPLATE_ID
```

After you run the experiment, you will see that 50% of the Spot Instances launched by the Auto Scaling group receive the Rebalance Recommendation signals. When the actions on this experiment is complete:

* The target Spot Instance receives an instance rebalance recommendation signal.
* A Spot instance interruption notice is issued two minutes before Amazon EC2 terminates or stops your instance.
* After two minutes, the Spot Instance is terminated or stopped.

Note that a Spot Instance that was stopped by AWS FIS remains stopped until you restart it.

The Auto Scaling group setup in the example has Capacity Rebalance enabled, and hence the Auto Scaling group will start to launch EC2 Spot replacement instances when the Spot instances receive the interruption signal. You can see these events in the ASG.

![Spot Interruption signals in EC2 ASG Events](/images/launching_ec2_spot_instances/rebalance_recommendation_asg.png)

With these tests, you can validate the resiliency of your workload to the Spot interruptions, and optionally improve the workload resiliency by implementing check-pointing or cleanup tasks.

## Resources

[How to use Spot Interruption in FIS](https://docs.aws.amazon.com/fis/latest/userguide/fis-tutorial-spot-interruptions.html)
