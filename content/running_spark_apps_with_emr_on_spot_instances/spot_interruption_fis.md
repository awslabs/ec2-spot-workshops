---
title: "Interrupting a Spot Instance"
weight: 98
---

In this section, you're going to launch a Spot Interruption using FIS and then verify that the capacity has been replenished and EMR was able to continue running the Spark job. This will help you to confirm the low impact of your workloads when implemeting Spot effectively. Moreover, you can discover hidden weaknesses, and make your workloads fault-tolerant and resilient.

#### (Optional) Re-Launch the Spark Application

The Spark job could take around seven to eight minutes to finish. However, when you arrive to this part of the workshop, either the job is about to finish or has finished already. So, here are the commands you need to run to re-laun the Spark job in EMR.

First, you need to empty the results folder in the S3 bucket. Run the following command (replace the bucket name with yours):

```
export S3_BUCKET=your_bucket_name
aws s3 rm --recursive s3://$S3_BUCKET/results/
```

Then, get the EMR cluster ID and replace it with `YOUR_CLUSTER_ID` in the following command to re-launch the Spark application:

```
aws emr add-steps --cluster-id YOUR_CLUSTER_ID --steps Type=CUSTOM_JAR,Name="Spark application",Jar="command-runner.jar",ActionOnFailure=CONTINUE,Args=[spark-submit,--deploy-mode,cluster,--executor-memory,18G,--executor-cores,4,s3://$S3_BUCKET/script.py,s3://$S3_BUCKET/results/]
```

Now go ahead an run the Spot interruption experiment before the jobs completes.

#### Launch the Spot Interruption Experiment
After creating the experiment template in FIS, you can start a new experiment to interrupt three (unless you changed the template) Spot instances. Run the following command:

```
FIS_EXP_TEMP_ID=$(aws cloudformation describe-stacks --stack-name $FIS_EXP_NAME --query "Stacks[0].Outputs[?OutputKey=='FISExperimentID'].OutputValue" --output text)
FIS_EXP_ID=$(aws fis start-experiment --experiment-template-id $FIS_EXP_TEMP_ID --no-cli-pager --query "experiment.id" --output text)
```

Wait around 30 seconds, and you should see that the experiment completes. Run the following command to confirm:

```
aws fis get-experiment --id $FIS_EXP_ID --no-cli-pager
```

At this point, FIS has triggered a Spot interruption notice, and in two minutes the instances will be terminated.

Go to CloudWatch Logs group `/aws/events/spotinterruptions` to see which instances are being interrupted. 

You should see a log message like this one:

![SpotInterruptionLog](/images/running-emr-spark-apps-on-spot/spotinterruptionlog.png)

#### Verify that EMR Instance Fleet replenished the capacity

Run the following command to get an understanding of how many instances are currently running before the Spot interruption:

```
aws ec2 describe-instances --filters\
 Name='tag:aws:elasticmapreduce:instance-group-role',Values='TASK'\
 Name='instance-state-name',Values='running'\
 | jq '.Reservations[].Instances[] | "Instance with ID:\(.InstanceId) launched at \(.LaunchTime)"'
```

You should see a list of instances with the date and time when they were launched, like this:

```output
"Instance with ID:i-06a82769173489f32 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-06c97b509c5e274e0 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-002b073c6479a5aba launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-0e96071afef3fc145 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-0a3ddb3903526c712 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-05717d5d7954b0250 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-0bcd467f88ddd830e launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-04c6ced30794e965b launched at 2022-04-06T14:02:49+00:00"
```

Wait around three minutes while the interrupted instances terminates, and the new instances finish bootstrapping. Run the previous command again to confirm that the new Spot instances are running, and the output will be like the following:

```output
"Instance with ID:i-06a82769173489f32 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-06c97b509c5e274e0 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-002b073c6479a5aba launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-0e96071afef3fc145 launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-04c6ced30794e965b launched at 2022-04-06T14:02:49+00:00"
"Instance with ID:i-0136152e14053af81 launched at 2022-04-06T14:11:25+00:00"
"Instance with ID:i-0ff78141712e93850 launched at 2022-04-06T14:11:25+00:00"
"Instance with ID:i-08818dc9ba688c3da launched at 2022-04-06T14:11:25+00:00"
```

Notice how the launch time from the last instances are different from the others.

#### Verify that the Spark application completed successfully

Follow the same steps from ["Examining the cluster"](/running_spark_apps_with_emr_on_spot_instances/examining_cluster.html) to launch the Spark History Server and explore the details of the recent Spark job submission. In the home screen, click on the latest App ID (if it's empty, wait for the job to finish) to see the execution details. You should see something like this:

![SparkJobCompleted](/images/running-emr-spark-apps-on-spot/sparkjobcompleted.png)

Notice how two minutes around after the job started, three executors were removed (each executor is a Spot instance). The job didn't stop, and when the new Spot instances were launched by EMR, Spark included them as new executors again to catch-up on completing the job. The job took around eight minutes to finish. If you don't see executors being added, you could re-launch the Spark job and start the FIS experiment right away.