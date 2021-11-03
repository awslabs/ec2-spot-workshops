---
title: "EC2 Auto Scalingによる自動スケール"
date: 2019-01-24T09:05:54Z
weight: 10
pre: "<b>1. </b>"
---
## はじめに
このワークショップでは、スケールするワークロードに対してコストを最適化しながらAmazon EC2を活用する方法を学びます。具体的には、Amazon EC2スポットインスタンスとEC2 Auto Scalingでの複数インスタンスタイプ・複数購入オプションの構成方法を取り上げます。

## シナリオ
あなたは新時代の音楽配信ストリーミングサービスを開発することになりました。これまでに調査した結果、[Koel](https://koel.phanan.net/)を採用するのがベストであることが分かっています。

要件には自動デプロイ、それから需要予測と実トラフィックのそれぞれに応じたスケールが含まれ、また費用上限を越えないようにコントロールすることが求められます。

性能と費用を最適化するため、[EC2 Auto Scalingの提供する複数インスタンスタイプ・複数購入オプションサポート機能](https://aws.amazon.com/jp/blogs/news/new-ec2-auto-scaling-groups-with-multiple-instance-types-purchase-options/)を活用します。
