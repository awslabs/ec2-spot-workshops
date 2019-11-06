+++
title = "Deploy the database with Amazon RDS"
weight = 80
+++

Amazon Relational Database Service (Amazon RDS) makes it easy to set up, operate, and scale a relational database in the cloud. It provides cost-efficient and resizable capacity while automating time-consuming administration tasks such as hardware provisioning, database setup, patching and backups. It frees you to focus on your applications so you can give them the fast performance, high availability, security and compatibility they need.

1. Execute the following command to update the file **rds.json** with the resource ids created by the Cloudformation template.

	```
	sed -i.bak -e "s#%dbSecurityGroup%#$db_sg#g" -e "s#%dbSubnetGroup%#$db_subnet_group#g" rds.json 
	```

1. Take a look at the configuration file that you just modified and then create the RDS instance:

	```
	aws rds create-db-instance --cli-input-json file://rds.json
	```
	
1. Browse to the [Amazon RDS console](https://console.aws.amazon.com/rds/home?#dbinstances:) to monitor your database deployment. Creating the database will take a few minutes. To save time, you can move onto the next step. You'll come back to check on the database creation in a later step.