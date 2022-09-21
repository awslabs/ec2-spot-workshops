---
title: "Optional - Spot Interruption"
date: 2022-09-20T00:00:00Z
weight: 145
---

## This step is optional

If you want to experiment with how AWS Batch jobs respond to ECS Spot Interruptions, you can follow this guide...

You are now going to create a role for the Fault Injection Simulator(FIS) and then an FIS Experiement. The FIS Experiemnt will create an interruption signal for some of the EC2 Spot instances.


```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                  "fis.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

Run the following to generate the configuration file that will be used to create the FIS IAM Role's Trust Policy:

```
cat <<EoF > fis-role-trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                  "fis.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EoF
```

Run the following command to create the Trust Policy:

```
aws iam create-role --role-name my-fis-role --assume-role-policy-document file://fis-role-trust-policy.json
```

Let's explore the configuration parameters in the structure:

- **priority**: job queues with a higher priority are evaluated first when associated with the same compute environment. Priority is determined in descending order.
- **computeEnvironmentOrder**: the set of compute environments mapped to a job queue and their order relative to each other. A compute environment with a **lower** value of `order` is tried for job placement first. We specify the On-demand compute environment to be tried first to ensure that we have compute capacity throughout the whole execution, thus being able to comply with SLAs should there be any.

{{% notice note %}}
TODO - Anything to note here?
{{% /notice %}}

Execute this command to create the IAM role. To learn more about this API, see [Create an IAM role for AWS FIS experiments](https://docs.aws.amazon.com/fis/latest/userguide/getting-started-iam-service-role.html#fis-trust-policy).

```
export FIS_IAM_ARN=$(aws iam create-role --role-name FIS-Role --assume-role-policy-document file://fis-iam-role-config.json | jq -r '.Arn')
echo "FIS IAM Role Arn: ${FIS_IAM_ARN}"
```

Next, you are going to create a **Job Definition** that will be used to submit jobs.
