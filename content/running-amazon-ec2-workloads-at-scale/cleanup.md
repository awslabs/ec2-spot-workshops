+++
title = "Cleanup"
weight = 170
+++

1. Working backwards, delete all manually created resources.

	```
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name runningAmazonEC2WorkloadsAtScale --force-delete
	
	aws deploy delete-deployment-group --application-name koelApp --deployment-group-name koelDepGroup
	
	aws deploy delete-application --application-name koelApp
	
	aws s3 rm s3://%codeDeployBucket% --recursive
		
	aws elbv2 delete-load-balancer --load-balancer-arn %loadBalancerArn%
	
	aws elbv2 delete-target-group --target-group-arn %targetGroupArn%
	
	aws rds delete-db-instance --db-instance-identifier runningAmazonEC2WorkloadsAtScale --skip-final-snapshot
	
	aws ec2 delete-launch-template --launch-template-name runningAmazonEC2WorkloadsAtScale
	```
	
1. Finally, delete the CloudFormation stack itself.
	
	```
	aws cloudformation delete-stack --stack-name runningAmazonEC2WorkloadsAtScale
	```