---
title: "Right sizing Spark executors"
weight: 40
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}


Building towards running the first Spark application on Amazon EMR Instance Fleets, let's dive deeper into the most important best practice that will allow us to be **flexible** around our EC2 Instance type selection - **right sizing our Spark executors**.

{{% notice note %}}
**Remember!** you might be able to achieve greater utilization and performance optimization when using a single EC2 instance type, but when adopting Spot Instances, the idea is to be as flexible as possible in order to achieve and keep the desired scale to run your Spark applications.
{{% /notice %}}

Today, the developers in your organization run the job on a non-managed Spark cluster using “**spark-submit —executor-memory=72G —executor-cores=16**". This confines the platform to EC2 instance types with a lot of memory and cores to accommodate the size of the executor, and prevents the cluster from running on a diversified set of EC2 instance types. If the Spot interruption rate for the high memory instances will increase, then you will have problems getting and keeping capacity for the clusters, hence we need to right size the executors to fit on smaller instance types and allow for a larger instance type selection. In some cases, smaller instance types will have lower Spot interruption rates. We will find out how to see Spot Interruption rates for the different instance types in the next section.

If we keep approximately the same vCPU:Mem ratio (1:4.5) for our job and avoid going over the recommended Java memory configuration (20-30GB), then we'll conclude that we can optimize our executor configuration by using "--executor-memory=24GB --executor cores=4". However, there are some more limitations in place.

#### Amazon EMR default memory limits for Spark executors

EMR by default places limits on executor sizes in two different ways, this is in order to avoid having the executor consume too much memory and interfere with the operating system and other processes running on the instance. 

1. [for each instance type differently](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hadoop-task-config.html#emr-hadoop-task-jvm) in the default YARN configuration options. 
Let's have a look at a few examples of instances that have our approximate vCPU:Mem ratio:  
r4.xlarge: yarn.scheduler.maximum-allocation-mb	23424  
r4.2xlarge: yarn.scheduler.maximum-allocation-mb 54272  
r5.xlarge: yarn.scheduler.maximum-allocation-mb	24576  
2. With the Spark on YARN configuration option which was [introduced in EMR version 5.22](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-whatsnew-history.html#emr-5220-whatsnew): spark.yarn.executor.memoryOverheadFactor and defaults to 0.1875 (18.75% of the spark.yarn.executor.memoryOverhead setting )


So we can conclude that if we decrease our executor size to ~18GB, we'll be able to use r4.xlarge and basically any of the R family instance types (`1:8 vCPU:Mem ratio`) as vCPU and Memory grows linearly within family sizes. If EMR will select an r4.2xlarge instance type from the list of supported instance types that we'll provide to EMR Instance Fleets, then it will run more than 1 executor on each instance, due to Spark dynamic allocation being enabled by default.

![tags](/images/running-emr-spark-apps-on-spot/sparkmemory.png)

Our conclusion is that in order to use R family instances with the flexibility of also using the smallest supported instance types, we will use **"--executor-memory=18GB --executor-cores=4"** for our Spark application submission.

