---
title: "Local Run"
chapter: false
weight: 25
---

## Run pipeline

To check our setup we will run Nextflow on the Cloud9 instance, submitting jobs to AWS Batch.

![nextflow-test-arch](/images/nextflow-on-aws-batch/nextflow202/nextflow-test-arch.png)

### Run AWS Batch Jobs with Nextflow locally

The first use of AWS Batch is upon us. We are going to start Nextflow using the batch profile.

```bash
cd ~/environment/nextflow-tutorial
cat ${HOME}/.nextflow/config  |grep -A5 batch
nextflow run script7.nf -profile batch -bucket-dir s3://${BUCKET_NAME_TEMP} --outdir=s3://${BUCKET_NAME_RESULTS}/batch
```

The output is going to look similar to this:

```bash
$ cat ../.nextflow/config  |grep -A5 batch
  batch {
    aws.region = 'us-east-1'
    process.executor = 'awsbatch'
    process.queue = 'job-queue'
  }
}
$ nextflow run script7.nf -profile batch -bucket-dir s3://${BUCKET_NAME_TEMP} --outdir=s3://${BUCKET_NAME_RESULTS}/batch
N E X T F L O W  ~  version 20.01.0
Launching `script7.nf` [jovial_jones] - revision: ce58523d1d
R N A S E Q - N F   P I P E L I N E
===================================
transcriptome: /home/ec2-user/environment/nextflow-tutorial/data/ggal/transcriptome.fa
reads        : /home/ec2-user/environment/nextflow-tutorial/data/ggal/gut_{1,2}.fq
outdir       : s3://nextflow-spot-batch-result-23641-1587713021
WARN: Unable to create AWS Batch helper class | credentials cannot be null
executor >  awsbatch (4)
[2b/641a4f] process > index          [100%] 1 of 1 ✔
[f0/a87531] process > quantification [100%] 1 of 1 ✔
[08/014db2] process > fastqc         [100%] 1 of 1 ✔
[a1/ced1b8] process > multiqc        [100%] 1 of 1 ✔
Done! Open the following report in your browser --> s3://nextflow-spot-batch-result-23641-1587713021/batch/multiqc_report.html
Completed at: 24-Apr-2020 08:15:40
Duration    : 2m 42s
CPU hours   : (a few seconds)
Succeeded   : 4
```

The `BUCKET_NAME_TEMP` S3 bucket ([deep link](https://s3.console.aws.amazon.com/s3/home)) will store intermediate files from pipelines, which helps to cache executions in case a pipeline is executed twice or needs to restart for some reason.

![temp_bucket](/images/nextflow-on-aws-batch/nextflow202/temp_bucket.png)

### Debug Job

The AWS Batch Job dashboard ([deep link](https://console.aws.amazon.com/batch/home)) shows how jobs are passing through stages.

![job_dash](/images/nextflow-on-aws-batch/nextflow202/job_dash.png)

Using CloudWatch ([deep link](https://console.aws.amazon.com/cloudwatch/home#logStream:group=/aws/batch/job)) one can check the logs.

![job_logs](/images/nextflow-on-aws-batch/nextflow202/job_logs.png)

At the end four jobs should have passed.

![job_dash_end](/images/nextflow-on-aws-batch/nextflow202/job_dash_end.png)
