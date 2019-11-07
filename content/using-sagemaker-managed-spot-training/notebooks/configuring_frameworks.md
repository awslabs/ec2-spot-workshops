---
title: "Configuring Frameworks for Managed Spot Training"
chapter: false
weight: 40
---

## SageMaker Python SDK

The example notebooks available in this workshop leverage the Amazon SageMaker Python SDK to simplify building, training, and hosting models on Amazon SageMaker. Amazon SageMaker Python SDK is an open source library for training and deploying machine-learned models on Amazon SageMaker.

With the SDK, you can train and deploy models using popular deep learning frameworks, algorithms provided by Amazon, or your own algorithms built into SageMaker-compatible Docker images.

When using the SageMaker Python SDK, it's simple to take advantage of Managed Spot Training by passing a couple additional configuraton parameters to an Estimator. An Estimator is a high-level interface for SageMaker training.

The following example configuration when instantiating an estimator demonstrates how Managed Spot Training can be enabled.

```
estimator = sagemaker.estimator.Estimator(
    sagemaker_session=sagemaker_session,
    image_name=image_name,
    role=role,
    train_instance_count=1,
    train_instance_type='ml.c4.xlarge',
    train_use_spot_instances=True,
    train_max_wait=[INTEGER_SECONDS],
    train_max_run=[INTEGER_SECONS],
    base_job_name='[JOB_BASE_NAME]',
    checkpoint_s3_uri="[S3_CHECKPOINT_PATH]",
    output_path="[S3_OUTPUT_PATH]"
)
```

When enabling Managed Spot Training, the relevant configuration options are:

```
    train_use_spot_instances=True,
    train_max_wait=[INTEGER_SECONDS],
    train_max_run=[INTEGER_SECONS],

    and

    checkpoint_s3_uri="[S3_CHECKPOINT_PATH]",
```

* train_use_spot_instances - Specifies whether to use SageMaker Managed Spot instances for training. If enabled then the train_max_wait arg should also be set.
* train_max_wait -  Timeout in seconds waiting for spot training instances (default: None). After this amount of time Amazon SageMaker will stop waiting for Spot instances to become available
* train_max_run - Timeout in seconds for training (default: 24 * 60 * 60). After this amount of time Amazon SageMaker terminates the job regardless of its current status.
* checkpoint_s3_uri - The S3 URI in which to persist checkpoints that the algorithm persists (if any) during training

### Checkpointing

A checkpoint is a snapshot of the state of the model. They can be used with Managed Spot Training. If a training job is interrupted, a snapshot can be used to resume from a previously saved point. This can save training time and minimize the impact of an interruption to your model training.

Snapshots are saved to an Amazon S3 location you specify. You can configure the local path to use for snapshots or use the default. When a training job is interrupted, Amazon SageMaker copies the training data to Amazon S3. When the training job is restarted, the checkpoint data is copied to the local path. It can be used to resume at the checkpoint.

To enable checkpoints, provide an Amazon S3 location. You can optionally provide a local path and choose to use a shared folder.

### Additional Learning

More datails on the configuration options for the Estimator can be found here: [Amazon SageMaker Python SDK - Estimator Documentation](https://sagemaker.readthedocs.io/en/stable/estimators.html)

More details on Managed Spot Training including the Manage Spot Training Lifecycle can be found here: [Managed Spot Training](https://docs.aws.amazon.com/sagemaker/latest/dg/model-managed-spot-training.html)