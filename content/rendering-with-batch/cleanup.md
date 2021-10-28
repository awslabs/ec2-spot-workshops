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

### Disabling the resources

Job queues and compute environments have to be disabled bore deleting them:

```bash
aws batch update-job-queue --job-queue "${RENDERING_QUEUE_NAME}" --state DISABLED && \
aws batch update-compute-environment --compute-environment "${SPOT_COMPUTE_ENV_ARN}" --state DISABLED && \
aws batch update-compute-environment --compute-environment "${ONDEMAND_COMPUTE_ENV_ARN}" --state DISABLED
```

To learn more about these APIs, see [update-job-queue CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/update-job-queue.html) and [update-compute-environment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/update-compute-environment.html).

### Deleting the resources

Deleting the job queue:

```bash
aws batch delete-job-queue --job-queue "${RENDERING_QUEUE_NAME}"
```

Deleting the Spot compute environment:

```bash
aws batch delete-compute-environment --compute-environment "${SPOT_COMPUTE_ENV_ARN}"
```

Deleting the OnDemand compute environment:

```bash
aws batch delete-compute-environment --compute-environment "${ONDEMAND_COMPUTE_ENV_ARN}"
```

{{% notice info %}}
If you see an error message with the exception `ClientException` when running any of the commands above, probably the resource is still being modified. Wait some seconds and try it again.
{{% /notice %}}

To learn more about these APIs, see [delete-job-queue CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-job-queue.html) and [delete-compute-environment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-compute-environment.html).

### Deregistering the job definition

```bash
aws batch deregister-job-definition --job-definition "${JOB_DEFINITION_ARN}"
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
