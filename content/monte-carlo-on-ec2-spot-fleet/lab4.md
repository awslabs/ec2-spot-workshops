+++
title = "Leverage a Fully Managed Solution using AWS Batch"
weight = 40
+++

![Lab 4 Architecture](/images/monte-carlo-on-ec2-spot-fleet/lab4_arch.png) 


1. Go to the AWS Batch Console. The following instructions use the first-run wizard. If the wizard does not show, replace the path at the end of the URL with /wizard. (e.g. [https://ap-southeast-2.console.aws.amazon.com/batch/home?region=ap-southeast-2#/wizard](https://ap-southeast-2.console.aws.amazon.com/batch/home?region=ap-southeast-2#/wizard))

2. Select/Enter the following values
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

3. Click **Create** . It will take less than one minute for the setup to complete. Once complete, click on **View Dashboard**
4. Go to **Job Definition** , hit **Create** and enter the following details
    * **Job definition name** :  montecarlo-queue-processor
    * **Job Attempts** : 3
    * **Execution timeout** : 120 
    * **Job role** :  Select the one that appears in drop down, as created during setup
    * **Container image** :  ruecarlo/montecarlo-workshop-worker:latest
    
    > We have created a docker container image containing the required libraries and the Worker code that we used in the previous lab. This container image is stored on [Dockerhub](https://hub.docker.com/r/ruecarlo/montecarlo-workshop-worker/). This is the image that we are pulling for our batch job.
    
    * **vCPUs** : 2
    * **Memory (MiB)** : 512
    * **Environment variables (Key)**  : REGION
    * **Environment variables (Value)**  : Name the region you are using, example us-east-1
    * Leave everything as default and click **Create job Definition**


5. Now we are ready to submit a job (with the definition created above) and run it against the compute environment created above.
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
2. If you monitor the SQS queue for messages you should see them being picked up by the worker container.

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