---
title: "Launch a cluster - Step 1"
weight: 60
---

In this step we'll launch our first cluster, which will run solely on Spot Instances. We will also submit an EMR step for a simple wordcount Spark application which will run against a public dataset of Amazon product reviews, located in an Amazon S3 bucket in the N. Virginia region. If you want to know more about the Amazon Customer Reviews Dataset, [click here] (https://s3.amazonaws.com/amazon-reviews-pds/readme.html)
{{% notice note %}}
Normally our dataset on S3 would be located in the same region where we are going to run our EMR clusters. In this workshop, it is fine if you are running EMR in a different region, and the Spark application will work against the dataset which is located in the N. Virginia region. This will be negligible in terms of price and performance.
{{% /notice %}}

To launch the cluster, follow these steps:

1. [Open the EMR console] (https://console.aws.amazon.com/elasticmapreduce/home) in the region where you are looking to launch your cluster.  
1. Click "**Create Cluster**"  
1. Click "**Go to advanced options**"  
1. Select the latest EMR release, and in the list of components, only leave **Hadoop** checked and also check **Spark** and **Ganglia** (we will use it later to monitor our cluster)  
1. Under "**Steps (Optional)**" -> Step type drop down menu, select "**Spark application**" and click **Add step**, then add the following details in the Add step dialog window:  

* **Spark-submit options**: here we will configure the memory and core count for each executor, as described in the previous section. Use these settings (make sure you have two '-' chars):  
```
--executor-memory 18G --executor-cores 4
```
* **Application location**: here we will configure the location of our Spark application. Save the following python code to a file (or download it from the Attachment box) and upload it to your S3 bucket using the AWS management console. You can refer to the [S3 Getting Started guide] (https://docs.aws.amazon.com/AmazonS3/latest/gsg/PuttingAnObjectInABucket.html) for detailed instructions

```python
import sys
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName('Amazon reviews word count').getOrCreate()
df = spark.read.parquet("s3://amazon-reviews-pds/parquet/")
df.selectExpr("explode(split(lower(review_body), ' ')) as words").groupBy("words").count().write.mode("overwrite").parquet(sys.argv[1])
exit()
```
{{%attachments style="orange" /%}}


Then add the location of the file under the **Application location** field, i.e: s3://\<your-bucket-name\>/script.py

* **Arguments**: Here we will configure the location of where Spark will write the results of the job. Enter: s3://\<your-bucket-name\>/results/  
* **Action on failure**: Leave this on *Continue* and click **Add** to save the step.

![sparksubmit](/images/running-emr-spark-apps-on-spot/sparksubmitstep1.png)

In the **After last step completes** selection, make sure that the "**Clusters enters waiting state**" option is checked. Since we are looking to examine the cluster during and after the Spark application run, we might end up with a terminated cluster before we complete the next steps in the workshop, if we opt to auto-terminate the cluster after our step is completed.

{{% notice note %}}
**Auto-terminate cluster after the last step is completed** is a powerful EMR feature that is used for running transient clusters. This is an effective model for clusters that perform periodic processing tasks, such as a daily data processing run, event-driven ETL workloads, etc.
We will not be running a transient cluster, since it might terminate before we complete some of the next steps in the workshop.
{{% /notice %}}

Click **Next** to continue setting up the EMR cluster and move from "**Step 1: Software and steps**"" to "**Step 2: Hardware**".
