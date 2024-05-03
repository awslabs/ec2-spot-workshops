+++
title = "Cleanup"
weight = 170
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Amazon EC2 Auto Scaling Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/0a0fe16c-8693-4d23-8679-4f1701dbd2b0/en-US)**.

{{% /notice %}}


{{% notice note %}}
If you're running in an account that was created for you as part of an AWS event, there's no need to go through the cleanup stage - the account will be closed automatically.\
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}


1. Delete all manually created resources.

	```
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name myEC2Workshop --force-delete
		
	aws elbv2 delete-load-balancer --load-balancer-arn $LoadBalancerArn
	
	aws ec2 delete-launch-template --launch-template-name myEC2Workshop

	```    

1. Delete the Target Group created (you need to wait until the Application Load Balancer has been completely deleted).
	```
	aws elbv2 delete-target-group --target-group-arn $TargetGroupArn
	```    
	
1. Finally, delete the CloudFormation stack itself.
	
	```
	aws cloudformation delete-stack --stack-name $stack_name
	```    

1. If you ran the optional Custom Spot Interruption handling exercise, make sure you remove the Spot Interruption handler CloudFormation template deployed by the Serverless Application Repository. 

	```
	aws cloudformation delete-stack --stack-name serverlessrepo-ec2-spot-interruption-handler
	```    