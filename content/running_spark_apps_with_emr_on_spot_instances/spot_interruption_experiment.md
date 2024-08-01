---
title: "Creating the Spot Interruption Experiment"
weight: 97
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



In this section, you're going to start creating the experiment to trigger the interruption of Amazon EC2 Spot Instances using [AWS Fault Injection Simulator (FIS)](https://aws.amazon.com/blogs/compute/implementing-interruption-tolerance-in-amazon-ec2-spot-with-aws-fault-injection-simulator/). When using Spot Instances, you need to be prepared to be interrupted. With FIS, you can test the resiliency of your workload and validate that your application is reacting to the interruption notices that EC2 sends before terminating your instances. You can target individual Spot Instances or a subset of instances in clusters managed by services that tag your instances such as ASG, Fleet and EMR.

You're going to use the CLI, so launch your terminal to run the commands included in this section.

#### What do you need to get started?

Before you start launching Spot interruptions with FIS, you need to create an experiment template. Here is where you define which resources you want to interrupt (targets), and when you want to interrupt the instance. 

You're going to use the following CloudFormation template which creates the IAM role (`FISSpotRole`) with the minimum permissions FIS needs to interrupt an instance, and the experiment template (`FISExperimentTemplate`) you're going to use to trigger a Spot interruption:

```
AWSTemplateFormatVersion: 2010-09-09
Description: FIS for Spot Instances
Parameters:
  InstancesToInterrupt:
    Description: Number of instances to interrupt
    Default: 3
    Type: Number

  DurationBeforeInterruption:
    Description: Number of minutes before the interruption
    Default: 2
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
      Description: "Interrupt multiple random instances"
      Targets: 
        SpotIntances:
          ResourceTags: 
            ResourceTagKey: ResourceTagValue
          Filters:
            - Path: State.Name
              Values: 
              - running
          ResourceType: aws:ec2:spot-instance
          SelectionMode: !Join ["", ["COUNT(", !Ref InstancesToInterrupt, ")"]]
      Actions: 
        interrupt:
          ActionId: "aws:ec2:send-spot-instance-interruptions"
          Description: "Interrupt multiple Spot instances"
          Parameters: 
            durationBeforeInterruption: !Join ["", ["PT", !Ref DurationBeforeInterruption, "M"]]
          Targets: 
            SpotInstances: SpotIntances
      StopConditions:
        - Source: none
      RoleArn: !GetAtt FISSpotRole.Arn
      Tags: 
        Name: "FIS_EXP_NAME"

Outputs:
  FISExperimentID:
    Value: !GetAtt FISExperimentTemplate.Id
```

Here are some important notes about the template:

* You can configure how many instances you want to interrupt with the `InstancesToInterrupt` parameter. In the template it's defined that it's going to interrupt **three** instances.
* You can also configure how much time you want the experiment to run with the `DurationBeforeInterruption` parameter. By default, it's going to take two minutes. This means that as soon as you launch the experiment, the instance is going to receive the two-minute notification Spot interruption warning.
* The most important section is the `Targets` from the experiment template. The template has two placeholders `ResourceTagKey` and `ResourceTagValue` which are basically the key/value for the tags to use when choosing the instances to interrupt. We're going to run a `sed` command to replace them with the proper values for this workshop.
* Notice that instances are **chosen randomly**, and only those who are in the `running` state.

#### Create the EC2 Spot Interruption Experiment with FIS

Let's continue by creating the Spot interruption experiment template using Cloudformation. You can view the CloudFormation template (**fisspotinterruption.yaml**) at GitHub [here](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/fis/fisspotinterruption.yaml). To download it, you can run the following command:

```
wget https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/fis/fisspotinterruption.yaml
```

Now, simply run the following commands to create the FIS experiment:

```
export FIS_EXP_NAME=fis-spot-interruption
sed -i -e "s#ResourceTagKey#aws:elasticmapreduce:instance-group-role#g" fisspotinterruption.yaml
sed -i -e "s#ResourceTagValue#TASK#g" fisspotinterruption.yaml
sed -i -e "s#FIS_EXP_NAME#$FIS_EXP_NAME#g" fisspotinterruption.yaml
aws cloudformation create-stack --stack-name $FIS_EXP_NAME --template-body file://fisspotinterruption.yaml --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name $FIS_EXP_NAME
```