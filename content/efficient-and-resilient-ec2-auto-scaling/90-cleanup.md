+++
title = "Cleanup"
weight = 110
+++

{{% notice note %}}
If you're running in an account that was created for you as part of an AWS event, there's no need to go through the cleanup stage - the account will be closed automatically.\
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}


1. Delete all manually created resources.

	```
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name ec2-workshop-asg --force-delete
		
	```    

2. Finally, delete the CloudFormation stack itself.
	
	```
	aws cloudformation delete-stack --stack-name $stack_name
	```    
