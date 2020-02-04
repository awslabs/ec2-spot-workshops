+++
title = "GitHubリポジトリのクローニング"
weight = 60
+++

ワークショップ用に準備したファイル群をCloud9環境に取得するため、GitHubリポジトリをクローンします。

1. Cloud9ターミナルから次のコマンドを発行します。

	```
	git clone https://github.com/awslabs/ec2-spot-workshops.git
	```
	
1. カレントディレクトリを移動します。

	```
	cd ec2-spot-workshops/workshops/running-amazon-ec2-workloads-at-scale
	```

1. 内容を確認します。ディレクトリ構造の確認にはターミナルからだけでなく、**Environment** タブのファイルツリーを活用できます。ファイルをダブルクリックすることで編集も可能です。

1. お使いのアカウントでクローンしたワークショップのアプリケーションを稼働させるため、提供されたファイル群に対して具体的なAWSリソース名を指定する必要があります。以降のステップでは、手元にクローンしたファイル群に対し、CloudFormation経由で作成されたリソース名を指定していきます。この作業を省力化する目的で、事前にCloudFormationの **Outputs** の出力をbashの環境変数に格納するよう、次のコマンド群を発行します。 なお実際のファイル編集は、このそれぞれの環境変数を用い、 *[sed](https://linux.die.net/man/1/sed)* コマンドで行なっていきます。
	```bash
	export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
	export stack_name=runningAmazonEC2WorkloadsAtScale

	# load outputs to env vars
	for output in $(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[].OutputKey' --output text)
	do
	    export $output=$(aws cloudformation describe-stacks --stack-name $stack_name --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
	    eval "echo $output : \"\$$output\""
	done
	```
