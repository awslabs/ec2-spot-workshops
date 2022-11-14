---
title: "Automations and monitoring"
weight: 145
---

{{% notice note %}}
If you're running out of time for the workshop, leave this section for diving deep later on how to automate the cluster creation, and how to monitor key metrics using CloudWatch.
{{% /notice %}}

When adopting EMR into your analytics flows and data processing pipelines, you will want to launch EMR clusters and run jobs in a programmatic manner. There are many ways to do so with AWS SDKs that can run in different environments like Lambda Functions, invoked by AWS Data Pipeline or AWS Step Functions, with third party tools like Apache Airflow, and more.

#### Examine the JSON configuration for EMR Instance Fleets
In this section we will simply look at a CLI command that can be used to start an identical cluster to the one we started from the console. This makes it easy to configure your EMR clusters with the AWS Management Console and get a CLI runnable command with one click.

1. In the AWS Management Console, under the EMR service, go to your cluster, and click the **AWS CLI export** button.
2. Find the --instance-fleets parameter, and copy the contents of the parameter including the brackets:
![cliexport](/images/running-emr-spark-apps-on-spot/cliexport.png)
3. Paste the data into a JSON validator like [JSON Lint](https://jsonlint.com/) and validate the JSON file. this will make it easy to see the Instance Fleets configuration we configured in the console, in a JSON format, that can be re-used when you launch your cluster programmatically. 

Here's an example of the command to create the cluster we used during this workshop:

```
aws emr create-cluster --os-release-label 2.0.20221004.0 --applications Name=Hadoop Name=Spark Name=Ganglia --tags 'Name=emr-spot-workshop' --ec2-attributes '{"KeyName":"emr-workshop-key-pair","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"subnet-00000000000000000","EmrManagedSlaveSecurityGroup":"sg-00000000000000000","EmrManagedMasterSecurityGroup":"sg-00000000000000000"}' --release-label emr-5.36.0 --log-uri 's3n://aws-logs-000000000000-us-east-2/elasticmapreduce/' --steps '[{"Args":["spark-submit","--deploy-mode","cluster","--executor-memory","18G","--executor-cores","4","s3://spark-app-000000000000/script.py","s3://spark-app-000000000000/results/"],"Type":"CUSTOM_JAR","ActionOnFailure":"CONTINUE","Jar":"command-runner.jar","Properties":"","Name":"Spark application"}]' --instance-fleets '[{"InstanceFleetType":"CORE","TargetOnDemandCapacity":4,"TargetSpotCapacity":0,"LaunchSpecifications":{"OnDemandSpecification":{"AllocationStrategy":"LOWEST_PRICE"}},"InstanceTypeConfigs":[{"WeightedCapacity":4,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"m5.xlarge"}],"Name":"Core - 2"},{"InstanceFleetType":"MASTER","TargetOnDemandCapacity":1,"TargetSpotCapacity":0,"LaunchSpecifications":{"OnDemandSpecification":{"AllocationStrategy":"LOWEST_PRICE"}},"InstanceTypeConfigs":[{"WeightedCapacity":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"m5.xlarge"}],"Name":"Master - 1"},{"InstanceFleetType":"TASK","TargetOnDemandCapacity":0,"TargetSpotCapacity":0,"LaunchSpecifications":{"OnDemandSpecification":{"AllocationStrategy":"LOWEST_PRICE"},"SpotSpecification":{"TimeoutDurationMinutes":60,"AllocationStrategy":"CAPACITY_OPTIMIZED","TimeoutAction":"TERMINATE_CLUSTER"}},"InstanceTypeConfigs":[{"WeightedCapacity":16,"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5d.4xlarge"},{"WeightedCapacity":16,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":64,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r4.4xlarge"},{"WeightedCapacity":4,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5a.xlarge"},{"WeightedCapacity":16,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":64,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5a.4xlarge"},{"WeightedCapacity":8,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5.2xlarge"},{"WeightedCapacity":4,"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5d.xlarge"},{"WeightedCapacity":4,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r4.xlarge"},{"WeightedCapacity":8,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5b.2xlarge"},{"WeightedCapacity":8,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r4.2xlarge"},{"WeightedCapacity":4,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5.xlarge"},{"WeightedCapacity":16,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":64,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5.4xlarge"},{"WeightedCapacity":8,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5a.2xlarge"},{"WeightedCapacity":4,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5b.xlarge"},{"WeightedCapacity":16,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":64,"VolumeType":"gp2"},"VolumesPerInstance":4}]},"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5b.4xlarge"},{"WeightedCapacity":8,"BidPriceAsPercentageOfOnDemandPrice":100,"InstanceType":"r5d.2xlarge"}],"Name":"Task - 3"}]' --ebs-root-volume-size 10 --service-role EMR_DefaultRole --enable-debugging --auto-termination-policy '{"IdleTimeout":3600}' --managed-scaling-policy '{"ComputeLimits":{"MaximumOnDemandCapacityUnits":4,"UnitType":"InstanceFleetUnits","MaximumCapacityUnits":68,"MinimumCapacityUnits":4,"MaximumCoreCapacityUnits":4}}' --name 'emr-spot-workshop' --scale-down-behavior TERMINATE_AT_TASK_COMPLETION --region us-east-2
```

### Using CloudWatch Metrics

EMR emits several useful metrics to CloudWatch metrics. You can use the AWS Management Console to look at the metrics in two ways:  

1. In the EMR console, under the **Monitoring** tab in your cluster's page  
1. By browsing to the CloudWatch service, and under Metrics, searching for the name of your cluster (copy it from the EMR Management Console) and clicking **EMR > Job Flow Metrics**

{{% notice note %}}
The metrics will take a few minutes to populate.
{{% /notice %}}

Some notable metrics:

* **AppsRunning** - you should see 1 since we only submitted one step to the cluster.  
* **ContainerAllocated** - this represents the number of containers that are running on core and task fleets. These would the be Spark executors and the Spark Driver.   
* **Memory allocated MB** & **Memory available MB** - you can graph them both to see how much memory the cluster is actually consuming for the wordcount Spark application out of the memory that the instances have.  

#### Set up Amazon EventBridge Rules for Cluster and/or Step failures
Much like we set up an EventBridge rule for EC2 Spot Interruptions to be sent to CloudWatch Logs, we can also set up rules to send out notifications or perform automations when an EMR cluster fails to start, or a Task on the cluster fails. This is useful for monitoring purposes.

In this example, let's set up a notification for when our EMR step failed.  

1. In the AWS Management Console, go to Amazon EventBridge -> Events -> Rules and click **Create Rule**.  
1. Type a name for the rule like `EMRStatusChange`, and click on the `Next` button.
1. Scroll down to the `Event pattern` section, and under the `AWS service` dropdown, choose `EMR`.
1. Under the `Event type` dropdown, select `State Change`.  
1. Check **Specific detail type(s)** and from the dropdown menu, select **EMR Step Status Change**  
1. Check **Specific states(s)** and from the dropdown menu, select **FAILED**.  
1. Click on the `Next` button.
1. In the `Target 1` section, check the `AWS service` option, select **SNS topic** and from the dropdown menu, select the SNS topic you created (if you don't have one, create one, go back to this screen, and click on the cycle button to refresh the dropdown).  
1. Click on the `Next` button.
1. Skip the `Tags` configuration, and click on the `Next` button again.
1. Scroll down, and click on the `Create rule` button.  
1. You can test that the rule works by following the same steps to start a cluster, but providing a bad parameter when submitting the step, for example - a non existing location for the Spark application or results bucket.