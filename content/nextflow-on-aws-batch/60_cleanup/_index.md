---
title: "Clean up the Environment"
chapter: true
weight: 60
---

## Clean Up

### At an AWS event

In case you are using an AWS provided environment you do not need to clean up, as this environment is cleaned up for you.

### On your own

{{% notice warning %}}
Please make sure you are not just **copy&paste** the commands below. Some commands are removing all available resources - so please make sure you only remove what you want to be removed!
{{% /notice %}}

#### S3

We are going to remove all S3 buckets which match the name `nextflow-spot-batch`

```bash
for b in $(aws s3 ls |awk '/nextflow-spot-batch/{print $3}' |xargs); do echo "# aws s3 rb --force s3://$b" ; aws s3 rb --force s3://$b ;done
```

#### ECR

We are going to remove the two images used: `nextflow-rna-seq` & `nextflow-head`

```bash
for x in nextflow-rna-seq nextflow-head;do echo "# aws ecr --region=${AWS_REGION} delete-repository --force --repository-name=$x" ; aws ecr --region=${AWS_REGION} delete-repository --force --repository-name=$x;done
```

#### AWS Batch

##### Job Definitions

We will deregister (remove) the job definitions within AWS Batch. You need to press any key to confirm the removal. Use `STRG+C` to get out.

```bash
for jd in $(aws batch --region=${AWS_REGION} describe-job-definitions |jq -r '.jobDefinitions[] | .jobDefinitionArn' |xargs); do  echo "# aws batch --region=${AWS_REGION} deregister-job-definition --job-definition=${jd}" ; echo "-> (remove? press any key)" ; read ; aws batch --region=${AWS_REGION} deregister-job-definition --job-definition=${jd}; done
```

##### Job Queues

Disable first...

```bash
for jq in $(aws batch --region=${AWS_REGION} describe-job-queues |jq -r '.jobQueues[] |.jobQueueName' |xargs);do echo "# aws batch --region=${AWS_REGION} update-job-queue --state=DISABLED --job-queue=${jq}" ; echo "-> (DISABLE? press any key)" ;read; aws batch --region=${AWS_REGION} update-job-queue   --state=DISABLED --job-queue=${jq};done

```

After this went through, delete the queue. If you did not disable them first, they won't be removed - thus, we skip the confirmation step.

```bash
for jq in $(aws batch --region=${AWS_REGION} describe-job-queues |jq -r '.jobQueues[] |.jobQueueName' |xargs);do echo "# aws batch --region=${AWS_REGION} delete-job-queue --job-queue=${jq}" ; aws batch --region=${AWS_REGION} delete-job-queue --job-queue=${jq};done
```

##### Compute Environment

Disable first... You need to press any key to confirm the removal. Use `STRG+C` to get out.

```bash
for ce in $(aws batch --region=${AWS_REGION} describe-compute-environments |jq -r '.computeEnvironments[] |.computeEnvironmentName' |xargs);do echo "# aws batch --region=${AWS_REGION} update-compute-environment --state=DISABLED --compute-environment=${ce}"  ; echo "-> (DISABLE? press any key)" ; read ; aws batch --region=${AWS_REGION} update-compute-environment --state=DISABLED --compute-environment=${ce} ;done
```

...and delete once the state had changed. If you did not disable them first, they won't be removed - thus, we skip the confirmation step.

```bash
for ce in $(aws batch --region=${AWS_REGION} describe-compute-environments |jq -r '.computeEnvironments[] |.computeEnvironmentName' |xargs);do echo "# aws batch --region=${AWS_REGION} delete-compute-environment --compute-environment=${ce}" ; aws batch --region=${AWS_REGION} delete-compute-environment --compute-environment=${ce} ;done
```

#### Cloud9

Finnaly, go to the [Cloud9 Dashboard](https://console.aws.amazon.com/cloud9/home) and delete your environment.
