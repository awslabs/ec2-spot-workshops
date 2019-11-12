+++
title = "Cleanup"
weight = 170
+++

{{% notice note %}}
If you're running in an account that was created for you as part of an AWS event, there's no need to go through the cleanup stage - the account will be closed automatically.\
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}

1. If you haven't already, terminate the EC2 instance that was detached from the EC2 Auto Scaling group in the previous step.

1. Delete all manually created resources.

	```
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name runningAmazonEC2WorkloadsAtScale --force-delete
	
	aws deploy delete-deployment-group --application-name koelApp --deployment-group-name koelDepGroup
	
	aws deploy delete-application --application-name koelApp
	
	aws s3 rm s3://$code_deploy_bucket --recursive
		
	aws elbv2 delete-load-balancer --load-balancer-arn $alb_arn
	
	aws elbv2 delete-target-group --target-group-arn $tg_arn
	
	aws rds delete-db-instance --db-instance-identifier runningAmazonEC2WorkloadsAtScale --skip-final-snapshot
	
	aws ec2 delete-launch-template --launch-template-name runningAmazonEC2WorkloadsAtScale

	aws cloudformation delete-stack --stack-name spotinterruptionhandler
	
	```
	
1. Finally, delete the CloudFormation stack itself.
	
	```
	aws cloudformation delete-stack --stack-name runningAmazonEC2WorkloadsAtScale
	```
