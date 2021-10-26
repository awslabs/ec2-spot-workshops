---
title: "Clean Up"
date: 2021-09-06T08:51:33Z
weight: 150
---

Before closing this workshop, let's make sure we clean up all the resources we created so we do not incur in unexpected costs.

## S3

To be able to delete an S3 bucket, it must be completely empty. Execute this command to empty your bucket:

```bash
aws s3 rm "s3://${BucketName}" --recursive
```

To learn more about this API, see [Emptying a bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/empty-bucket.html).

## ECR

To be able to delete an ECR repository, it must not contain any image. Execute this command to delete the image that you pushed:

```bash
aws ecr batch-delete-image --repository-name "${RepositoryName}" --image-ids imageTag=latest
```

To learn more about this API, see [batch-delete-image CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ecr/batch-delete-image.html).

## AWS Batch

When deleting Batch components, the order matters; a CE cannot be deleted if it is associated to a valid queue, so we have to start by deleting the queue:

### Deleting the job queue

A job queue must be disabled in order to delete it.

```bash
aws batch update-job-queue --job-queue "${RENDERING_QUEUE_NAME}" --state DISABLED && \
aws batch delete-job-queue --job-queue "${RENDERING_QUEUE_NAME}"
```

To learn more about this API, see [delete-job-queue CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-job-queue.html).

### Deleting the compute environment

As with the job queue, the compute environment must be disabled first.

```bash
aws batch update-compute-environment --compute-environment "${SPOT_COMPUTE_ENV_ARN}" --state DISABLED && \
aws batch update-compute-environment --compute-environment "${ONDEMAND_COMPUTE_ENV_ARN}" --state DISABLED && \
```

Then, delete them with these commands:

```bash
aws batch delete-compute-environment --compute-environment "${SPOT_COMPUTE_ENV_ARN}" && \
aws batch delete-compute-environment --compute-environment "${ONDEMAND_COMPUTE_ENV_ARN}"
```

{{% notice info %}}
If you see the following output: **An error occurred (ClientException) when calling the DeleteComputeEnvironment operation: Cannot delete, resource is being modified**, is because either of the environments are still being modified. Wait some seconds and execute the commands again.
{{% /notice %}}

To learn more about this API, see [delete-compute-environment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-compute-environment.html).

### Deregistering the job definition

```bash
aws batch deregister-job-definition --job-definition "${JOB_DEFINITION_NAME}"
```

To learn more about this API, see [deregister-job-definition CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/deregister-job-definition.html).

## AWS FIS

You can delete the experiment template with the following command:

```bash
aws fis delete-experiment-template --id "${EXPERIMENT_TEMPLATE_ID}"
```

To learn more about this API, see [delete-experiment-template CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/fis/delete-experiment-template.html).

## Deleting the CloudFormation stack

Deleting the CloudFormation Stack will delete all the resources it created. To do that, navigate to [CloudFormation in the AWS Console](https://console.aws.amazon.com/cloudformation/home), select the stack **RenderingWithBatch** and delete it.
