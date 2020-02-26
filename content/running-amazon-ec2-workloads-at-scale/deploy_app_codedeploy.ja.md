+++
title = "CodeDeployからAuto Scalingグループにデプロイする"
weight = 120
+++

AWS CodeDeployで用いるアプリケーション仕様ファイル(AppSpecファイル)はYAMLもしくはJSON形式のファイルです。
AppSpecファイルは、ファイルで定義されている一連のライフサイクルイベントフックとして、各デプロイを管理するために使用されます。

正しい形式の AppSpec file を作成する方法については、[CodeDeploy AppSpec Fileリファレンス](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure.html)を参照してください。 

ここまでのステップが完了すると、Auto Scalingグループ内のEC2インスタンスにアプリケーションをデプロイできるようになっています。

1. **codedeploy**ディレクトリに移動し、これからデプロイするアプリケーションの構造を確認します。

1. CodeDeployデプロイスクリプトを編集し、RDS DBインスタンス名を更新します。
次のコマンドを発行して**codedeploy/scripts/configure_db.sh**を更新し、**%endpoint%**をRDS DBインスタンスのエンドポイントの値で置き換えます。

	```
	# RDS DBインスタンスエンドポイント名を取得
	rds_endpoint=$(aws rds describe-db-instances --db-instance-identifier runningamazonec2workloadsatscale --query DBInstances[].Endpoint.Address --output text)

	sed -i.bak -e "s#%endpoint%#$rds_endpoint#g" codedeploy/scripts/configure_db.sh
	```

1. 続いてKoelのGitHubレポジトリを手元にクローンします。

	```
	cd ~/environment/ec2-spot-workshops/workshops/running-amazon-ec2-workloads-at-scale/
	
	git clone https://github.com/phanan/koel.git
	
	cd koel && git checkout v3.7.2
	```
{{% notice note %}}
Gitから'detached HEAD'の通知が来ることを確認してください。
{{% /notice %}}

1. KoelアプリケーションディレクトリにCodeDeployの構成情報をコピーします。

	```
	cp -avr ../codedeploy/* .
	```

1. コピーされたCodeDeploy構成情報を確認し、次のコマンドでCodeDeployアプリケーションを作成します。

	```
	aws deploy create-application --application-name koelApp
	```

1. [AWS CodeDeployコンソール](https://console.aws.amazon.com/codesuite/codedeploy/applications)を開き、右上のリージョン情報が正しいことを確認した上で、作成されたアプリケーションを確認します。

{{% notice note %}}
CodeDeployコンソールに遷移したタイミングで、リージョンが変更されている可能性があります。右上のリージョン情報が異なっている場合、正しいリージョンを改めて選択してください。
{{% /notice %}}


1. アプリケーションをCodeDeploy用S3バケットに配置します。

	```
	aws deploy push --application-name koelApp --s3-location s3://$codeDeployBucket/koelApp.zip --no-ignore-hidden-files
	```
{{% notice note %}}
次のような出力が表示されることを確認してください。

*To deploy with this revision, run: aws deploy create-deployment --application-name koelApp --s3-location bucket=runningamazonec2workloadsatscale-codedeploybucket-11wv3ggxcni40,key=koelApp.zip,bundleType=zip,eTag=870b90e201bdca3a06d1b2c6cfcaab11-2 --deployment-group-name <deployment-group-name> --deployment-config-name <deployment-config-name> --description <description>*
{{% /notice %}}
	
1. アプリケーションが正しくS3バケットに配置されたことを確認します。CloudFormationスタックの出力からS3バケット名を確認し(もしくは`$ echo $codeDeployBucket`を発行し), [S3コンソール](https://s3.console.aws.amazon.com/s3/home)から対象バケットを選択します。

1. 次のコマンドを発行して**deployment-group.json**の**%codeDeployServiceRole%**を作成した値で更新します。続いてデプロイグループを作成します。

	```
	cd ..

	sed -i.bak -e "s#%codeDeployServiceRole%#$codeDeployServiceRole#g" deployment-group.json
	
	aws deploy create-deployment-group --cli-input-json file://deployment-group.json
	```

1. [AWS CodeDeployコンソール](https://console.aws.amazon.com/codesuite/codedeploy/applications)を開き、再度リージョンが正しいことを確認してから、アプリケーションを選択して「デプロイグループ」タブをクリックし、作成されたデプロイグループを確認します。

{{% notice note %}}
CodeDeployコンソールに遷移したタイミングで、リージョンが変更されている可能性があります。右上のリージョン情報が異なっている場合、正しいリージョンを改めて選択してください。
{{% /notice %}}

1. 次のコマンドを発行して**deployment.json**の**%codeDeployBucket%**を作成した値で更新します。

	```
	sed -i.bak -e "s#%codeDeployBucket%#$codeDeployBucket#g" deployment.json
	```

1. **deployment.json**の内容を確認し、デプロイを作成します。

	```
	aws deploy create-deployment --cli-input-json file://deployment.json
	```
{{% notice note %}}
**deploymentId**をメモしてください。
{{% /notice %}}
	
1. [AWS CodeDeployコンソール](https://console.aws.amazon.com/codesuite/codedeploy/deployments)を開き、再度リージョンが正しいことを確認してから対象のデプロイIDをクリックし、デプロイ状況を確認します。下部のデプロイイベントに対象となるEC2インスタンスが表示されていることを確認します。個々のインスタンスへのデプロイ状況は「イベントの表示」から確認できます。

{{% notice note %}}
CodeDeployコンソールに遷移したタイミングで、リージョンが変更されている可能性があります。右上のリージョン情報が異なっている場合、正しいリージョンを改めて選択してください。
{{% /notice %}}

1. アプリケーションが正しくインスタンスにデプロイされると、ターゲットグループのヘルスチェックが正常としてマークされます。[ターゲットグループコンソール](https://console.aws.amazon.com/ec2/v2/home#TargetGroups:sort=targetGroupName)からヘルスチェック結果を確認します。

1. 最低1つのインスタンスが正常とマークされたら、[ロードバランサコンソール](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName)から作成したロードバランサを選択します。

1. **DNS名**をコピーし、URLとしてブラウザからアクセスします。ログインページが表示されたらば、ユーザー名に'**admin@example.com**', パスワードに'**admin-pass**'を指定してログインします。

1. 各インスタンスにはマウントポイント**/var/www/media**があり、ここにEFSファイルシステムがマウントされており、オーディオファイルが格納される想定となっています。mp3ファイルをいくつかコピーするため、Cloud9環境からEFSファイルシステムをマウントします。CloudFormationスタックの出力から控えた**%fileSystem**の値に置き換えた上で、次のコマンドを実行します。

	```
	mkdir -p ~/environment/media

	sudo mount -t efs $fileSystem:/ ~/environment/media
	
	sudo chown ec2-user. ~/environment/media
	
	sudo cp -av *.mp3 ~/environment/media
	```	
	
1. ブラウザのKoel画面に戻り、**MANAGE**から**Settings**, **Scan**と進みます。構築できた音楽サービスにしばらく触れてみてください。

1. [オプション] 任意のmp3ファイルを同様の手順で追加することもできます。追加した後にはメディアディレクトリの再スキャンを忘れずに実施してください。

