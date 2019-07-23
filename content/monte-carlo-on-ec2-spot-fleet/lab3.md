+++
title = "Deploy an Automated Trading Strategy on EC2 Spot Fleet"
weight = 30
+++

Now that we understand the basics of our trading strategy, lets get our hands dirty building out the batch processing pipeline.

![Lab 13 Architecture](/images/monte-carlo-on-ec2-spot-fleet/lab3_arch.png) 

#### Create a standard SQS Queue
We will start by creating a managed message queue to store the batch job parameters.

1. Go to the SQS Console, if you haven't used the service in this region, click **Get Started Now**. Otherwise, click **Create New Queue**.

2. Name your queue *"workshop"*. Select **Standard Queue**. Click **Quick-Create Queue**. 
{{% notice note %}}
Queue Name is Case Sensitive
{{% /notice %}}
![SQS Creation](/images/monte-carlo-on-ec2-spot-fleet/sqs_create.png)
{{% notice info %}}
For regions that don't yet support FIFO queues, the console may look different than shown. Just name the queue and accept the defaults.
{{% /notice %}}

3. Save the queue **ARN** and **URL** for later use.
![SQS Info](/images/monte-carlo-on-ec2-spot-fleet/sqs_info.png)
	
#### Edit the EC2 Instance Profile
Our EC2 instances run with an Instance Profile that contains an IAM role giving the instance permissions to interact with other AWS services. We need to edit the associated policy with permissions to access the SQS service.

1. Go to the EC2 Console.

2. Under **Instances**, select the instance named *montecarlo-workshop*.

3. Scroll down and select the **IAM Role**.

4. You should see two attached policies. One will be an inline policy named after the workshop. Click the arrow beside the policy and click **Edit policy**.
![IAM Role](/images/monte-carlo-on-ec2-spot-fleet/iam_role.png)

5. Click on **Add additional permisions**. Click on **Choose a service** and select or type **SQS**.
![IAM Role](/images/monte-carlo-on-ec2-spot-fleet/iam_role_1.png)

6. Click on **Select actions**. Under *Manual actions*, check the box beside **All SQS actions (sqs:\*)**. 
![IAM Role](/images/monte-carlo-on-ec2-spot-fleet/iam_role_2.png)

7. You will see a warning that you must choose a **queue resource type**. Click anywhere on the orange warning line. Under Resources, click on **Add ARN**.

8. In the pop-up window, paste the *ARN* that you saved previously. Click **Add**.
![IAM Role](/images/monte-carlo-on-ec2-spot-fleet/iam_role_3.png)

9. Click on **Review Policy** and then click **Save changes**.

#### Configure the Web Client
The CloudFormation template deployed a web server that will serve as the user interface. We need to configure it with our SQS queue

1. Launch Web Site using the URL from the CloudFormation output.
2. Click **Configuration**
3. Configure the **SQS URL**, **S3 Bucket Name**, and **AWS Region** using the output values from the CloudFormation stack.
![Web Config](/images/monte-carlo-on-ec2-spot-fleet/web_config.png)
4. Click **Submit** and then click **Home** to return to the home page.

#### Configure our Simulation 
1. Enter you simulation details. You can select whatever values you'd like, but too large of an iteration count, may take a long time to complete. We recommend the following configuration.
	* Stock Symbol (e.g. AMZN)
	* Short Window = 40 days
	* Long Window = 100 days
	* Trading Days  = 1260 (5 years)
	* Iterations = 2000
	* Preview Only = *unchecked* - You can use this to see the json message placed on the queue. 

#### View the messages in SQS
1. Go to the SQS Console and select your queue.

2. Under **Queue Actions**, select **View/Delete Messages**. 

3. Click on **Start Polling for Messages**

4. You should see the message that was created by the web client. Explore the message attributes to see what we will be passing to the worker script

5. Now that we have messages on the queue, lets spin up some workers on EC2 spot instances.


#### Create the Launch Template
1. From the EC2 Console, select **Launch Template** and click **Create Launch Template**

1. Leave **Create New Template**. Name the template `MonteCarlo-Workshop-Template`, and use the same for the 
template version description

1. In the *Launch template content* section, click on the **Search for AMI** and select the default 
Amazon Linux 2 HVM 64-bit(x86) AMI

1. For **Key pair name**, choose the SSH Key Pair that you specified in the CloudFormation template. 

1. Select the VPC with name **VPC for Spot Monte Carlo Simulation Workshop**, Under **Security groups** 
select the name with the prefix *spot-montecarlo workshop*.
![Launch Template](/images/monte-carlo-on-ec2-spot-fleet/launch_template.png)

1. Leave the rest to default, at the bottom of the page click on **Advanced Details**, In the IAM instance profile
select the one with the prefix *spot-montecarlo workshop*. 

1. Finally in the **User Data** content copy the following:

