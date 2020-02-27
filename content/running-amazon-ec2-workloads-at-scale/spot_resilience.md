+++
title = "スポットインスタンスを利用するシステムの堅牢化"
weight = 155
+++

### Handling Spot Interruptions
あるアベイラビリティゾーンのあるインスタンスタイプにおいてキャパシティが不足してきたとき、EC2サービスはキャパシティを回復させる必要があります。このとき、対象のアベイラビリティゾーンにおけるインスタンスタイプにスポットインスタンスが起動していれば、EC2サービスは該当するスポットインスタンスに2分前の中断通知を送付し、スポットインスタンスを中断することでEC2キャパシティの回復に充てます。2分前の中断通知はインスタンスメタデータサービス、およびCloudWatch Eventsから受け取ることができます。中断通知の詳細は[こちら](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-interruptions.html#spot-instance-termination-notices)のドキュメントを参照してください。
ここでは、中断通知イベントをCloudWatch Events経由で受信し、それをトリガーにLambda関数を実行する仕組みを構築します。中断通知イベントは`EC2 Spot Instance Interruption Warning`という名称です。Lambda関数には、中断対象とマークされたスポットインスタンスをAuto Scalingグループからデタッチ([DetachInstances](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DetachInstances.html))する動作を記述します。

  1. まず検討すべきポイントは、スポットインスタンスをデタッチするタイミングでAuto Scalingグループの希望容量を1台減らすのか、それとも台数変更なしにするのか、という点です。もし希望容量の台数変更をしない場合、Auto Scalingサービスが自動的に新しいインスタンスを起動します。

  1. 次に、今回のワークショップのようにAuto Scalingグループがロードバランサー配下に登録される場合、インスタンスがAuto Scalingグループからデタッチされるとき、ロードバランサーからも登録解除(deregister)されます。このとき、ロードバランサー(あるいはターゲットグループ)にConnection Draining(あるいは登録解除の遅延とも呼ばれます)が設定されていれば、Auto Scalingは処理中のコネクションが終了するまでデタッチを待ちます。今回、このタイムアウト値は中断通知の長さに合わせて120秒を設定しています。

EC2 Auto Scalingのデタッチ動作については[こちらのドキュメント](https://docs.aws.amazon.com/autoscaling/ec2/userguide/detach-instance-asg.html)を参照してください。

このワークショップでは、Lambda関数とClowdWatch Eventsを作成し、それぞれを関連付けるCloudFormationテンプレートを準備しました。

  1. CloudFormationテンプレートの内容を確認します。次のコマンドでスタックをデプロイします。

    ```
    aws cloudformation deploy --template-file spot-interruption-handler.yaml --stack-name spotinterruptionhandler --capabilities CAPABILITY_IAM
    ```

  1. スタックの作成が完了したらば[Lambdaコンソール](https://console.aws.amazon.com/lambda/home)を開き、新規作成された関数名をクリックします。作成完了の目安は2分以内を想定しています。

 
 1. 作成されたLambda関数の内容を確認します。Cloud9のインラインコードエディタを活用してください。

これでスポットインスタンスの中断通知を受け取り、そのインスタンスを自動的にAuto Scalingグループからデタッチさせることができるようになりました。中断そのものをシミュレーションすることはできませんが、ここではLambda関数のテスト機能を使って処理が正しく実行されるかを確認します。

  1. Labmdaコンソール右上にあるドロップダウンメニューから「テストイベントの選択」をクリックしてドロップダウンメニューを表示させ、「テストイベントの設定」を選択します。グレーアウトされている場合にもそのままクリックし、ドロップダウンメニューを表示できます。
  1. 「テストイベントの設定」ダイアログボックスではイベント名に任意の名前を設定し(TestSpotInterruptionなど), 次のjsonを入力します。
  
    ```json
    {
      "version": "0",
      "id": "92453ca5-5b23-219e-8003-ab7283ca016b",
      "detail-type": "EC2 Spot Instance Interruption Warning",
      "source": "aws.ec2",
      "account": "123456789012",
      "time": "2019-11-05T11:03:11Z",
      "region": "eu-west-1",
      "resources": [
        "arn:aws:ec2:eu-west-1b:instance/<instance-id>"
      ],
    "detail": {
      "instance-id": "<instance-id>",
      "instance-action": "terminate"
      }
    }
    ```
    
  1. このjsonに2箇所存在する**"\<instance-id>"**を、作成したAuto Scalingグループ内の任意の1台のインスタンスIDで置き換えます。インスタンスIDは[EC2 Auto Scalingコンソール](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details)のインスタンスタブから確認できます。

  1. 作成を押します。
  1. 「テストイベントの選択」で先ほど選択したテストイベントを選択し、「テスト」ボタンをクリックします。
  1. 画面上部に実行結果の成功が表示されます。「詳細」をクリックして内容を確認します。
  1. [EC2 Auto Scalingコンソール](https://console.aws.amazon.com/ec2/autoscaling/home#AutoScalingGroups:view=details)から対象Auto Scalingグループの「アクティビティ履歴」タブを開き、成功ログとして"Instance i-01234567890123456 belongs to AutoScaling Group runningAmazonEC2WorkloadsAtScale. Detaching instance..."のようなメッセージが出ていることを確認します。またその直後のログに新しいインスタンスの起動が記録されているのを確認します。
  1. [EC2 ELBターゲットグループコンソール](https://console.aws.amazon.com/ec2/v2/home?1#TargetGroups:sort=targetGroupName)から今回のターゲットグループを選択し、ターゲットタブを開きます。該当インスタンスがdrainingのステータスになっていることを確認します。

ここまでの手順で、実際にスポットインスタンスが中断される前にスポットインスタンスの中断通知を受けてシームレスに新しいスポットインスタンスを起動し、入れ替える仕組みを構築することができました。

{{% notice warning %}} 
実際に中断が発生する場合、Auto ScalingグループからデタッチしたインスタンスはEC2スポットサービスにより自動的に終了(Terminate)されます。今回は単に中断イベントをシミュレーションしただけであったためインスタンスは終了されません。デタッチしたインスタンスを忘れずに終了させてください。
{{% /notice %}}


### Increasing the application's resilience when using Spot Instances

これまでの手順では、スポットインスタンスの起動に際して、アベイラビリティゾーンごとに最も安い順に4種類のインスタンスタイプを9種類のインスタンスタイプから選択できるように構成してきました。ここからさらに、使用するインスタンスタイプとアベイラビリティゾーンの組み合わせを増やすことで、特定のスポットキャパシティプール(アベイラビリティゾーンとインスタンスタイプの組み合わせ)での中断の影響を緩和していくことができます。

#### チャレンジしてみましょう

今回作成したスポットインスタンスによる音楽ストリーミングアプリケーションをより堅牢にするために、どのような構成の改善を検討したらよいでしょうか。

{{%expand "考え方の一例" %}}

1. アベイラビリティゾーンを追加します。今の設定では2つのアベイラビリティゾーンを定義しています。ここにもうひとつアベイラビリティゾーンを追加することで、ある1箇所のスポットキャパシティプールでキャパシティが不足し、スポットインスタンスの中断が発生するとき、引き続きワークロードを受けることのできる可能性を高めることができます。

2. インスタンスタイプを追加します。さらに増やせば増やすほど中断発生する確率を下げることができます。今回は9種類のインスタンスタイプを定義していますが、さらに追加できるものがあるでしょうか。

3. スポットインスタンスを起動する対象となるスポットキャパシティプールを増やします。今回は9種類のインスタンスタイプのうち、4種類を上限に指定しました。これを増やすことで使用できるインスタンスタイプの多様性を高めることができ、中断発生確率の低下につながります。
{{% /expand %}}

#### チャレンジしてみましょう
スポットインスタンスの配分戦略には、今回選択したlowest-priceの他にどのようなものがあるでしょうか。今回のワークロードに最も適した配分戦略はどれになるでしょうか。
ヒント：新しい配分戦略についての[記事] (https://aws.amazon.com/blogs/compute/introducing-the-capacity-optimized-allocation-strategy-for-amazon-ec2-spot-instances/)を参照してください。

{{%expand "Click here for the answer" %}}
今回はいわゆるステートレスなアプリケーションを構築しました。これよりも中断を許容しにくい、ステートがインスタンス内に残るようなアプリケーションなどを検討する場面では、capacity-optimizedと呼ばれる配分戦略を選択することを検討してください。AWSがその時点で最も中断の発生しにくいスポットキャパシティプールを自動的に選択し、そこからスポットインスタンスを立ち上げる配分戦略です。
{{% /expand %}}
