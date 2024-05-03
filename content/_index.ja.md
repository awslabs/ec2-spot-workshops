---
title: "Amazon EC2 Spot Workshops"
date: 2019-01-06T12:22:13Z
draft: false
---
# EC2スポットインスタンスワークショップへようこそ！

![spot_logo](/images/spotlogo_small.png )

### Overview

[Amazon EC2 スポットインスタンス](https://aws.amazon.com/ec2/spot/)はAWSの空きキャパシティを活用した、オンデマンドインスタンスに比べて大幅な割引でお使いいただけるEC2インスタンスの購入オプションのひとつです。スポットインスタンスを活用することでAWSの使用コストを最適化し、アプリケーションの対費用スループットを10倍にも高めることができます。

EC2サービスがキャパシティを必要とし、戻してもらう必要がある場合、スポットインスタンスは2分前の中断通知とともに中断されることがあります。アプリケーションが耐障害性を持ち、また柔軟であるほど、中断の可能性と大幅な割引という特徴を持つスポットインスタンスを大いに活用することができます。このようなワークロードの例には、ビッグデータ分析、コンテナ化されたアプリケーション、大規模計算(High Performance Computing, HPC), ステートレスなウェブサーバー、CG等のグラフィックレンダリング処理、CI/CDを含むテスト・ビルド処理などが挙げられます。

このワークショップサイトでは、EC2スポットインスタンスを活用することのできる様々なシナリオを、ハンズオン形式で自習することができます。ワークショップ内ではそれぞれのワークロードに応じたベストプラクティスを実践形式で紹介しています。

左メニューから興味のあるワークショップを選択し、スポットインスタンスの様々な活用シーンに触れてみてください。左メニューには、現時点で日本語化されたワークショップコンテンツのみが表示されています。オリジナルの英語版のコンテンツ一覧はグローバルの[EC2 Spot Instances Workshop](https://ec2spotworkshops.com/)ウェブサイトからアクセス可能です。また以下に示した概要からも、主要なワークショップに進むことができます。

{{< card important_workshop 
    "ja/running-amazon-ec2-workloads-at-scale" 
    "EC2 Auto Scalingによる自動スケール (日本語版)"
    "Amazon-EC2_Auto-Scaling_light-bg.png" 
>}}
このワークショップでは、スケールするワークロードに対してコストを最適化しながらAmazon EC2を活用する方法を学びます。
{{< /card >}}

{{< card important_workshop 
    "running_spark_apps_with_emr_on_spot_instances"
    "Running Spark apps with EMR on Spot instances (in English, 英語版のみ提供)"
    "Amazon-EC2_Instances_light-bg.png" 
>}}
In this workshop you will assume the role of a data engineer, tasked with cost optimizing the organization’s 
costs for running Spark applications, using Amazon EMR and EC2 Spot Instances.
{{< /card >}}

{{< card important_workshop 
    "using_ec2_spot_instances_with_eks"
    "Using Spot Instances with EKS (in English, 英語版のみ提供)"
    "Amazon-Elastic-Container-Service-for-Kubernetes.svg" 
>}}
In this workshop, you learn how to provision, manage, and maintain your Amazon Kubernetes clusters with Amazon EKS at any scale on Spot Instances to architect for optimizations on cost and scale.
{{< /card >}}

{{< card workshop 
    "launching_ec2_spot_instances"
    "Launching EC2 Spot Instances (in English, 英語版のみ提供)"
    "Amazon-EC2_Spot-Instance_light-bg.png" 
>}}
In this workshop you will explore different ways of requesting Amazon EC2 Spot requests
and understand how to qualify workloads for EC2 Spot.
{{< /card >}}








