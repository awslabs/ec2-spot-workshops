---
title: "Creating the compute environment"
date: 2021-09-06T08:51:33Z
weight: 80
---

Run the following to generate the configuration file that will be used to create the Batch compute environment:

```bash
export RENDERING_COMPUTE_ENV_NAME=RenderingComputeEnvironment

cat <<EoF > ~/compute-environment-config.json
{
    "computeEnvironmentName": "${RENDERING_COMPUTE_ENV_NAME}",
    "type": "MANAGED",
    "state": "ENABLED",
    "computeResources": {
        "type": "SPOT",
        "allocationStrategy": "SPOT_CAPACITY_OPTIMIZED",
        "minvCpus": 0,
        "maxvCpus": 256,
        "desiredvCpus": 100,
        "instanceTypes": [
            "optimal"
        ],
        "subnets": [
            "${SUBNET_1}",
            "${SUBNET_2}",
            "${SUBNET_3}"
        ],
        "securityGroupIds": [
            "${SECURITY_GROUP_ID}"
        ],
        "instanceRole": "ecsInstanceRole",
        "bidPercentage": 100
    }
}
EoF
```

Execute this command to create the Batch compute environment and export its ARN to an environment variable. To learn more about this API, see [create-compute-environment CLI command reference](https://docs.aws.amazon.com/cli/latest/reference/batch/create-compute-environment.html).

```bash
export COMPUTE_ENV_ARN=$(aws batch create-compute-environment --cli-input-json file://compute-environment-config.json | jq -r '.computeEnvironmentArn')
```

Next, you are going to create a job queue that is going to be associated to this compute environment.
