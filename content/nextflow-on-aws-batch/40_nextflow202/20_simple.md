---
title: "Local Run"
chapter: false
weight: 20
---


## Run pipeline 

To check our setup we will run nextflow on the Cloud9 instance, submitting jobs to AWS Batch.

![](/images/nextflow-on-aws-batch/nextflow202/nextflow-test-arch.png)


```
nextflow run script7.nf -profile batch -w s3://${BUCKET_NAME}
```

```
N E X T F L O W  ~  version 20.01.0
Launching `script7.nf` [awesome_euclid] - revision: ce58523d1d
R N A S E Q - N F   P I P E L I N E    
===================================
transcriptome: /home/ec2-user/environment/nextflow-tutorial/data/ggal/transcriptome.fa
reads        : /home/ec2-user/environment/nextflow-tutorial/data/ggal/gut_{1,2}.fq
outdir       : results
executor >  awsbatch (4)
[0d/87999e] process > index          [100%] 1 of 1 ✔
[22/58896c] process > quantification [100%] 1 of 1 ✔
[df/5a3dfb] process > fastqc         [100%] 1 of 1 ✔
[31/61eb3a] process > multiqc        [100%] 1 of 1 ✔
Done! Open the following report in your browser --> results/multiqc_report.html
Completed at: 30-Mar-2020 10:21:57
Duration    : 2m 51s
CPU hours   : (a few seconds)
Succeeded   : 4
```
