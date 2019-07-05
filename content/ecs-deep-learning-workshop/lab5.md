+++
title = "Lab-5 Wrap Image Classfication in an ECS Task"
weight = 150
+++

## Wrap Image Classification in an ECS Task

At this point, you've run through training and prediction examples using the command line and using a Juypter notebook, respectively. You can also create task definitions to execute these commands, log the outputs to both S3 and CloudWatch Logs, and terminate the container when the task has completed. S3 will store a log file containing the outputs from each task run, and CloudWatch Logs will have a log group that continues to append outputs from each task run. In this lab, you will create additional task definitions to accomplish this. The steps should be familiar because you've done this in lab 3, only the configuration of the task definition will be slightly different.

*Note: The task definition that was created by the CloudFormation template is an example of a prediction task that you can refer to for help if you get stuck.* 


### Training task

1. Open the EC2 Container Service dashboard, click on **Task Definitions** in the left menu, and click **Create new Task Definition**. Select **EC2** as Launch compatibility and click Next step.

2. Name your task definition, e.g. "mxnet-train".

3. Click on **Add container** and complete the Standard fields in the Add container window. Provide a name for your container, e.g. "mxnet-train". The image field is the same container image that you deployed previously. As a reminder, the format is equivalent to the registry/repository:tag format used in lab 2, step 6, i.e. **AWS_ACCOUNT_ID**.dkr.ecr.**AWS_REGION**.amazonaws.com/**ECR_REPOSITORY**:latest.

Set the memory to a soft limit of "1024". Leave the port mapping blank because you will not be starting the Jupyter process, and instead running a command to perform the training.

Scroll down to the **Advanced Container** configuration section, and in the **Entry point** field, type:

	/bin/bash, -c

In the Command field, type:

	DATE=`date -Iseconds` && echo \\\"running train_mnist.py\\\" && cd /root/ecs-deep-learning-workshop/mxnet/example/image-classification/ && python3 train_mnist.py --lr-factor 1|& tee results && echo \\\"results being written to s3://$OUTPUTBUCKET/train_mnist.results.$HOSTNAME.$DATE.txt\\\" && aws s3 cp results s3://$OUTPUTBUCKET/train_mnist.results.$HOSTNAME.$DATE.txt && echo \\\"Task complete!\\\"

The command references an OUTPUTBUCKET environment variable, and you can set this in **Env variables**. Set the key to be "OUTPUTBUCKET" and the value to be the S3 output bucket created by CloudFormation. You can find the value of your S3 output bucket by going to the CloudFormation stack outputs tab, and used the value for **outputBucketName**. Set "AWS_DEFAULT_REGION" to be the value of **awsRegionName** from the CloudFormation stack outputs tab.

![](/images/ecs-deep-learning-workshop/adv-config-env-train.png)

Next you'll configure logging to CloudWatch Logs. Scroll down to the **Log configuration**, select **awslogs** from the Log driver dropdown menu. For Log options, set the **awslogs-group** to be the value of **cloudWatchLogsGroupName** from the CloudFormation stack outputs tab. And type in the region you're currently using, e.g. Ohio would be us-east-2, Oregon would be us-west-2. Leave the **awslogs-stream-prefix** blank.

![](/images/ecs-deep-learning-workshop/adv-config-log-train.png)

If you are using GPU instances, you will need to check the box for **Privileged** in the **Security** section. Since we're using CPU instances, leave the box unchecked.

Click **Add** to save this configuration and add it to the task defintion. Click **Create** to complete the task defintion creation step.

\
4. Now you're ready to test your task definition. Select **Run Task** from the **Actions** drop down. Refresh the task list to confirm the task enters the Running state.

\
5. The task outputs logs to CloudWatch Logs as well as S3. Open the **CloudWatch** dashboard, and click on **Logs** in the left menu. Click on the log group, and then click on the log stream that was created. You should see log output from the task run; since the training task takes some time to complete, you'll see the log output continue to stream in. Once the task has completed and stopped, check your S3 output bucket, and you should see a log file has been written. Download the log file and check the content.

![](/images/ecs-deep-learning-workshop/cw-logs.png)

### Prediction task

1. Return to the **Task Definitions** page, and click **Create new Task Definition**. Select **EC2** as Launch compatibility and click Next step.

2. Name your task definition, e.g. "mxnet-predict".

3. Click on **Add container** and complete the Standard fields in the Add container window. Provide a name for your container, e.g. "mxnet-predict". The image field is the same container image that you deployed previously. As a reminder, the format is equivalent to the registry/repository:tag format used in lab 2, step 6, i.e. **AWS_ACCOUNT_ID**.dkr.ecr.**AWS_REGION**.amazonaws.com/**ECR_REPOSITORY**:latest.

Set the memory to a soft limit of "1024". Leave the port mapping blank because you will not be starting the Jupyter process, and instead running a command to perform the training.

Scroll down to the **Advanced Container configuration** section, and in the **Entry point** field, type:

	/bin/bash, -c

In the Command field, type:

	DATE=`date -Iseconds` && echo \"running predict_imagenet.py $IMAGEURL\" && /usr/local/bin/predict_imagenet.py $IMAGEURL |& tee results && echo \"results being written to s3://$OUTPUTBUCKET/predict_imagenet.results.$HOSTNAME.$DATE.txt\" && aws s3 cp results s3://$OUTPUTBUCKET/predict_imagenet.results.$HOSTNAME.$DATE.txt && echo \"Task complete!\"

Similar to the training task, configure the **Env variables** used by the command. Set "OUTPUTBUCKET" to be the value of **outputBucketName** from the CloudFormation stack outputs tab. Set "IMAGEURL" to be a URL to an image to be classified. This can be a URL to any image, but make sure it's an absolute path to an image file and not one that is dynamically generated. Set "AWS_DEFAULT_REGION" to be the value of **awsRegionName** from the CloudFormation stack outputs tab.

![](/images/ecs-deep-learning-workshop/adv-config-env-predict.png)

Configure the **Log configuration** section as you did for the training task. Select **awslogs** from the Log driver dropdown menu. For Log options, set the **awslogs-group** to be the value of **cloudWatchLogsGroupName** from the CloudFormation stack outputs tab. And type in the region you're currently using, e.g. Ohio would be us-east-2, Oregon would be us-west-2. Leave the **awslogs-stream-prefix blank**.

If you are using GPU instances, you will need to check the box for **Privileged** in the **Security** section. Since we're using CPU instances, leave the box unchecked.

Click **Add** to save this configuration and add it to the task defintion. Click **Create** to complete the task defintion creation step.

\
4. Run the predict task and check both CloudWatch Logs and the S3 output bucket for related log output.

\
### Extra Credit Challenges

* An S3 input bucket was created by the CloudFormation template. Try uploading images to S3 and running the prediction task against those images.

* Modify the Dockerfile to enable a password in the Jupyter web interface.

* Trigger a lambda function when an image is uploaded to the S3 input bucket and have that lambda function call the prediction task.




