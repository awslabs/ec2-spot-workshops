+++
title = "CloudFormationによるセットアップ"
weight = 30
+++

### CloudFormationスタックの起動

事前準備を省力化するため、このワークショップの環境を準備するCloudFormationテンプレートを用意しました。このCloudFormtionスタックには、VPCおよび2つのアベイラビリティゾーンに対応するそれぞれのサブネット、IAMポリシーとロール、セキュリティグループ、S3バケット、EFSファイルシステム、そしてワークショップ環境自体を操作していくためのCloud9 IDE環境が含まれます。

#### CloudFormationスタックの作成

1. [こちら](https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/workshops/running-amazon-ec2-workloads-at-scale/running-amazon-ec2-workloads-at-scale.yaml)に準備したCloudFormationテンプレートをダウンロードします。

1. 作成されるリソースにどのようなものがあるか、テンプレートの内容を確認します。

1. [AWS CloudFormationマネジメントコンソール](https://console.aws.amazon.com/cloudformation)を開きます。
{{% notice note %}}
ファシリテーターがいる場合、ファシリテーターの指示したリージョンを選択していることを確認してください。
{{% /notice %}}

1. 「**スタックの作成 (Create stack)**」をクリックします。

1. 「**テンプレートの指定 (Specify template)**」で「**テンプレートファイルのアップロード (Upload a template file)**」をクリックし、「**ファイルの選択 (Choose file)**」に先ほどダウンロードしたテンプレートファイルを指定します。

1. 「**次へ (Next)**」をクリックします。

1. 「**スタックの詳細指定 (Specify stack details)**」で、「**スタック名 (Stack name)**」に　*runningAmazonEC2WorkloadsAtScale* を指定します。

1. (オプション) **パラメータ (Parameters)**で **sourceCidr** を変更することで、EC2インスタンスへのSSHおよびHTTPアクセス、またロードバランサへのHTTPアクセスの接続元を限定することができます。

1. 「**次へ (Next)**」をクリックします。

1. 「**スタックオプションの指定 (Configure stack options)**」は変更不要です。

1. 「**次へ (Next)**」をクリックします。

1. スタックの構成内容を確認します。画面最下部の「**機能**」では、**「AWS CloudFormation によって IAM リソースが作成される場合があることを承認します。」(I acknowledge that AWS CloudFormation might create IAM resources)** にチェックを入れます。設定内容に問題がなければ「**スタックの作成 (Create stack)**」をクリックします。

#### スタックの進捗確認

スタックの作成完了の目安は、おおむね5分ほどです。

1. [AWS CloudFormationマネジメントコンソール](https://console.aws.amazon.com/cloudformation) から、作成したスタックを選択します。

1. スタックの詳細を表示するペインで「**イベント (Events)**」タブをクリックします。更新ボタンで最新情報を表示することができます。


「**イベント (Events)**」タブでは最新のイベントが先頭に表示され、スタックの主要なステップがどこまで進んだかを確認できます。


AWS CloudFormationがそれぞれのリソースの作成を開始すると、「**CREATE\_IN\_PROGRESS**」イベントが記録されます。そのリソースが正常に作成完了すると、「**CREATE_COMPLETE**」イベントが記録されます。

スタック全体の作成が完了すると、「**イベント (Events)**」タブの最上部に「**CREATE_COMPLETE**」イベントが記録されます。
