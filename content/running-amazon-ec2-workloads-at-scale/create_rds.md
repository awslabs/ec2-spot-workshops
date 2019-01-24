+++
title = "Deploy the database with Amazon RDS"
weight = 80
+++

Amazon Relational Database Service (Amazon RDS) makes it easy to set up, operate, and scale a relational database in the cloud. It provides cost-efficient and resizable capacity while automating time-consuming administration tasks such as hardware provisioning, database setup, patching and backups. It frees you to focus on your applications so you can give them the fast performance, high availability, security and compatibility they need.

1. Edit the file **rds.json**. Update the values **%dbSecurityGroup%** and **%dbSubnetGroup%** from the CloudFormation stack outputs. Save the file.

1. Create the RDS instance:

	```
	aws rds create-db-instance --cli-input-json file://rds.json
	```
	
1. Browse to the [Amazon RDS console](https://console.aws.amazon.com/rds/home?#dbinstances:) to monitor your database deployment. Creating the database will take a few minutes. To save time, you can move onto the next step. You'll come back to check on the database creation in a later step.