+++
title = "EC2 Auto Scalingグループの作成"
weight = 100
+++

Amazon EC2 Auto Scaling は、Amazon EC2 のインスタンスを自動的に作成または終了してアプリケーションの負荷を処理する Amazon EC2 インスタンスの数を調整できる、完全マネージド型サービスです。Amazon EC2 Auto Scaling では、異常なインスタンスを検出して置き換えることにより、EC2 インスタンスのフリートを管理できます。また、お客様が定義する条件に応じて Amazon EC2 のキャパシティーのスケールアップ/スケールダウンを自動的に行って、アプリケーションの可用性を維持できます。Amazon EC2 Auto Scaling を使用することで、需要が急激に上昇したときには Amazon EC2 インスタンスの数を自動的に増やしてパフォーマンスを維持し、需要が落ち着いた状態にあるときにはインスタンスの数を減らしてコストを削減できます。

1\. **asg.json**を編集し、先ほどCloudFormationから作成したTarget Groupのとサブネットの値を書き換えます。

```
sed -i.bak -e "s#%TargetGroupARN%#$tg_arn#g" -e "s#%publicSubnet1%#$publicSubnet1#g" -e "s#%publicSubnet2%#$publicSubnet2#g" asg.json
```

#### チャレンジしてみましょう
これからデプロイするEC2 Auto Scalingグループは、[ミックスインスタンスグループ機能](https://aws.amazon.com/blogs/aws/new-ec2-auto-scaling-groups-with-multiple-instance-types-purchase-options/)(オンデマンドインスタンスとスポットインスタンス、および複数インスタンスタイプの混在環境)をサポートするものです。**asg.json**ファイルを確認し、次の質問に答えてみましょう。\

- Q. それぞれ何台のオンデマンドインスタンス、スポットインスタンスが起動されるでしょうか。\
- Q. Overridesのセクションに列挙されたインスタンスタイプ一覧から、実際にオンデマンドインスタンスとして起動されるのはどのインスタンスタイプでしょうか。またスポットインスタンスはどうでしょうか。

ヒント: EC2 Auto Scalingのユーザーガイドの[複数のインスタンスタイプと購入オプションを使用する Auto Scaling グループ](https://docs.aws.amazon.com/ja_jp/autoscaling/ec2/userguide/asg-purchase-options.html)のセクション、また合わせて
APIドキュメントの[InstancesDistribution] (https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_InstancesDistribution.html)のセクションを読んでみてください。

{{%expand "考え方の一例(クリックで展開)" %}}

まず`OnDemandBaseCapacity`(ベースのオンデマンド部分)に2が指定され、`OnDemandPercentageAboveBaseCapacity`(オンデマンドの割合)に0, `DesiredCapacity`(希望する容量)に4が指定されています。このとき、EC2 Auto ScalingがこのAuto Scalingグループを作成するタイミングで、2台のオンデマンドインスタンスと2台のスポットインスタンスを起動します。

`SpotAllocationStrategy`に`lowest-price`が指定されているため、スポットインスタンスとしては、アベイラビリティゾーンごとに最も価格の安いインスタンスタイプが選択されます。また`SpotInstancePools`に4が指定されているため、今後このAuto Scalingグループがスケールアウトし、追加のスポットインスタンスが起動されるとき、アベイラビリティゾーンごとに上から4番目までに安いインスタンスタイプが選択されます。

{{% /expand %}}


2\. 次のコマンドを発行し、Auto Scalingグループを作成します。

   ```
   aws autoscaling create-auto-scaling-group --cli-input-json file://asg.json
   ```

{{% notice note %}}
コマンドが成功したとき、特別な出力がないのが正常動作です。
{{% /notice %}}

	
3\. [Auto Scaling コンソール](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details)を開き、新たに作成されたAuto Scalingグループの詳細情報を確認します。次にEC2インスタンスコンソールに移り、起動されたインスタンスがオンデマンドかスポットかを確認します。この属性を表示するには、右上の歯車ボタンから表示属性ダイアログボックスを開き、「ライフサイクル」列を表示させるようにしてください。Normalがオンデマンドおよびリザーブドインスタンス、Spotがスポットインスタンスを示します。

#### チャレンジしてみましょう
Q. 各アベイラビリティゾーンに1台ずつスポットインスタンスを起動しました。このとき選択されたインスタンスタイプは、実際にそのアベイラビリティゾーンで最安値のものになっているでしょうか。\
ヒント: [スポットインスタンスの価格履歴] (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances-history.html)を参照してみましょう。

{{%expand "考え方の一例(クリックで展開)" %}}

1. [EC2インスタンスコンソール] (https://console.aws.amazon.com/ec2/v2/home?#Instances)からスポットインスタンスを選択します。追加表示させたライフサイクル属性を確認し、値がSpotであるものを選択します。
2. それぞれのスポットインスタンスがどのアベイラビリティゾーンに起動されたかを確認します。
3. [EC2スポットインスタンスコンソール Spot Instances console] (https://console.aws.amazon.com/ec2sp/v1/spot/home)を開き、「価格設定履歴」ボタンを押して起動されたスポットインスタンスのインスタンスタイプに設定された現在の価格を確認します。そして**asg.json**に定義した他のインスタンスタイプと価格を比較します。

次の図はeu-west-1リージョンにおける、ある日のm5.largeのスポットインスタンス価格です。アベイラビリティゾーンごとの価格推移が表示され、この図では直近3時間の推移が選択されています。

![spotpricehistory](/images/running-amazon-ec2-workloads-at-scale/spotpricehistory.png)

{{% /expand %}}
