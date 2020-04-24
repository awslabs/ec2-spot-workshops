---
title: "Clean up the Environment"
chapter: true
weight: 60
---

## Clean Up!

### At an AWS event

In case you are using an AWS provided environment you do not need to clean up, as this environment is cleaned up for you.

### On your own

#### S3

```bash
for b in $(aws s3 ls |awk '/nextflow-spot-batch/{print $3}' |xargs); do echo "# aws s3 rb --force s3://$b" ; aws s3 rb --force s3://$b ;done
```

#### ECR

```
for x in $(aws ecr --region=${AWS_REGION}  describe-repositories |jq -r '.repositories[] | .repositoryName' |xargs);do echo "# aws ecr --region=${AWS_REGION} delete-repository --force --repository-name=$x" ; aws ecr --region=${AWS_REGION} delete-repository --force --repository-name=$x;done
```

#### AWS Batch

##### Job Definitions

```bash
for jd in $(aws batch --region=${AWS_REGION} describe-job-definitions |jq -r '.jobDefinitions[] | .jobDefinitionArn' |xargs); do  echo "# aws batch --region=${AWS_REGION} deregister-job-definition --job-definition=${jd}" ; aws batch --region=${AWS_REGION} deregister-job-definition --job-definition=${jd}; done
```

##### Job Queues

Disable first...

```bash
for jq in $(aws batch --region=${AWS_REGION} describe-job-queues |jq -r '.jobQueues[] |.jobQueueName' |xargs);do echo "# aws batch --region=${AWS_REGION} update-job-queue --state=DISABLED --job-queue=${jq}" ; aws batch --region=${AWS_REGION} update-job-queue   --state=DISABLED --job-queue=${jq};done

```

After this went through, delete the queue

```bash
for jq in $(aws batch --region=${AWS_REGION} describe-job-queues |jq -r '.jobQueues[] |.jobQueueName' |xargs);do echo "# aws batch --region=${AWS_REGION} delete-job-queue --job-queue=${jq}" ; aws batch --region=${AWS_REGION} delete-job-queue --job-queue=${jq};done
```

##### Compute Environment

Disable first...

```bash
for ce in $(aws batch --region=${AWS_REGION} describe-compute-environments |jq -r '.computeEnvironments[] |.computeEnvironmentName' |xargs);do echo "# aws batch --region=${AWS_REGION} update-compute-environment --state=DISABLED --compute-environment=${ce}" ; aws batch --region=${AWS_REGION} update-compute-environment --state=DISABLED --compute-environment=${ce} ;done
```

...and delete once the state had changed:

```bash
for ce in $(aws batch --region=${AWS_REGION} describe-compute-environments |jq -r '.computeEnvironments[] |.computeEnvironmentName' |xargs);do echo "# aws batch --region=${AWS_REGION} delete-compute-environment --compute-environment=${ce}" ; aws batch --region=${AWS_REGION} delete-compute-environment --compute-environment=${ce} ;done
```

#### Cloud9

Finnaly, go to the [Cloud9 Dashboard](https://console.aws.amazon.com/cloud9/home) and delete your environment.