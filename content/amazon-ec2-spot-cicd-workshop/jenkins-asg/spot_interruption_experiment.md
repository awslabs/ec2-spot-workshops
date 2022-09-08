---
title: "Creating the Spot Interruption Experiment"
weight: 145
---

In this section, you're going to start creating the experiment to [trigger the interruption of Amazon EC2 Spot Instances using AWS Fault Injection Simulator (FIS)](https://aws.amazon.com/blogs/compute/implementing-interruption-tolerance-in-amazon-ec2-spot-with-aws-fault-injection-simulator/). When using Spot instances, you need to be prepared to be interrupted. With FIS, you can test the resiliency of your workload and validate that your application is reacting to the interruption notices that EC2 sends before terminating your instances. You can target individual Spot instances or a subset of instances from an Auto Scaling group.

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
            Name: "Jenkins Master (Spot)"
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
        Name: "fis-spot-interruption"

Outputs:
  FISExperimentID:
    Value: !GetAtt FISExperimentTemplate.Id
```

Here are some important notes about the template:

* You can configure how many instances you want to interrupt with the `InstancesToInterrupt` parameter. In the template it's defined that it's going to interrupt **three** instances.
* You can also configure how much time you want the experiment to run with the `DurationBeforeInterruption` parameter. By default, it's going to take two minutes. This means that as soon as you launch the experiment, the instance is going to receive the two-minute notification Spot interruption warning.
* The most important section is the `Targets` from the experiment template. This is where you tell FIS which instances to interrupt. In this case, we're simply going to say that we want to interrupt a instance that's `running` and has a `Name` tag with value `Jenkins Master (Spot)`.
* Notice that instances are going to be **chosen randomly**

#### Create the EC2 Spot Interruption Experiment with FIS

Let's continue by creating the Spot interruption experiment template using Cloudformation. You can view the CloudFormation template (**fisspotinterruption.yaml**) at GitHub [here](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/amazon-ec2-spot-cicd-workshop/fisspotinterruption.yaml). To download it, you can run the following command:

```
wget https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/amazon-ec2-spot-cicd-workshop/fisspotinterruption.yaml
```

Now, simply run the following commands to create the FIS experiment:

```
aws cloudformation create-stack --stack-name fis-spot-interruption --template-body file://fisspotinterruption.yaml --capabilities CAPABILITY_NAMED_IAM
aws cloudformation wait stack-create-complete --stack-name fis-spot-interruption
```