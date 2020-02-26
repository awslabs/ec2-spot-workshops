+++
title = "AWS Systems Managerで負荷をかける"
weight = 150
+++

AWS Systems Manager は、AWS でご利用のインフラストラクチャを可視化し、制御するためのサービスです。Systems Manager を使用すると、統合ユーザーインターフェイスで AWS のさまざまなサービスの運用データを確認でき、AWS リソース全体に関わる運用タスクを自動化できます。AWS Systems Manager を使うと、AWS で実行されるサーバーと、オンプレミスのデータセンターで実行されるサーバーを、1 つのインターフェイスで管理できます。また、サーバーにインストールされた軽量なエージェントとセキュアな通信を確立し、管理タスクを実行できます。これは Amazon EC2 やオンプレミスで実行されている Windows および Linux オペレーティングシステムのリソース管理に役立ちます。

ここではSSMのリモートコマンド機能を使って、各インスタンスに負荷をかけ、自動スケールされることを確認します。

1. **ssm-stress.json**の内容を確認します。内容の変更は不要です。各インスタンスに負荷をかけるため、次のコマンドを実行します。

	```
	aws ssm send-command --cli-input-json file://ssm-stress.json
	```

1. [AWS Systems Manager コンソール](https://console.aws.amazon.com/systems-manager/run-command/executing-commands)を開き、実行したコマンドの実行状況を確認します。

1. [CloudWatchコンソール](https://console.aws.amazon.com/cloudwatch/home?#alarm:alarmFilter=ANY)を開き、ターゲット追跡ポリシーに設定したアラームが発火するのを待ちます。

1. [Auto Scalingコンソール](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details)を開き、対象Auto Scalingグループの「アクティビティ履歴」および「いんすたんす」タブを確認します。コマンド投入から数分でターゲット追跡ポリシーに設定したCPU使用率アラームが閾値に達し、スケールアウトが実行されます。

{{% notice info %}}
AWSアカウントを作って間もない場合、もしくはスポットインスタンスをこれまでに起動したことがない場合、作成したAuto Scalingグループが希望容量までスケールアウトできないことがあります。ワークショップのこのステップ自体はインスタンス台数が少なかったとしても構わないものですので、「アクティビティ履歴」にエラーがあった場合も無視して構いません。
{{% /notice %}}

1. [AWS CodeDeployコンソール](https://console.aws.amazon.com/codesuite/codedeploy/deployments)を開き、画面右上のリージョン設定を確認した上で、新規起動されたインスタンスに正しくアプリケーションがデプロイされることを確認します。
