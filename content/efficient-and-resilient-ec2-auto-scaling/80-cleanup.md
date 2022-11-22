+++
title = "Cleanup"
weight = 80
+++

{{% notice note %}}
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}

### Clean up

**Delete** all manually created resources.

```bash
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name ec2-workshop-asg --force-delete
aws ec2 delete-key-pair --key-name asgworkshop
```    

**Finally**, delete the CloudFormation stack itself.
	
```bash
aws cloudformation delete-stack --stack-name $stack_name
aws cloudformation wait stack-delete-complete --stack-name $stack_name
```

