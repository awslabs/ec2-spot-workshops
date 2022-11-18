+++
title = "Finished!"
weight = 90
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

**Congratulations** on completing the workshop...*or at least giving it a good go*!  This is the workshop's permanent home, so feel free to revisit as often as you'd like.  In typical Amazon fashion, we'll be listening to your feedback and iterating to make it better.  If you have feedback, we're all ears!

Check the resources on next page to [**learn more**](/efficient-and-resilient-ec2-auto-scaling/100-learn-more.html) about the topics we discussed..
