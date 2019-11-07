+++
title = "Deploy to the ASG with CodeDeploy"
weight = 120
+++

An application specification file (AppSpec file), which is unique to AWS CodeDeploy, is a YAML-formatted or JSON-formatted file. The AppSpec file is used to manage each deployment as a series of lifecycle event hooks, which are defined in the file. The AppSpec file is used to:
	
* Map the source files in your application revision to their destinations on the instance.

* Specify custom permissions for deployed files.

* Specify scripts to be run on each instance at various stages of the deployment process.

You can learn more about the AppSpec File Structure [here](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure.html).

You will now deploy your application to the EC2 instances launched by the auto scaling group.

1. Take a moment to browse and view the CodeDeploy structure for your application, located in the **codedeploy** directory.

1. You'll need to modify the CodeDeploy deployment scripts in order to implement using the RDS database instance. Edit **codedeploy/scripts/configure_db.sh**. Replace **%endpoint%** with the **Endpoint** of the database instance (e.g. **runningamazonec2workloadsatscale.ckhifpaueqm7.us-east-1.rds.amazonaws.com** running the following command.
). 

	```
	# Grab the RDS endpoint
	rds_endpoint=$(aws rds describe-db-instances --db-instance-identifier runningamazonec2workloadsatscale --query DBInstances[].Endpoint.Address --output text)

	sed -i.bak -e "s#%endpoint%#$rds_endpoint#g" codedeploy/scripts/configure_db.sh
	```

1. Then clone the Koel GitHub repo:

	```
	cd ~/environment/ec2-spot-workshops/workshops/running-amazon-ec2-workloads-at-scale/
	
	git clone https://github.com/phanan/koel.git
	
	cd koel && git checkout v3.7.2
	```
{{% notice note %}}
you'll get an update about being in 'detached HEAD' state. This is normal.
{{% /notice %}}

1. Next, copy the CodeDeploy configs into the root level of the koel application directory:

	```
	cp -avr ../codedeploy/* .
	```

1. After reviewing and getting comfortable with the CodeDeploy configs, go ahead and create the CodeDeploy application:

	```
	aws deploy create-application --application-name koelApp
	```

1. Browse to the [AWS CodeDeploy console](https://console.aws.amazon.com/codesuite/codedeploy/applications), make sure your region is selected in the upper right-hand corner dropdown, and then click on your application to check out your newly created application.
{{% notice note %}}
The CodeDeploy console will not default to your current region. Please make sure to click on **Select a Region** in the upper right-hand corner and select your region in the dropdown.
{{% /notice %}}


1. Next, push the application to the CodeDeploy S3 bucket (which you initially loaded on the $code_deploy_bucket environment variable):

	```
	aws deploy push --application-name koelApp --s3-location s3://$code_deploy_bucket/koelApp.zip --no-ignore-hidden-files
	```
{{% notice note %}}
You will get output similiar to the following. This is normal and correct:	
*To deploy with this revision, run: aws deploy create-deployment --application-name koelApp --s3-location bucket=runningamazonec2workloadsatscale-codedeploybucket-11wv3ggxcni40,key=koelApp.zip,bundleType=zip,eTag=870b90e201bdca3a06d1b2c6cfcaab11-2 --deployment-group-name <deployment-group-name> --deployment-config-name <deployment-config-name> --description <description>*
{{% /notice %}}
	
1. Find the value of **codeDeployBucket** in the CloudFormation stack outputs (or run $ echo $code_deploy_bucket). This is the bucket you're using for your code deployments. Browse to the [S3 console](https://s3.console.aws.amazon.com/s3/home) and click on the bucket. You should see your application deployment bundle inside the bucket.

1. Edit **deployment-group.json** and replace the value of **%codeDeployServiceRole%** from the CloudFormation stack outputs with the below command, and then create the deployment group:

	```
	cd ..

	sed -i.bak -e "s#%codeDeployServiceRole%#$code_deploy_service_role#g" deployment-group.json
	
	aws deploy create-deployment-group --cli-input-json file://deployment-group.json
	```

1. Browse to the [AWS CodeDeploy console](https://console.aws.amazon.com/codesuite/codedeploy/applications), make sure your region is selected in the upper right-hand corner dropdown, click on your application, and then click on the **Deployment groups** tab to check out your newly created deployment group.
{{% notice note %}}
The CodeDeploy console will not default to your current region. Please make sure to click on **Select a Region** in the upper right-hand corner and select your region in the dropdown.
{{% /notice %}}


1. Finally, edit the application by editing **deployment.json** and replacing the value of **%codeDeployBucket%** from the CloudFormation stack outputs.

	```
	sed -i.bak -e "s#%codeDeployBucket%#$code_deploy_bucket#g" deployment.json
	```

1. Take look at the configuration file and then create a deployment running:

	```
	aws deploy create-deployment --cli-input-json file://deployment.json
	```
{{% notice note %}}
Note the **deploymentId**.
{{% /notice %}}
	
1. Browse to the [AWS CodeDeploy console](https://console.aws.amazon.com/codesuite/codedeploy/deployments), make sure your region is selected in the upper right-hand corner dropdown, and then click on your **Deployment ID** to monitor your application deployment. At the bottom under **Deployment lifecycle events**, you will see a list of the EC2 instances belonging to your auto scaling group. To monitor the individual deployments to each of the instances, click on **View Events**.
{{% notice note %}}
The CodeDeploy console will not default to your current region. Please make sure to click on **Select a Region** in the upper right-hand corner and select your region in the dropdown.
{{% /notice %}}
1. As the application is successfully deployed to the instances, they will pass their target group health checks and be marked as healthy in the target group status. Browse to the [Target Group console](https://console.aws.amazon.com/ec2/v2/home#TargetGroups:sort=targetGroupName), select your target group, and click on the **Targets** tab.

1. Once one or more instances are marked with a status of healthy, browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName), select your load balancer, and copy the **DNS name** (URL) of your load balancer (e.g. http://runningAmazonEC2WorkloadsAtScale-115077449.us-east-1.elb.amazonaws.com).

1. Open your web browser and browse to the **DNS name** (URL). You will see the login page to your application. Login in with the default email address '**admin@example.com**' and default password '**admin-pass**'.

1. The EFS file system is mounted on every instance at **/var/www/media** in order to create a shared location for your audio files. Mount the EFS file system in the Cloud9 environment and copy some mp3s to the file system. Replace **%fileSystem** with the value from the CloudFormation stack outputs:

	```
	mkdir -p ~/environment/media

	sudo mount -t efs $file_system:/ ~/environment/media
	
	sudo chown ec2-user. ~/environment/media
	
	sudo cp -av *.mp3 ~/environment/media
	```	
	
1. Back in Koel, under **MANAGE**, click on **Settings**. Click on **Scan**. Play around and enjoy some audio on your music service.

1. [Optional] If you'd like, find a few more mp3s on the web and upload them to the directory **~/environment/media** in the Cloud9 environment. After uploading them, be sure to re-scan the media directory.