+++
title = "Cleanup"
weight = 150
+++
Congratulations, you have completed the Jenkins with Auto Scaling group lab! Your next challenge is to remove all of the resources that were provisioned in your account so as to ensure that no additional cost can be incurred. Please note that the commands below should be executed in order - some later steps have dependencies on earlier ones!

## Delete all Auto Scaling groups

```bash
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsASG;
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name EC2SpotJenkinsHostASG;
```

## Delete theh CloudFormation stack

```bash
aws cloudformation delete-stack --stack-name SpotCICDWorkshop;
```

## Remove theh EC2 key pair
The final resource that needs to be removed was the first one that you created - the EC2 Key Pair that you created prior to launching the CloudFormation stack.

1. Go to the **EC2** console and click on the **Key Pairs** option from the left frame (or [click here](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs));
2. Mark the check box associated with the Key Pair named **Spot CICD Workshop Key Pair** and click on the **Delete** button. At the resulting pop-up, confirm this action by clicking on the **Yes** button.
