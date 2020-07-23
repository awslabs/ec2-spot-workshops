+++
title = "EC2起動テンプレートの作成"
weight = 70
+++

EC2起動テンプレートを活用することにより、EC2インスタンス起動時に指定する様々なパラメータを事前に定義し、再利用可能な形で保管できます。

起動テンプレートを使えば、EC2インスタンスの起動時に毎回同じ値を入力する必要がなくなります。AMI ID, インスタンスタイプやネットワーク設定といった項目のセットを事前定義でき、EC2マネジメントコンソールやAWS CLI, SDKのいずれからも、EC2インスタンスを起動するときにこの起動テンプレートを指定することができます。

{{% notice note %}}
[起動テンプレート](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)と[起動設定](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html)の違いについて補足します。いずれもEC2の起動に必要なパラメータを定義する機能ですが、起動テンプレートはAmazon EC2とEC2 Auto Scalingを活用する上で、バージョン管理機能を含むより強力な機能を提供します。特にこのワークショップで取り扱う、複数インスタンスタイプ・複数購入オプションを指定したEC2 Auto Scalingグループは起動テンプレートからの作成のみがサポートされています。起動テンプレートについてさらに深く知るには[こちら](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)のドキュメントを参照してください。
{{% /notice %}}

このワークショップに必要な起動テンプレートを定義していきます。

1. 作成されたリソース名で**user-data.txt**を更新するため、次のコマンドを実行します。この内容には、EC2インスタンス起動時に自動実行される[cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html)命令を含んだ[ユーザーデータ](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)が含まれます。
    ```bash
    sed -i.bak -e "s/%awsRegionId%/$AWS_REGION/g" -e "s/%fileSystem%/$fileSystem/g" user-data.txt
    ```
1. インスタンス起動時に実行される処理がどのようなものか、ユーザーデータスクリプトの内容を確認します。

1. 起動テンプレートに定義するデータを格納する **launch-template-data.json** を更新します。ここでは、その時点の最新のAmazon Linux 2 AMIを指定し、CloudFormationで作成したリソースIDを指定し、また上のステップで作成したユーザーデータスクリプトをbase64エンコーディングした値を指定します。次のコマンドを発行します。
    ```
    # 事前に最新のAmazon Linux 2 AMIのAMI IDを取得する
    export ami_id=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images |   sort_by(.CreationDate) | last(.[]).ImageId')

    sed -i.bak -e "s#%instanceProfile%#$instanceProfile#g" -e "s/%instanceSecurityGroup%/$instanceSecurityGroup/g" -e "s#%ami-id%#$ami_id#g" -e "s#%UserData%#$(cat user-data.txt | base64 --wrap=0)#g" launch-template-data.json
    ```

1. 起動テンプレートに定義する項目がどのようなものか、launch-template-data.jsonの内容を確認します。問題がなければ次のコマンドを発行し、起動テンプレートのリソースを作成します。
    ```
    aws ec2 create-launch-template --launch-template-name runningAmazonEC2WorkloadsAtScale --version-description dev --launch-template-data file://launch-template-data.json
    ```

    次のような出力を確認します。

    ```
    {
        "LaunchTemplate": {
            "LatestVersionNumber": 1, 
            "LaunchTemplateId": "lt-04c1ee7ef0e1e6b3b", 
            "LaunchTemplateName": "runningAmazonEC2WorkloadsAtScale", 
            "DefaultVersionNumber": 1, 
            "CreatedBy": "arn:aws:sts::012345678912:assumed-role/runningEC2WorkloadsAtScale-instanceRole-E5CPATQAY4O0/i-xxxxxxx", 
            "CreateTime": "2019-11-05T13:27:58.000Z"
        }
    }
    ```

作成された起動テンプレートを[EC2起動テンプレートマネジメントコンソール](https://console.aws.amazon.com/ec2/v2/home?#LaunchTemplates:sort=launchTemplateId)もしくはCLIから確認します。CLIから確認する場合、正常に作成されたことを次のコマンドで確かめてください。


* 起動テンプレートの定義が正しいことを確認します。

	```
	aws ec2 describe-launch-template-versions  --launch-template-name runningAmazonEC2WorkloadsAtScale
	```

* 起動テンプレートに指定したユーザーデータが正しいことを確認します。

	```
	aws ec2 describe-launch-template-versions  --launch-template-name runningAmazonEC2WorkloadsAtScale --output json | jq -r '.LaunchTemplateVersions[].LaunchTemplateData.UserData' | base64 --decode
	```