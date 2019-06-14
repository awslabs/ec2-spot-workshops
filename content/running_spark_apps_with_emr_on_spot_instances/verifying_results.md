---
title: "Verifying the job's results"
weight: 140
draft: true
---

In this section we will use Amazon Athena to run a SQL query against the results of our Spark application in order to make sure that the job finished successfully.

1. In the AWS Management Console, go to the [Athena service] (https://console.aws.amazon.com/athena/home) and verify that you are in the correct region where you ran your EMR cluster.
2. With "sampledb" selected in the left pane under the **Database** list, paste the following in the query window and hit **Run query**:

```sql
CREATE EXTERNAL TABLE EMRWorkshopresults(
  words string, 
  count bigint)
stored as parquet
LOCATION
  's3://<your-s3-results-bucket>/results';
```
3. When the query completes and the result is **Query successful**, the table with your results has been created.
4. To look at some of the results, run this query: 

```sql 
SELECT *
FROM "EMRWorkshopresults"
ORDER BY count DESC limit 100
```