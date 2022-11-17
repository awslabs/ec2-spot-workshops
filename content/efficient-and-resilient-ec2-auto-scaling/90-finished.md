+++
title = "Finished!"
weight = 90
+++

{{% notice note %}}
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}

### Clean up

1. **Delete** all manually created resources.

	```
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name ec2-workshop-asg --force-delete
		
	```    

2. **Finally**, delete the CloudFormation stack itself.
	
	```
	aws cloudformation delete-stack --stack-name $stack_name
	```    

**Congratulations** on completing the workshop...*or at least giving it a good go*!  This is the workshop's permanent home, so feel free to revisit as often as you'd like.  In typical Amazon fashion, we'll be listening to your feedback and iterating to make it better.  If you have feedback, we're all ears!
