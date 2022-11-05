---
title: "Running the experiment"
date: 2022-09-20T00:00:00Z
weight: 155
---

## Viewing the EC2 Spot instance request status

You can look at your EC2 Spot instance request status with the following command. To learn more about this API, see [describe-spot-instance-requests CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-spot-instance-requests.html).

```
aws ec2 describe-spot-instance-requests --query 'SpotInstanceRequests[].[InstanceId, Status.Code]'
```

The output will show you the EC2 instance IDs and the Spot instance request state:
  - **fulfilled**: indicates an EC2 Spot request was fulfilled and is still active and running.
  - **instance-terminated-by-experiment**: indicates that the EC2 Spot instance received the AWS FIS Interruption signal and was terminated.
  - **instance-terminated-by-user**: indicates that the EC2 Spot instance fulfilled its job and was terminated by AWS Batch after no longer being needed.

{{% notice info %}}
You should wait a few minutes after starting the rendering pipeline for several EC2 instances to reach the **fulfilled** state before the next step, starting the AWS FIS experiment.
{{% /notice %}}

## Starting the AWS FIS experiment

You can run this command twice, at two different points during the AWS Batch run, to simulate multiple Spot interruptions. To learn more about this API, see [start-experiment CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/start-experiment.html).

```
export FIS_EXPERIMENT=$(aws fis start-experiment --experiment-template-id ${FIS_TEMPLATE} | jq -r '.experiment.id')
echo "FIS Experiment ID: ${FIS_EXPERIMENT}"
```

{{% notice note %}}
AWS FIS sends an interruption signal to up to 5 EC2 instances, then waits 2 minutes before terminating the EC2 host.
{{% /notice %}}

To get the status of the AWS FIS experiment, execute the following command. To learn more about this API, see [get-experiment CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/fis/get-experiment.html).

```
aws fis get-experiment --id ${FIS_EXPERIMENT}  | jq -r '.experiment.state'
```

If the status is:
- **running**: the job is still underway.
- **completed**: the AWS FIS experiment has been run and instances will respond to the interruption notice based on the time delay set in the template.
- **failed**: the AWS FIS experiment has failed, a reason code will be provided to assist in understanding why the experiment failed. (e.g. "Target resolution returned empty set").

{{% notice info %}}
If the AWS Batch job is not active, the "failed" reason code will be "**Target resolution returned empty set**". This indicates that no running EC2 instances with the "Spot" tag were found. You should wait a few minutes longer after the AWS Batch job is underway and start the AWS FIS experiment again or the AWS Batch job has completed.
{{% /notice %}}

{{% notice note %}}
With each run of the AWS FIS Experiment, EC2 Spot interruptions remove EC2 instances from the Spot compute environment. The retry strategy of the AWS Batch job will handle these interruptions automatically. If desired, it is possible to create specific retry logic within AWS Batch. Details about this capability can be viewed in the [AWS Batch Documentation](https://docs.aws.amazon.com/batch/latest/userguide/job_retries.html).
{{% /notice %}}