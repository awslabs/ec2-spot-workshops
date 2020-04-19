+++
title = "データベースへのデータの投入"
weight = 110
+++

1. [Amazon RDS コンソール](https://console.aws.amazon.com/rds/home?#dbinstances:)を開き、データベースの作成状況を確認します。データベース名を選択し、「概要」セクションに表示される「情報」ステータスが利用可能になっていることを確認します。もしまだ「作成中」であれば、数分おきにリロードして利用可能になるまで待機してください。おそらく初期バックアップの作成に時間を要していることが考えられます。

1. 次に「接続とセキュリティ」セクションから「エンドポイント」をメモします。例えば **runningamazonec2workloadsatscale.ckhifpaueqm7.us-east-1.rds.amazonaws.com** というような文字列です。

1. このデータベースに実データを投入します。次のコマンドの**%endpoint%**を先ほどメモした文字列に置き換え、実行します。

	```
	mysql -h %endpoint% -u dbadmin --password=db-pass-2020 -f koel < koel.sql
	```

{{% notice note %}}

コマンドが成功したとき、特別な出力がないのが正常動作です。

{{% /notice %}}