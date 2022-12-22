---
title: "Clean Up"
date: 2021-09-06T08:51:33Z
weight: 150
---

Before closing this workshop, let's make sure we clean up all the resources we created so we do not incur in unexpected costs.

## S3 and ECR

To be able to delete an S3 bucket or an ECR repository, they must be completely empty. Execute these commands to empty your bucket and delete the image that you pushed to your repository:

```
aws s3 rm "s3://${BucketName}" --recursive
aws ecr batch-delete-image --repository-name "${RepositoryName}" --image-ids imageTag=latest
```

To learn more about these APIs, see [Emptying a bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/empty-bucket.html) and [batch-delete-image CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ecr/batch-delete-image.html).

## AWS Batch

When deleting AWS Batch components, the order matters; a Compute Environment cannot be deleted if it is associated to a valid queue, so we have to start by deleting the queue. Job Queues and Compute Environments have to be disabled before deleting them.

To disable the components:

```
aws batch update-job-queue --job-queue "${JOB_QUEUE_ARN}" --state DISABLED && \
aws batch update-compute-environment --compute-environment "${SPOT_COMPUTE_ENV_ARN}" --state DISABLED && \
aws batch update-compute-environment --compute-environment "${ONDEMAND_COMPUTE_ENV_ARN}" --state DISABLED
```

To learn more about these APIs, see [update-job-queue CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/update-job-queue.html) and [update-compute-environment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/update-compute-environment.html).

{{% notice info %}}
The previous operation may take up to 2 minutes. Job queues and compute environments cannot be deleted while being modified, so running the commands below while the compute environments and job queue are being disabled might result in an error with the message "resource is being modified".
{{% /notice %}}

To delete the components:

```
aws batch delete-job-queue --job-queue "${JOB_QUEUE_ARN}"
aws batch delete-compute-environment --compute-environment "${SPOT_COMPUTE_ENV_ARN}"
aws batch delete-compute-environment --compute-environment "${ONDEMAND_COMPUTE_ENV_ARN}"
```

To learn more about these APIs, see [delete-job-queue CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-job-queue.html) and [delete-compute-environment CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/delete-compute-environment.html).

Finally, deregister the job definition:

```
aws batch deregister-job-definition --job-definition "${JOB_DEFINITION_ARN}"
```

To learn more about this API, see [deregister-job-definition CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/batch/deregister-job-definition.html).

## Deleting the CloudFormation stack

Deleting the CloudFormation Stack will delete all the resources it created. To do that, navigate to [CloudFormation in the AWS Console](https://console.aws.amazon.com/cloudformation/home), select the stack **MonteCarloWithBatch** and delete it.
