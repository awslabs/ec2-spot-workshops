---
title: "Batch Sqared Debug"
chapter: false
weight: 37
---

If you want to debug what is going on you may start a container similar to what is started within the `workflow-queue`.

```bash
docker run -ti --rm -e AWS_REGION=${AWS_REGION} \
                    -e NF_SCRIPT=script7.nf \
                    -e BUCKET_NAME_RESULTS=${BUCKET_NAME_RESULTS} \
                    -e AWS_BATCH_JOB_ID=${RANDOM} \
                    ${REPO_URI}:${IMG_TAG} bash
```

That allows you to run the entrypoint script `entrypoint.sh` on your own and see what is happening.

```bash
$ docker run -ti --rm -e AWS_REGION=${AWS_REGION} \
>                     -e NF_SCRIPT=script7.nf \
>                     -e BUCKET_NAME_RESULTS=${BUCKET_NAME_RESULTS} \
>                     -e AWS_BATCH_JOB_ID=${RANDOM} \
>                     ${REPO_URI}:${IMG_TAG} bash
bash-4.2# entrypoint.sh
+ PIPELINE_URL=https://github.com/seqeralabs/nextflow-tutorial.git
+ NF_SCRIPT=script7.nf
+ NF_OPTS=
+ [[ -z us-east-1 ]]
+ [[ https://github.com/seqeralabs/nextflow-tutorial.git =~ ^s3://.* ]]
+ git clone https://github.com/seqeralabs/nextflow-tutorial.git /scratch
Cloning into '/scratch'...
remote: Enumerating objects: 67, done.
remote: Counting objects: 100% (67/67), done.
remote: Compressing objects: 100% (44/44), done.
remote: Total 134 (delta 42), reused 43 (delta 23), pack-reused 67
Receiving objects: 100% (134/134), 457.49 KiB | 7.62 MiB/s, done.
Resolving deltas: 100% (78/78), done.
+ cd /scratch
+ echo '>> Remove container from pipeline config if present.'
>> Remove container from pipeline config if present.
+ sed -i -e /process.container/d nextflow.config
++ sed -e s#s3://##
++ echo nextflow-spot-batch-result-23641-1587713021
+ BUCKET_NAME_RESULTS=nextflow-spot-batch-result-23641-1587713021
+ BUCKET_TEMP_NAME=nextflow-spot-batch-temp-12183
+ aws --region us-east-1 s3 mb s3://nextflow-spot-batch-temp-12183
make_bucket: nextflow-spot-batch-temp-12183
+ nextflow run script7.nf -profile batch -bucket-dir s3://nextflow-spot-batch-temp-12183 --output s3://nextflow-spot-batch-result-23641-1587713021/12183
N E X T F L O W  ~  version 20.01.0
Launching `script7.nf` [zen_allen] - revision: ce58523d1d
R N A S E Q - N F   P I P E L I N E
===================================
transcriptome: /scratch/data/ggal/transcriptome.fa
reads        : /scratch/data/ggal/gut_{1,2}.fq
outdir       : results
WARN: Unable to create AWS Batch helper class | credentials cannot be null
executor >  awsbatch (4)
[c4/2bf496] process > index          [100%] 1 of 1 ✔
[94/8a9200] process > quantification [100%] 1 of 1 ✔
[fa/edc701] process > fastqc         [100%] 1 of 1 ✔
[cd/40a5bb] process > multiqc        [100%] 1 of 1 ✔
Done! Open the following report in your browser --> results/multiqc_report.html
Completed at: 24-Apr-2020 09:15:19
Duration    : 1m 21s
CPU hours   : (a few seconds)
Succeeded   : 4
```
