---
title: "Local Run"
chapter: false
weight: 20
---


## Run pipeline 

To check our setup we will run nextflow on the Cloud9 instance, submitting jobs to AWS Batch.

![](/images/nextflow-on-aws-batch/nextflow202/nextflow-test-arch.png)


```
cd ~/environment/nextflow-tutorial
nextflow run script7.nf -profile batch -bucket-dir s3://${BUCKET_NAME_TEMP} --outdir=s3://${BUCKET_NAME_RESULTS} 
```

The output is going to look similar to this:
```
N E X T F L O W  ~  version 20.01.0
Launching `script7.nf` [cheeky_hawking] - revision: ce58523d1d
R N A S E Q - N F   P I P E L I N E    
===================================
transcriptome: /home/ec2-user/environment/nextflow-tutorial/data/ggal/transcriptome.fa
reads        : /home/ec2-user/environment/nextflow-tutorial/data/ggal/gut_{1,2}.fq
outdir       : s3://nextflow-spot-batch-result-10273-1587651187
WARN: Unable to create AWS Batch helper class | credentials cannot be null
executor >  awsbatch (4)
[2b/4a8171] process > index          [100%] 1 of 1 ✔
[73/56b097] process > quantification [100%] 1 of 1 ✔
[ef/232be8] process > fastqc         [100%] 1 of 1 ✔
[bf/ddfd01] process > multiqc        [100%] 1 of 1 ✔
Done! Open the following report in your browser --> s3://nextflow-spot-batch-result-10273-1587651187/multiqc_report.html
Completed at: 23-Apr-2020 14:27:30
Duration    : 3m 52s
CPU hours   : (a few seconds)
Succeeded   : 4
```

The `BUCKET_NAME_TEMP` S3 bucket will store intermediate files from pipelines, which helps to cache executions in case a pipeline is executed twice or needs to restart for some reason.

![](/images/nextflow-on-aws-batch/nextflow202/temp_bucket.png)



### Debug Job 

The AWS Batch Job dashboard shows how jobs are passing through stages.

![](/images/nextflow-on-aws-batch/nextflow202/job_dash.png)

Using CloudWatch one can check the logs.

![](/images/nextflow-on-aws-batch/nextflow202/job_logs.png)

At the end four jobs should have passed.

![](/images/nextflow-on-aws-batch/nextflow202/job_dash_end.png)