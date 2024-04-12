---
title: "Use FIS to Interrupt a Spot Instance"
date: 2022-08-31T13:12:00-07:00
weight: 50
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

During this workshop we have been making extensive use of Spot instances. One question users of Spot instances ask is how they can reproduce the effects of an instance termination so they can qualify if an application would have degradation or issues when spot instances are terminated and replaced by other instances from pools where capacity is available.

In this section, you're going to create and run an experiment to [trigger the interruption of Amazon EC2 Spot Instances using AWS Fault Injection Simulator (FIS)](https://aws.amazon.com/blogs/compute/implementing-interruption-tolerance-in-amazon-ec2-spot-with-aws-fault-injection-simulator/). When using Spot Instances, you need to be prepared to be interrupted. With FIS, you can test the resiliency of your workload and validate that your application is reacting to the interruption notices that EC2 sends before terminating your instances. You can target individual Spot Instances or a subset of instances in clusters managed by services that tag your instances such as ASG, EC2 Fleet, and EKS.

#### What do you need to get started?

Before you start launching Spot interruptions with FIS, you need to create an experiment template. Here is where you define which resources you want to interrupt (targets), and when you want to interrupt the instance. 

Let's create a CloudFormation template which creates the IAM role (`FISSpotRole`) with the minimum permissions FIS needs to interrupt an instance, and the experiment template (`FISExperimentTemplate`) you're going to use to trigger a Spot interruption:

```
export FIS_EXP_NAME=fis-karpenter-spot-interruption
cat <<EoF > fis-karpenter.yaml
AWSTemplateFormatVersion: 2010-09-09
Description: FIS for Spot Instances
Parameters:
  InstancesToInterrupt:
    Description: Number of instances to interrupt
    Default: 1
    Type: Number

  DurationBeforeInterruption:
    Description: Number of minutes before the interruption
    Default: 3
    Type: Number

Resources:

  FISSpotRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
        - Effect: Allow
          Principal:
            Service: [fis.amazonaws.com]
          Action: ["sts:AssumeRole"]
      Path: /
      Policies:
        - PolicyName: root
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action: 'ec2:DescribeInstances'
                Resource: '*'
              - Effect: Allow
                Action: 'ec2:SendSpotInstanceInterruptions'
                Resource: 'arn:aws:ec2:*:*:instance/*'

  FISExperimentTemplate:
    Type: AWS::FIS::ExperimentTemplate
    Properties:       
      Description: "Interrupt a spot instance with EKS label intent:apps"
      Targets: 
        SpotIntances:
          ResourceTags: 
            IntentLabel: apps
          Filters:
            - Path: State.Name
              Values: 
              - running
          ResourceType: aws:ec2:spot-instance
          SelectionMode: !Join ["", ["COUNT(", !Ref InstancesToInterrupt, ")"]]
      Actions: 
        interrupt:
          ActionId: "aws:ec2:send-spot-instance-interruptions"
          Description: "Interrupt a Spot instance"
          Parameters: 
            durationBeforeInterruption: !Join ["", ["PT", !Ref DurationBeforeInterruption, "M"]]
          Targets: 
            SpotInstances: SpotIntances
      StopConditions:
        - Source: none
      RoleArn: !GetAtt FISSpotRole.Arn
      Tags: 
        Name: "${FIS_EXP_NAME}"

Outputs:
  FISExperimentID:
    Value: !GetAtt FISExperimentTemplate.Id
EoF
```

Here are some important notes about the template:

* You can configure how many instances you want to interrupt with the `InstancesToInterrupt` parameter. In the template it's defined that it's going to interrupt **one** instance.
* You can also configure how much time you want the experiment to run with the `DurationBeforeInterruption` parameter. By default, it's going to take two minutes. This means that as soon as you launch the experiment, the instance is going to receive the two-minute notification Spot interruption warning.
* The most important section is the `Targets` from the experiment template. Under `ResourceTags` we have `IntentLabel: apps` which tells the experiment to only select from the EKS nodes we have labeled with `intent: apps`. If there is more than one instance still running with this label, the instance to be interrupted will be **chosen randomly**.

#### Create the EC2 Spot Interruption Experiment with FIS

