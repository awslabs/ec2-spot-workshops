+++
title = "AWS Elastic Load Balancerのデプロイ"
weight = 90
+++

ロードバランサは、不特定多数のクライアントに対するアプリケーションのアクセスポイントです。ロードバランサは受け付けたトラフィックを複数アベイラビリティゾーンに配置されたEC2インスタンスなどの複数のターゲットに分散します。この構成はアプリケーションの可用性向上に寄与します。ロードバランサには複数のリスナーを関連づけることができます。

リスナーはクライアントからのリクエストに応じてプロトコルおよびポートベースでリクエストを検査し、ルールごとに登録されたターゲットグループにリクエストを振り分けます。それぞれのルールにはターゲットグループ、条件、優先順位を指定します。これらの条件に合致したリクエストは適切なターゲットグループにルーティングされます。それぞれのリスナーにはデフォルトルールを定義する必要があります。またそれ以外に、リクエスト内容に応じて特定のターゲットグループを指定するルールを定義することもでき、これはコンテントベースルーティングとも呼ばれます。

ターゲットグループにルーティングされたリクエストは、プロトコルとポート番号に応じてEC2インスタンスのようなグループ内のターゲットにさらにルーティングされます。1つのターゲットを複数のターゲットグループに登録することもできます。ターゲットグループにはヘルスチェックを設定できます。ヘルスチェックはターゲットグループ内のすべてのターゲットに対して実行されます。

1. 次のコマンドを実施し、CloudFormationから作成したリソースIDで **application-load-balancer.json** を更新します。

	```
	sed -i.bak -e "s#%publicSubnet1%#$publicSubnet1#g" -e "s#%publicSubnet2%#$publicSubnet2#g" -e "s#%loadBalancerSecurityGroup%#$loadBalancerSecurityGroup#g" application-load-balancer.json
	```

1. 更新されたjsonファイルの内容を確認し、次のコマンドでロードバランサを作成します。

	```
	aws elbv2 create-load-balancer --cli-input-json file://application-load-balancer.json
	```
1. 環境変数にロードバランサのARNを格納します。

	```
	export alb_arn=$(aws elbv2 describe-load-balancers --names runningAmazonEC2WorkloadsAtScale --query LoadBalancers[].LoadBalancerArn --output text)
	```
1. [ロードバランサマネジメントコンソール](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName)から作成されたロードバランサを確認します。

1. 次のコマンドを実施し、CloudFormationから作成したリソースIDで **target-group.json** を更新します。

	```
	sed -i.bak -e "s#%vpc%#$vpc#g" target-group.json
	```

1. 次のコマンドでターゲットグループを作成します。

	```
	aws elbv2 create-target-group --cli-input-json file://target-group.json
	```

1. 環境変数にターゲットグループのARNを格納します。

	```
	export tg_arn=$(aws elbv2 describe-target-groups --names runningAmazonEC2WorkloadsAtScale --query TargetGroups[].TargetGroupArn --output text)
	```

1. 次のコマンドを実施し、作成したターゲットグループのARNで **modify-target-group.json** を更新します。

	```
	sed -i.bak -e "s#%TargetGroupArn%#$tg_arn#g" modify-target-group.json
	```

1. デフォルトで5分となっているターゲットグループのderegistration_delay_timeout値を2分に更新し、スポットインスタンスの中断通知の猶予時間に合わせます。この設定項目の理解を深めるには、Elastic Load BalancingのApplication Load Balancerユーザーガイドの[登録解除の遅延](https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-target-groups.html#deregistration-delay)の記述を参照してください。

	```
	aws elbv2 modify-target-group-attributes --cli-input-json file://modify-target-group.json
	```

1. [ターゲットグループマネジメントコンソール](https://console.aws.amazon.com/ec2/v2/home#TargetGroups:sort=targetGroupName)から作成されたターゲットグループを確認します。

1. 次のコマンドを実施し、先ほどのステップで作成した**%LoadBalancerArn%** と **%TargetGroupArn%** で
 **listener.json** を更新します。
 
	```
	sed -i.bak -e "s#%LoadBalancerArn%#$alb_arn#g" -e "s#%TargetGroupArn%#$tg_arn#g" listener.json
	```

1. 次のコマンドでリスナーを作成します。

	```
	aws elbv2 create-listener --cli-input-json file://listener.json
	```

1. [ロードバランサマネジメントコンソール](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName)からロードバランサを選択し、**リスナー** タブを開きます。作成されたリスナーが関連づけられていることを確認します。
