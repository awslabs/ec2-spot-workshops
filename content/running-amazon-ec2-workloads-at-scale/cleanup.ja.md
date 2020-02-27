+++
title = "クリーンアップ"
weight = 170
+++

{{% notice note %}}
AWSイベントでAWSから提供されたアカウントを用いている場合、このステップは省略できます。ご自身のアカウントをお使いの場合、予期せぬ請求が発生しないよう、作成したリソースを確実に消去してください。
{{% /notice %}}

1. もしまだであれば、Auto Scalingグループからデタッチしたインスタンスを削除(Terminate)します。

1. 手動で作成した全てのリソースを、次のコマンドで削除します。

	```
	aws autoscaling delete-auto-scaling-group --auto-scaling-group-name runningAmazonEC2WorkloadsAtScale --force-delete
	
	aws deploy delete-deployment-group --application-name koelApp --deployment-group-name koelDepGroup
	
	aws deploy delete-application --application-name koelApp
	
	aws s3 rm s3://$codeDeployBucket --recursive
		
	aws elbv2 delete-load-balancer --load-balancer-arn $alb_arn

	sleep 5
	
	aws elbv2 delete-target-group --target-group-arn $tg_arn
	
	aws rds delete-db-instance --db-instance-identifier runningAmazonEC2WorkloadsAtScale --skip-final-snapshot
	
	aws ec2 delete-launch-template --launch-template-name runningAmazonEC2WorkloadsAtScale

	aws cloudformation delete-stack --stack-name spotinterruptionhandler
	
	```
	
1. 最後にCloudFormationスタックを削除します。
	
	```
	aws cloudformation delete-stack --stack-name runningAmazonEC2WorkloadsAtScale
	```
