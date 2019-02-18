+++
title = "Lab-2 Build an MXNet Docker Image"
weight = 120
+++

In this lab, you will build an MXNet Docker image using one of the ECS cluster instances which already comes bundled with Docker installed. There are quite a few dependencies for MXNet, so for your convenience, we have provided a [Dockerfile](https://github.com/awslabs/ecs-deep-learning-workshop/blob/master/lab-2-build/mxnet/Dockerfile) in the lab 2 folder to make sure nothing is missed. You can review the Dockerfile to see what's being installed. Links to MXNet documentation can be found in the [Appendix](https://github.com/awslabs/ecs-deep-learning-workshop/#appendix) if you'd like to read more about it.

1. Go to the EC2 Dashboard in the Management Console and click on **Instances** in the left menu. Select the EC2 instance created by the CloudFormation stack. If your instances list is cluttered with other instances, apply a filter in the search bar using the tag key **aws:ec2spot:fleet-request-id** and choose the value that matches the **spotFleetName** from your CloudFormation Outputs.

![](/images/ecs-deep-learning-workshop/ec2-public-dns.png)

Once you've selected one of the provisioned EC2 instances, note the Public DNS Name and SSH into the instance.
	
	$ ssh -i PRIVATE_KEY.PEM ec2-user@EC2_PUBLIC_DNS_NAME
\
2. Once logged into the EC2 instance, clone the workshop github repository so you can easily access the Dockerfile.

	$ git clone https://github.com/awslabs/ecs-deep-learning-workshop.git
\
3. Navigate to the lab-2-build/mxnet/ folder to use as your working directory.

	$ cd ecs-deep-learning-workshop/lab-2-build/mxnet
\
4. Build the Docker image using the provided Dockerfile. A build argument is used to set the password for the Jupyter notebook login which is used in a later lab. **Also, note the trailing period in the command below!!**  

	$ docker build --build-arg PASSWORD=INSERT_A_PASSWORD -t mxnet .
\

{{% notice warning %}}
It is not recommended to use build-time variables for passing secrets like github keys, user credentials etc. Build-time variable values are visible to any user of the image with the docker history command. We have chosen to do it for this lab for simplicity's sake. There are various other methods for secrets management like using [DynamoDB with encryption](https://aws.amazon.com/blogs/developer/client-side-encryption-for-amazon-dynamodb/) or [S3 with encryption](https://aws.amazon.com/blogs/security/how-to-manage-secrets-for-amazon-ec2-container-service-based-applications-by-using-amazon-s3-and-docker/) for key storage and using [IAM Roles](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html) for granting access. There are also third party tools such as [Hashicorp Vault](https://www.vaultproject.io/) for secrets management.
{{% /notice %}}

This process will take a couple of minutes because MXNet and some dependencies are being installed during the container build process. If you're new to Docker, you can take this opportunity to review the Dockerfile to understand what's going on or take a quick break to grab some coffee/tea.

\
5. Now that you've built your local Docker image, you'll need to tag and push the MXNet Docker image to ECR. You'll reference this image when you deploy the container using ECS in the next lab. Find your respository URI in the EC2 Container Service Dashboard; click on Repositories in the left menu and click on the repository name that matches the ecrRepository output from CloudFormation. The Repository URI will be listed at the top of the screen.

![](/images/ecs-deep-learning-workshop/ecr-uri.png)

In your terminal window, tag and push the image to ECR:

	$ docker tag mxnet:latest AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY:latest   

	$ docker push AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY:latest  

Following the example above, you would enter these commands:

	$ docker tag mxnet:latest 873896820536.dkr.ecr.us-east-2.amazonaws.com/ecs-w-ecrre-1vpw8bk5hr8s9:latest

	$ docker push 873896820536.dkr.ecr.us-east-2.amazonaws.com/ecs-w-ecrre-1vpw8bk5hr8s9:latest

You can copy and paste the Repository URI to make things simpler.

### Checkpoint

Note that you did not need to authenticate docker with ECR because the [Amazon ECR Credential Helper](https://github.com/awslabs/amazon-ecr-credential-helper) has been installed and configured for you on the EC2 instance.

At this point you should have a working MXNet Docker image stored in an ECR repository and ready to deploy with ECS.
