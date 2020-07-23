+++
title = "アーキテクチャ"
weight = 20
+++

このワークショップでは次のような項目を取り扱います。

* 以下の構成要素を含むAWS Cloud Formationスタック
  * ワークショップ用のAmazon Virtual Private Cloud (Amazon VPC)
    * 2つのアベイラビリティゾーンに対応する2つのサブネット
  * AWS Cloud9開発環境
  * 動作に必要なIAMポリシーおよびIAMロール
  * 動作に必要なセキュリティグループ
  * EFSファイルシステム
  * AWS CodeDeploy用のS3バケット
* Amazon EC2起動テンプレート
* Amazon RDS DBインスタンス
* アプリケーションロードバランサー(ALB), および関連するリスナーとターゲットグループ定義
* Amazon EC2 Auto Scalingグループ
  * スケジュールスケーリング定義
  * 動的スケジューリング定義
* AWS CodeDeployアプリケーション開発環境
* AWS System Managerによるrun command(システム負荷生成用)

今回構築するシステムのアーキテクチャ図を以下に示します。

![Architecture Description](/images/running-amazon-ec2-workloads-at-scale/architecture.jpg)
