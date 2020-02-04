+++
title = "AWS CLIおよび関連ツールの導入"
weight = 50
+++

1. Cloud9環境から以下のコマンドを発行し、最新のAWS CLIがインストールされていることを確認します。

	```
	sudo pip install -U awscli
	```
	
1. このワークショップで用いるツール群を次のコマンドで導入します。

	```
	sudo yum -y install jq amazon-efs-utils
	```