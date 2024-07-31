---
title: "Verifying the app's results"
weight: 99
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: That this workshop has been deprecated. For the latest and updated version featuring the newest features, please access the Workshop at the following link: **[Run Spark efficiently on Amazon EMR using EC2 Spot and AWS Graviton](https://catalog.us-east-1.prod.workshops.aws/workshops/d04d8f89-c205-4d1d-81f2-d4d7f7d664c8/en-US)**.
This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for earlier version.
{{% /notice %}}



In this section we will use Amazon Athena to run a SQL query against the results of our Spark application in order to make sure that it completed successfully. We'll compare the results when you didn't interrupt the Spark job when creating the cluster, with the results when you interrupt three Spot task nodes.

1. In the AWS Management Console, go to the [Athena service](https://console.aws.amazon.com/athena/home/query-editor) and verify that you are in the correct region where you ran your EMR cluster.
1. On the right hand side of the screen there's a `Workgroup` dropdown, click it and change it to `SparkResultsWorkGroup` option.

![AthenaWorkgroup](/images/running-emr-spark-apps-on-spot/athena-workgroup.png)

1. Go to the `Saved queries` tab, and open the `EMRWorkshopResults` saved query. This is the query to create the table that uses the S3 bucket as a source where the first Spark job saved its results.
1. Click on the `Run` button.
1. Go to the `Saved queries` tab again, and open the `EMRWorkshopResultsSpot` saved query. This is the query to create the table that uses the S3 bucket as a source where the subsequen Spark job that you interrupted saved its results.
1. To look at some of the results, run this query: 

    ```
    SELECT *
    FROM "EMRWorkshopResults"
    ORDER BY count DESC limit 100;
    ```

1. And to confirm that the number of rows match, run the following commands:

    ```
    SELECT COUNT(*)
    FROM "EMRWorkshopResults";
    ```

    ```
    SELECT COUNT(*)
    FROM "EMRWorkshopResultsSpot";
    ```

1. Both results match.