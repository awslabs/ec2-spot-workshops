+++
title = "Cloud9環境の使用"
weight = 40
+++
AWS Cloud9はsudo権限のあるターミナルとセットアップ済みのAWS CLI環境を提供する、統合開発環境です。AWS Cloud9はお使いのアカウントにEC2インスタンスを起動し、その上にこれらの環境を自動的にセットアップします。AWS Cloud9を用いることで、Linuxコマンドの発行とCLIからのAWSサービスへのアクセスが非常に容易になります。

このワークショップでは、AWS Cloud9環境はCloudFormationスタック経由で起動されます。ワークショップ本体のCloudFormationスタックと別に、もう一つのCloud9用のCloudFormationスタックが作られています。

{{% notice note %}}
このワークショップでは、以後の操作をこのCloud9環境から実施するものとします。お手元のローカルのコンピューターからの操作ではないことに注意してください。
{{% /notice %}}

1. CloudFormationスタック出力に含まれる **cloud9Environment** を確認し、お使いのアカウントに起動されたAWS Cloud9環境名を確認します。

1. [AWS Cloud9 マネジメントコンソール](https://console.aws.amazon.com/cloud9/)を開きます。

1. **Your environments**から**Open IDE**を開きます。
{{% notice note %}}
改めて、今回このワークショップで作成したCloud9環境にアクセスしていることを確認してください。
{{% /notice %}}

1. 今回がCloud9に触れる初めての機会である場合、すこし時間を取ってCloud9環境に慣れ親しんでください。Cloud9の[クイックツアー](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html#tutorial-tour-ide)を通読することもできます。