```bash
#!/bin/bash
# Install Dependencies
yum -y install git python3 python-pip3 jq
pip3 install --upgrade pandas-datareader yfinance scipy boto3 awscli matplotlib scipy numpy pandas boto3

#Populate Variables
echo 'Populating Variables'
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
mkdir /home/ec2-user/spotlabworker
chown ec2-user:ec2-user /home/ec2-user/spotlabworker
cd /home/ec2-user/spotlabworker
STACK_NAME=$(aws cloudformation --region $REGION list-stacks | jq -r '.StackSummaries[] | select(.TemplateDescription == "Environment for running EC2 Spot Monte Carlo Workshop"  and .StackStatus == "CREATE_COMPLETE").StackName')
WEBURL=$(aws cloudformation --region $REGION describe-stacks --stack-name $STACK_NAME | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "WebInterface" ).OutputValue ')
	
echo 'Region is '$REGION
echo 'URL is '$WEBURL

echo "Downloading worker code"
wget $WEBURL/static/queue_processor.py
wget $WEBURL/static/worker.py

echo 'Starting the worker processor'
python3 /home/ec2-user/spotlabworker/queue_processor.py --region $REGION> stdout.txt 2>&1
```

1. Save the template

#### Create the Spot Worker Fleet

1. From the EC2 Console, select **Spot Requests** and click **Request Spot Instances**. Then Select **Flexible Instances**

1. Select the Launch Template **MonteCarlo-Workshop-Template** 

1. In the Network section, select the VPC with name **VPC for Spot Monte Carlo Simulation Workshop**, and select 
the two subnets available
![Spot Flexible Instances](/images/monte-carlo-on-ec2-spot-fleet/spot_fleet_flexible_instances_1.png)

1. click on **Maintain Target Capacity** and leave the interruption behaviour to the default "Terminate"

1. Expand the **Advanced Configuration** and select the **Health Check : Replace unhealthy instances**

1. For **Total target Capacity**, type **2**

1. Check the *Fleet request settings* and check the fleet that has been selected. Notice how each entry has
a different Spot price. Feel free to untick the **Apply Recommendations** and change the components in the fleet using: 
c4.large, c5.large, m4.large, m5.large, t2.large, t3.large. Leave "Diversified" as the allocation strategy.
![Instance Fleet Selection](/images/monte-carlo-on-ec2-spot-fleet/spot_fleet_flexible_instances_2.png)

1. Click **Launch**.

1. Wait until the request is fulfilled, capacity shows the specified number of Spot instances, and the status is Active.

1. Once the workers come up, they should start processing the SQS messages automatically. Feel free to create some more jobs from the webpage. Check out the S3 bucket to confirm the results are being processed.


#### Optional: Auto-scale the Worker Fleet on EC2 Spot
In the previous step, we specified two Spot instances, but what if we need to process more than two jobs at once? In this optional section we will configure auto-scaling so that new spot instances are created as more jobs get added to the queue.

1. Go to the CloudWatch console, and click on **Alarms**.

2. Click on **Create Alarm**. Select **SQS Metrics**.

3. Scroll down and select **ApproximateNumberOfMessagesVisible**. Click **Next**
![CW Alarm](/images/monte-carlo-on-ec2-spot-fleet/spot_cw_alarm.png)

4. We will create a threshold for scaling up. Name the alarm, set the threshold for **>= 2** messages for **2** consecutive periods. Delete the default notification actions. Hit **Next** and write a description and a unique name like `Scale Up Spot Fleet`, click on **Create Alarm**.

![CW Alarm](/images/monte-carlo-on-ec2-spot-fleet/spot_cw_alarmfinal.png)

5. Repeat these steps for the scale down policy, use the unique name `Scale Down Spot Fleet` and set the threshold for **<= 1** message for **3** consecutive periods.

6. Return to **Spot Requests** in the EC2 Console.

7. Select your fleet and go to the **Auto Scaling** tab at the bottom pane.

8. Click **Configure**. On the next screen, click on **Scale Spot Fleet using step or simple scaling policies**
![CW Alarm](/images/monte-carlo-on-ec2-spot-fleet/spot_auto_scale.png)

9. Under the **ScaleUp** and **ScaleDown** policies, configure the appropriate alarms under **Policy trigger**.
![CW Alarm](/images/monte-carlo-on-ec2-spot-fleet/spot_auto_scale_final.png)

10. Click **Save**

#### Evaluate the Results
1. Check your S3 Bucket. In a few minutes, you should see results start appearing the bucket. 

2. If you monitor the SQS queue for messages you should see them being picked up by the worker nodes.

#### Terminate the Spot Fleet
In the next lab, we will use [AWS Batch](https://aws.amazon.com/batch/) to create a managed batch process pipeline. We will reuse our existing queue, so let's terminate our EC2 Spot worker fleet.

1. From the EC2 Console, select **Spot Requests** and click **Request Spot Instances**.

2. Check the box beside the Spot fleet request containing your worker nodes.  The correct request will have a capacity of 2 and the shortest time since it was created.

{{% notice warning %}}
Take care not to cancel the Spot fleet request responsible for our workstation node (Jupyter/WebClient). It will have a capacity of 1 and the instance type will be m4.large.
{{% /notice %}}

3. Under **Actions**, select **Cancel Spot request**. 

**You've completed Lab 3, Congrats!**

#### Extra Credit
* Each job is handled fully by one worker. Maybe you could look at adding more parallelism to task scheduler.
