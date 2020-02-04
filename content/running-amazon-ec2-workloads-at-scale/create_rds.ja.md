+++
title = "Amazon RDSによるデータベースの導入"
weight = 80
+++

Amazon Relational Database Service (Amazon RDS)はリレーショナルデータベースを簡単に作成・操作・運用できるマネージド型のデータベースサービスです。サイズ変更可能なデータベースをコスト効率よく提供し、またこれまでデータベース運用につきものだった、ハードウェアの増強、データベースエンジンの導入、パッチ当てやバックアップ運用といった時間のかかる作業を自動化します。さらにデータベースの性能チューニングのヒント、高可用性オプションの提供、セキュリティや互換性の維持などを提供することで、ユーザーは本質的なアプリケーションの開発と運用に集中することができます。

1. 次のコマンドを実施し、CloudFormationから作成したリソースIDで **rds.json** を更新します。
	```
	sed -i.bak -e "s#%dbSecurityGroup%#$dbSecurityGroup#g" -e "s#%dbSubnetGroup%#$dbSubnetGroup#g" rds.json 
	```

1. 更新されたjsonファイルの内容を確認します。問題がなければ次のコマンドでRDS DBインスタンスを作成します。
	```
	aws rds create-db-instance --cli-input-json file://rds.json
	```
	
1. [Amazon RDS console](https://console.aws.amazon.com/rds/home?#dbinstances:)を開き、作成したRDS DBインスタンスが起動する様子を確認します。データベースの作成には数分かかります。これを待つ間に次のステップに進むこともできます。また後ほどデータベースが作成されたことを確認してください。
