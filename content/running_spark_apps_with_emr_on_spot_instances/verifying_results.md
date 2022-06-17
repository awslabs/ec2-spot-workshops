---
title: "Verifying the app's results"
weight: 140
---

In this section we will use Amazon Athena to run a SQL query against the results of our Spark application in order to make sure that it completed successfully.

1. In the AWS Management Console, go to the [Athena service](https://console.aws.amazon.com/athena/home) and verify that you are in the correct region where you ran your EMR cluster.
1. With "sampledb" selected in the left pane under the **Database** list, paste the following in the query window and hit **Run query**:

        CREATE EXTERNAL TABLE EMRWorkshopresults(
          words string, 
          count bigint)
        stored as parquet
        LOCATION
          's3://<your-s3-results-bucket>/results';

1. When the query completes and the result is **Query successful**, the table with your results has been created.
1. To look at some of the results, run this query: 

        SELECT *
        FROM "EMRWorkshopresults"
        ORDER BY count DESC limit 100
