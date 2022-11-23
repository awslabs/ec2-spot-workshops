+++
title = "Creating a Spot Interruption Experiment"
weight = 90
+++

When using Spot Instances, you need to be prepared to be interrupted. You can trigger the interruption of an Amazon EC2 Spot Instance using [AWS Fault Injection Simulator (FIS)](https://docs.aws.amazon.com/fis/latest/userguide/what-is.html). With (FIS), you can test the resiliency of your workload and validate that your application is reacting to the interruption notices that EC2 sends before terminating your instances. You can target individual Spot Instances or a subset of instances in clusters managed by services that tag your instances such as ASG, EC2 Fleet and EMR. AWS FIS can be run in the AWS Management Console, AWS CLI, AWS SDKs and as HTTPS API.

To use AWS FIS, you setup an experiment and run the experiment on the AWS resources. To setup an experiment, you first create a bluepring for your experinent via an *experiment template*. An experiment template contains the actions, targets, and stop conditions for the experiment. 

* **Actions**: The experiment performs an action on the AWS resources. AWS FIS provides a set of preconfigured actions based on the type of AWS Resource. In out case, we will use a preconfigured action `aws:ec2:send-spot-instance-interruptions`, which will send a Spot Instance interruption notice to target Spot Instances two minutes before interrupting them. The action will also sent a EC2 Instance rebalance recommendation before the interruption ahead of the interruption based on `durationBeforeInterruption` parameter. The parameter is defaulted to 2 minutes, but can be changed to a value greater than 2 minutes to represent a EC2 Instance rebalance recommendation coming ahead of the Spot Instance interruption notice. For more details, see [send-spot-instance-interruptions](https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html#send-spot-instance-interruptions).

* **Targets**: A target is one or more AWS resources on which AWS FIS experiment performs an action during an experiment. In our case, we will run our actions on EC2 Spot instance using `aws:ec2:spot-instance` as the resource type, and further use `resourceTags` and `filters` to narrow down to the right subset of EC2 Spot instances.

* **Stop conditions**: A stop condition is a mechanism by AWS FIS to stop an experiment if it reaches a threshold that you define as an Amazon CloudWatch alarm. In our case, the experiment will run to completion without a stop condition.

{{% notice warning %}}
Note: Currently, AWS FIS has a Service Quota of maximum of 5 resources per experiment target per account per region, and Service Quota is not configurable . This means that even if your experiments targets more than 5 EC2 Spot instances, AWS FIS limits itself to 5 EC2 Spot instance being interreupted per experiment. You can get over this limit by running more than 1 experiment at a time.
{{% /notice %}}

### Interrupt a Spot instance in the AWS Console without using AWS FIS

You can use the [Spot Requests console](https://console.aws.amazon.com/ec2/home?#SpotInstances:) directly to interrupt the specific EC2 Spot instance, as indicated in the Capacity column and clicking on 'Initiate interruption' in the 'Actions' menu.

![Interrupt EC2 Spot instance from the console](/images/launching_ec2_spot_instances/Interrupt_Spot_from_console.png)

### Interrupt a Spot instance in AWS FIS using AWS CLI

In this section, we will design a template to run the Spot interruption on the EC2 Spot instances launched via Auto Scaling group.

To interrupt Spot instances using AWS FIS CLI, you will have to follow 3 steps:

1. Create an IAM Role to execute the experiment
1. Create the Spot interruption experiment template
1. Run the Spot interruption experiment

In this section we will run the first 2 steps.

#### 1. Create an IAM Role to execute the experiment

To use AWS FIS, you must create an IAM role that grants AWS FIS the permissions required so that AWS FIS can run experiments on your behalf. You specify this experiment role when you create an experiment template. The IAM policy for the experiment role must grant permission to modify the resources that you specify as targets in your experiment template. For more information, see [Create an IAM role for AWS FIS experiments](https://docs.aws.amazon.com/fis/latest/userguide/getting-started-iam-service-role.html).

The experiment role must have a trust relationship that allows the AWS FIS service to assume the role. To create this, you will create a text file named fis_policy.json and add the trust relationship. 

```bash
cat <<EoF > ./fis_role_trust_policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFISExperimentRoleAssumeRole",
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

You will use `create-role` command to create the role with the trust policy. 

```bash
aws iam create-role --role-name my-fis-role --assume-role-policy-document file://fis_role_trust_policy.json
```

The experiment role should also have permission to use the AWS FIS actions for Amazon EC2. Our experiment will require us to perform `ec2:RebootInstances`, `ec2:StopInstances`, `ec2:StartInstances`, and `ec2:TerminateInstances` actions on an EC2 Instances. Out experiment also needs to send a Spot interruption notice using the `aws:ec2:send-spot-instance-interruptions` action on an EC2 Instances. 

Create a text file named fis_role_permissions_policy.json and add the permission policies.

```bash
cat <<EoF > ./fis_role_permissions_policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFISExperimentRoleEC2Actions",
            "Effect": "Allow",
            "Action": [
                "ec2:RebootInstances",
                "ec2:StopInstances",
                "ec2:StartInstances",
                "ec2:TerminateInstances"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*"
        },
        {
            "Sid": "AllowFISExperimentRoleSpotInstanceActions",
            "Effect": "Allow",
            "Action": [
                "ec2:SendSpotInstanceInterruptions"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*"
        }
    ]
}
EoF
```

You will use `put-role-policy` command to add these permissions to the role created earlier. 

```bash
aws iam put-role-policy --role-name my-fis-role --policy-name my-fis-policy --policy-document file://fis_role_permissions_policy.json
```

Let us save the ARN of the role created in an environment variable

```bash
export FIS_ROLE_ARN=$(aws iam get-role --role-name my-fis-role | jq -r '.Role.Arn')
```


#### 2. Create the Spot interruption experiment template

Let us design an experiment template that sends a Spot Interruption notice to the EC2 Spot instances launched via the Auto Scaling group. We will setup an a preconfigured *Action* `aws:ec2:send-spot-instance-interruptions` with `durationBeforeInterruption` set to 2 minutes. We will set a *Target* with `aws:ec2:spot-instance` as the resource type, filter the EC2 Spot instances launched via ASG using `resourceTags` set to `"aws:autoscaling:groupName": "EC2SpotWorkshopASG"`. Our Target will also filter EC2 Spot instances in the running state via `filters` as shown below. We will not have any *Stop* condition for our experiment.

Create an experiment template using this command.

```bash
cat <<EoF > ./spot_experiment.json
{
    "description": "Test Spot Instance interruptions",
    "targets": {
        "SpotInstancesInASG": {
            "resourceType": "aws:ec2:spot-instance",
            "resourceTags": {
                "aws:autoscaling:groupName": "EC2SpotWorkshopASG"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": [
                        "running"
                    ]
                }
            ],
            "selectionMode": "PERCENT(50)"
        }
    },
    "actions": {
        "interruptSpotInstance": {
            "actionId": "aws:ec2:send-spot-instance-interruptions",
            "parameters": {
                "durationBeforeInterruption": "PT2M"
            },
            "targets": {
                "SpotInstances": "SpotInstancesInASG"
            }
        }
    },
    "stopConditions": [
        {
            "source": "none"
        }
    ],
    "roleArn": "${FIS_ROLE_ARN}",
    "tags": {}
}
EoF
```

Create an experiment template using the json configuration.

```bash
export FIS_TEMPLATE_ID=$(aws fis create-experiment-template --cli-input-json file://spot_experiment.json | jq -r '.experimentTemplate.id')
```

You have now created an experiment template to send a Spot interruption using Amazon FIS!

### Challenges

Given the configuration you used above, try to answer the following questions. Click to expand and see the answers.


{{%expand "1. How can I change the number of Spot Instances which are being interrupted?" %}}

You can change the scope of the identified resources by specifying the `selectionMode` of the target instances in the experiment template. AWS FIS selection modes supported shown below can be choosen and the `n` changes per the requirement. Example is to choose `PERCENT(25)` to ramdomly interrupt 25% of the identified targets. 

* `ALL` – Run the action on all targets.
* `COUNT(n)` – Run the action on the specified number of targets, chosen from the identified targets at random. 
* `PERCENT(n)` – Run the action on the specified percentage of targets, chosen from the identified targets at random.s.

{{% /expand %}}

{{%expand "2. How can I send an Rebalance Recommendation signal ahead of the Spot Interruption Notification signal?" %}}

You can change the `durationBeforeInterruption` to more than 2 minutes. The Rebalance Recommendation signal is sent to the identified EC2 Spot targets at the time set in `durationBeforeInterruption` before the FIS experiment interrupts the Spot Instances. Note that exactly 2 minutes before the FIS experiment interrupts the Spot Instance, a Spot Interruption Notification is sent.

An example is if `durationBeforeInterruption` is set to `PT2M`. The Rabalance Recommendation signal is sent 5 minutes before the Spot Interruption, and exactly 2 minutes before the actual Spot interruption, the EC2 Spot instances receive the Spot Interruption Notification.

{{% /expand %}}

{{%expand "3. How can I create an experiment template for interrupting Spot instances launched via the EC2 Fleet?" %}}

You can change the `resourceTags` to include the instances in the experiment.

```bash
cat <<EoF > ./spot_experiment.json
{
    "description": "Test Spot Instance interruptions",
    "targets": {
        "SpotInstancesInASG": {
            "resourceType": "aws:ec2:spot-instance",
            "resourceTags": {
                "aws:ec2:fleet-id": "${FLEET_ID}"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": [
                        "running"
                    ]
                }
            ],
            "selectionMode": "PERCENT(50)"
        }
    },
    "actions": {
        "interruptSpotInstance": {
            "actionId": "aws:ec2:send-spot-instance-interruptions",
            "parameters": {
                "durationBeforeInterruption": "PT2M"
            },
            "targets": {
                "SpotInstances": "SpotInstancesInASG"
            }
        }
    },
    "stopConditions": [
        {
            "source": "none"
        }
    ],
    "roleArn": "${FIS_ROLE_ARN}",
    "tags": {}
}
EoF
```

{{% /expand %}}

{{%expand "4. How can I create an experiment template for interrupting Spot instances launched via RunInstance API?" %}}

In the RunInstance example, we tagged the EC2 Spot Instance with a `Name=EC2SpotWorkshopRunInstance`, and you can use that to update the `resourceTags`. Note the change of `selectionMode` to `ALL` for the experiment to successfully terminate the Spot Instance.

```bash
cat <<EoF > ./spot_experiment.json
{
    "description": "Test Spot Instance interruptions",
    "targets": {
        "SpotInstancesInASG": {
            "resourceType": "aws:ec2:spot-instance",
            "resourceTags": {
                "Name": "EC2SpotWorkshopRunInstance"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": [
                        "running"
                    ]
                }
            ],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "interruptSpotInstance": {
            "actionId": "aws:ec2:send-spot-instance-interruptions",
            "parameters": {
                "durationBeforeInterruption": "PT2M"
            },
            "targets": {
                "SpotInstances": "SpotInstancesInASG"
            }
        }
    },
    "stopConditions": [
        {
            "source": "none"
        }
    ],
    "roleArn": "${FIS_ROLE_ARN}",
    "tags": {}
}
EoF
```

{{% /expand %}}
