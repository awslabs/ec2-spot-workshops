---
title: "Clean Up"
date: 2021-09-06T08:51:33Z
weight: 140
---

Before closing this workshop, let's make sure we clean up all the resources we created so we do not incur in unexpected costs.

## S3

To delete an S3 bucket it must be completely empty. Execute these commands to empty your bucket and then delete it.

```bash
aws s3 rm "s3://${BUCKET_NAME}" --recursive
aws s3api delete-bucket --bucket "${BUCKET_NAME}"
```

To learn more about these APIs, see [delete-bucket CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/s3api/delete-bucket.html) and [Emptying a bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/empty-bucket.html).

## ECR

This command will delete the repository and all the images it contains, since we are passing the *force* argument.

```bash
aws ecr delete-repository --registry-id "${REGISTRY_ID}" --force true
```

To learn more about this API, see [delete-repository CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ecr/delete-repository.html).

## AWS Batch

When deleting Batch components, the order matters; a CE cannot be deleted if it is associated to a valid queue, so we have to start by deleting the queue:

### Deleting the job queue

```bash
aws batch delete-job-queue --job-queue "${RENDERING_QUEUE_NAME}"
```

To learn more about this API, see [delete-job-queue CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-job-queue.html).

### Deleting the compute environment

```bash
aws batch delete-compute-environment --compute-environment "${SPOT_COMPUTE_ENV_ARN}"
aws batch delete-compute-environment --compute-environment "${ONDEMAND_COMPUTE_ENV_ARN}"
```

To learn more about this API, see [delete-compute-environment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-compute-environment.html).

### Deregistering the job definition

```bash
aws batch deregister-job-definition --job-definition "${JOB_DEFINITION_NAME}"
```

To learn more about this API, see [deregister-job-definition CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/deregister-job-definition.html).


## Launch Template

```bash
aws ec2 delete-launch-template --launch-template-id "${LAUNCH_TEMPLATE_ID}"
```

To learn more about this API, see [delete-launch-template CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ec2/delete-launch-template.html).

## AWS Cloud9

This command will delete the Cloud9 environment and terminate the EC2 instance connected to it.

```bash
aws cloud9 delete-environment --environment-id "${C9_ENV_ID}"
```

To learn more about this API, see [delete-environment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/cloud9/delete-environment.html).