Run the following commands to create the FIS experiment from your template, it will take a few moments for them to complete:

```
aws cloudformation create-stack --stack-name $FIS_EXP_NAME --template-body file://fis-karpenter.yaml --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name $FIS_EXP_NAME
```

#### Run the Spot Interruption Experiment

You can run the Spot interruption experiment by issuing the following commands:

```
FIS_EXP_TEMP_ID=$(aws cloudformation describe-stacks --stack-name $FIS_EXP_NAME --query "Stacks[0].Outputs[?OutputKey=='FISExperimentID'].OutputValue" --output text)
FIS_EXP_ID=$(aws fis start-experiment --experiment-template-id $FIS_EXP_TEMP_ID --no-cli-pager --query "experiment.id" --output text)
```

In a few seconds the experiment should complete. This means one of your instances has received a two minute instance interruption notice and will be terminated. You can see the status of the experiment by running:

```
aws fis get-experiment --id $FIS_EXP_ID --no-cli-pager
```

If the experiment completed successfully you should see a response like this:

```
{
    "experiment": {

        ...

        "state": {
            "status": "completed",
            "reason": "Experiment completed."
        },
        "targets": {
            "SpotIntances": {
                "resourceType": "aws:ec2:spot-instance",
                "resourceTags": {
                    "IntentLabel": "apps"
                },
                "filters": [
                    {
                        "path": "State.Name",
                        "values": [
                            "running"
                        ]
                    }
                ],
                "selectionMode": "COUNT(1)"
            }
        },

        ...

    }
}
```

If `status` is listed as `running`, wait a few seconds and run the command again. If `status` is listed as `failed` with `reason` as `Target resolution returned empty set` it means you do not have any Spot instances running with the `intent: apps` label and so no instance was selected for termination.

You can watch how your cluster reacts to the notice with eks-node-viewer. Recall you can access by running:

```bash
eks-node-viewer
```

In the Karpenter logs you will see something like this:

```
controller.interruption removing offering from offerings {"commit": "34d50bf-dirty", "queue": "karpenter-eksspotworkshop", "messageKind": "SpotInterruptionKind", "machine": "default-4z4fx", "action": "CordonAndDrain", "node": "ip-10-0-101-91.eu-west-1.compute.internal", "reason": "SpotInterruptionKind", "instance-type": "m5.xlarge", "zone": "eu-west-1c", "capacity-type": "spot", "ttl": "3m0s"}

controller.interruption initiating delete for machine from interruption message {"commit": "34d50bf-dirty", "queue": "karpenter-eksspotworkshop", "messageKind": "SpotInterruptionKind", "machine": "default-4z4fx", "action": "CordonAndDrain", "node": "ip-10-0-101-91.eu-west-1.compute.internal"}

controller.termination  cordoned node   {"commit": "34d50bf-dirty", "node": "ip-10-0-101-91.eu-west-1.compute.internal"}
```

{{% notice note %}}
You can interrupt more instances by running the experiment multiple times and watch how your cluster reacts, just reissue this command:
```
FIS_EXP_ID=$(aws fis start-experiment --experiment-template-id $FIS_EXP_TEMP_ID --no-cli-pager --query "experiment.id" --output text)
```
{{% /notice %}}

## What Have we learned in this section : 

In this section we have learned:

* We have built an container image using a multi-stage approach and uploaded the resulting microservice into Amazon Elastic Container Registry (ECR).

* We have deployed a Monte Carlo Microservice applying all the lessons learned from the previous section.

* We have set up the Horizontal Pod Autoscaler (HPA) to scale our Monte Carlo microservice whenever the average CPU percentage exceeds 50%, We configured it to scale from 3 replicas to 100 replicas

* We have sent request to the Monte Carlo microservice to stress the CPU of the Pods where it runs. We saw in action dynamic scaling with HPA and Karpenter and now know can we appy this techniques to our kubernetes cluster

* We have created a FIS experiment and ran it to interrupt one of our Spot instances. We watched how the cluster responded using the visual web tool kube-ops-view.


{{% notice info %}}
Congratulations ! You have completed the dynamic scaling section of this workshop.
In the next sections we will collect our conclusions and clean up the setup.
{{% /notice %}}
