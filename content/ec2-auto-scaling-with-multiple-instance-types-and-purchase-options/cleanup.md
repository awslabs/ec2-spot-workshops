+++
title = "Cleanup"
weight = 170
+++

1. Working backwards, delete all manually created resources.

	```
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name myEC2Workshop --force-delete
		
	aws elbv2 delete-load-balancer --load-balancer-arn %loadBalancerArn%
	
	aws elbv2 delete-target-group --target-group-arn %targetGroupArn%
	
	aws ec2 delete-launch-template --launch-template-name myEC2Workshop
	```
	
1. Finally, delete the CloudFormation stack itself.
	
	```
	aws cloudformation delete-stack --stack-name myEC2Workshop
	```