+++
title = "Seed the database with application data"
weight = 110
+++

1. Browse to the [Amazon RDS console](https://console.aws.amazon.com/rds/home?#dbinstances:) to monitor your database deployment. Click on your database name. Under **Summary**, the **DB instance status** should be **available**. If it isn't quite ready (perhaps still doing the initial backup), you can hit refresh every couple of minutes and wait for it to be in the **available** state.

1. In the **Connectivity & security** section, find the **Endpoint** of the database instance (e.g. **runningamazonec2workloadsatscale.ckhifpaueqm7.us-east-1.rds.amazonaws.com**
).

1. Seed the database for the application environment. Replace **%endpoint%** with the database instance endpoint noted in the last step:

    ```bash
    mysql -h %endpoint% -u dbadmin --password=db-pass-2020 -f koel < koel.sql
    ```

{{% notice note %}}
This command will not return any output if it is successful.
{{% /notice %}}