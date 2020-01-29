+++
title = "Leverage a Fully Managed Solution using AWS Batch"
weight = 40
+++

During this section we will use [Cloud9](https://aws.amazon.com/cloud9/) to build up a 
[docker image](https://docs.docker.com/v17.09/engine/userguide/storagedriver/imagesandcontainers/)
that we will then use to upload to [Elastic Container Registry](https://aws.amazon.com/ecr/). 

We will use this docker image later on with AWS Batch to run our portfolio valuation simulations and
leverage a Spot fully managed solution.

## Using the Cloud9 Environment

AWS Cloud9 comes with a terminal that includes sudo privileges to the managed Amazon EC2 instance that is hosting your development environment and a preauthenticated AWS Command Line Interface. This makes it easy for you to quickly run commands and directly access AWS services.

An AWS Cloud9 environment was launched as a part of the CloudFormation stack (you may have noticed a second CloudFormation stack created by Cloud9). You'll be using this Cloud9 environment to execute the steps in the workshop.

1. Find the name of the AWS Cloud9 environment by checking the value of **cloud9Environment** in the CloudFormation stack outputs.

1. Sign in to the [AWS Cloud9 console](https://console.aws.amazon.com/cloud9/).

1. Find the Cloud9 environment in **Your environments**, and click **Open IDE**.
{{% notice note %}}
Please make sure you are using the Cloud9 environment created by the workshop CloudFormation stack!
{{% /notice %}}

1. Take a moment to get familiar with the Cloud9 environment. You can even take a quick tour of Cloud9 [here](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html#tutorial-tour-ide) if you'd like.


## Create and upload the docker image to ECR

1. On the terminal run the following commands. This will download the repository of code we will
use to build our image.
```
sudo yum install -y jq
git clone https://github.com/awslabs/ec2-spot-workshops.git
cd ec2-spot-workshops/workshops/monte-carlo-on-ec2-spot-fleet
```

1. Login into Elastic Container Registry (ECR) on the terminal. The result of the command will show a **Login Succeeded**
```
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
$(aws ecr get-login --region $REGION --no-include-email)
```

1. Create a repository named **monte-carlo-workshop**.
```
MONTE_CARLO_REGISTRY=$(aws ecr create-repository --repository-name monte-carlo-workshop | jq --raw-output '.["repository"].repositoryUri')
MONTE_CARLO_IMAGE=${MONTE_CARLO_REGISTRY}:latest
echo "Monte carlo repository created at :$MONTE_CARLO_REGISTRY"
echo "Monte carlo image name : $MONTE_CARLO_IMAGE"
```
{{% notice info %}}
When executing next section you will need to use use the image generated. Please take note the 
result above for the **Monte carlo image name**. It should be something like: **ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com/monte-carlo-workshop:latest**
{{% /notice %}}

1. Create the docker image and upload it to the ECR registry
```
docker build -f Dockerfile --tag ${MONTE_CARLO_IMAGE} .
docker push ${MONTE_CARLO_IMAGE}
echo "${MONTE_CARLO_IMAGE} image ready for use"
```

You are now ready to use the generated docker image within AWS Batch. If you are already familiar 
with docker you can try to run the docker image on cloud9 as an optional exercise.


<details>
<summary><strong>Click to reveal detailed instructions (Optional)</strong></summary><p>

1. First let's ensure our cloud9 instance has the right role to query SQS
    1. Go to the **EC2 Console** and click on **instances**
    1. Select the cloud9 instance we are using for this lab
    1. Click on **Actions** and select ** Instance Settings -> Attach/Replace IAM role**
    1. Select the role created by the cloudformation template, prefixed with **monte-carlo-spotFleetInstanceRole**
1. Go to the website URL we used in Lab3 and place a new simulation. The website url can be found
on the **cloudformation -> monte-carlo stack -> Outputs -> WebInterface**
1. Go back to **Cloud9 terminal** and execute the following command.
```
docker run -it -e BATCH_MODE=true -e REGION=$REGION ${MONTE_CARLO_IMAGE}
```

This should display how the process consumes SQS messages from the queue and exits after a few iterations waiting if there are no more messages queued.
</details>

## Leveraging AWS Batch
![Lab 4 Architecture](/images/monte-carlo-on-ec2-spot-fleet/lab4_arch.png) 

1. Before we set up AWS Batch environment. Let's submit a valuation to the SQS queue.
Go to the website URL we used in Lab3 and place a new simulation. The website url can be found
on the **cloudformation -> monte-carlo stack -> Outputs -> WebInterface**. You should be
able to see at least one message in the SQS console.

1. Go to the AWS Batch Console. The following instructions use the first-run wizard. If the wizard does not show, replace the path at the end of the URL with /wizard. e.g. [https://ap-southeast-2.console.aws.amazon.com/batch/home?region=ap-southeast-2#/wizard](https://ap-southeast-2.console.aws.amazon.com/batch/home?region=ap-southeast-2#/wizard)

1. Select/Enter the following values
    * **How would you like to run your job ?** : No job submission and hit Next
    * **Compute environment name** : montecarlo-batch-worker
    * **Service role** and **EC2 instance role** : Leave it defaulted to "Create a new Role"
    * **Provisioning Model** : Spot
    * **Maximum bid price** : 100
    * **Spot fleet role** : Select the role containing your workshop name
    * **Allowed instance types** : optimal
    * **Minimum vCPUs** : 0
    * **Desired vCPUs** : 0
    * **Maximum vCPUs** : 20
    * **VPC Id** : VPC as created earlier
    * **Subnets** : Any two subnets in the VPC
    * **Security groups** : Security Group as created earlier
    * **Job queue name** : montecarlo-batch-worker

1. Click **Create** . It will take less than one minute for the setup to complete. Once complete, click on **View Dashboard**
1. Go to **Job Definition** , hit **Create** and enter the following details
    * **Job definition name** :  montecarlo-queue-processor
    * **Job Attempts** : 3
    * **Execution timeout** : 120 
    * **Job role** :  Select the one that appears in drop down, as created during setup
    * **Container image** :  ACCOUNT_NUMBER.dkr.ecr.AWS_REGION.amazonaws.com/monte-carlo-workshop:latest
    
    > The container image name value should be the one you captured from in the previous step.
    if required, go back to the cloud9 console in another tab and copy the content from there.
    
    * **vCPUs** : 2
    * **Memory (MiB)** : 512
    * Add an environment variable with **Key**: REGION and **Value**  name the region you are using, example us-east-1
    * Add an environment variable with **Key**: BATCH_MODE and **Value** = **true**
    * Leave everything as default and click **Create job Definition**

1. Now we are ready to submit a job (with the definition created above) and run it against the compute environment created above.
Go to Jobs, select **Submit job** and enter the following details
    * **Job name** :  montecarlo-batch-first-run
    * **Job definition** :  Select the one created above
    * **Job queue** :  Select the one created above
    * **Job Type** : Select Single
    * Leave everything as default and click **Submit Job**

This will create the EC2 Instances using Spot price as bid during creating the compute environment.
This process may take 2-3 minutes. When you refresh the screen, you will see the staus of the job getting transitioned from submitted > pending > runnable > starting > running.

![Job Status](/images/monte-carlo-on-ec2-spot-fleet/batch-job-status.png)

#### Evaluate the Results
1. Once the job reaches **Running** state, check your S3 Bucket. In a few minutes you should see results start appearing the bucket.
1. If you monitor the SQS queue for messages you should see them being picked up by the worker container.
1. Once the job is completed, check the **AWS Batch -> Jobs Dashboard** and click on the job to display the job summary showing the number of attempts and link to the logs. Click on **View Logs**
1. Click on the links to the logs and confirm everthing went as expected
![AWS Batch Job Logs](/images/monte-carlo-on-ec2-spot-fleet/aws_batch_logs.png)

#### Extra Credit
* Use [AWS QuickSight](https://https://quicksight.aws/) to build visualizations, perform ad-hoc analysis, and quickly get business insights from your data. You will need to create a json manifest file with your Amazon S3 data location. Use the following template as a starting point:

<pre>
{
    "fileLocations": [
        {
            "URIPrefixes": [
                "s3://YOUR_S3_BUCKET_NAME/"
            ]
        }
    ],
    "globalUploadSettings": {
        "format": "CSV"
    }
}
</pre>

**You've completed Lab 4, Congrats!**