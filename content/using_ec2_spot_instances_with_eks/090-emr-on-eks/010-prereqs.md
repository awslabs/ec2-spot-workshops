---
title: "Prerequisites"
date: 2021-03-15T16:24:50-04:00
weight: 10
draft: false
---


In this chapter, we will prepare your EKS cluster so that it is integrated with EMR on EKS.

{{% notice note %}}
If you don't have EKS cluster with Spot Managed Node Groups, please review instructions from [start the workshop](/using_ec2_spot_instances_with_eks/010-prerequisites.html), [launch using eksctl](/using_ec2_spot_instances_with_eks/020-eksctl.html), [create Spot managed node groups](/using_ec2_spot_instances_with_eks/040-spotmanagednodegroups.html) and [deploy cluster auto-scaler](/using_ec2_spot_instances_with_eks/070-scaling/deploy_ca.html) modules.
{{% /notice %}}

### Create namespace and RBAC permissions

Let's create a namespace '**spark**' in our EKS cluster. After this, we will use the automation powered by eksctl for creating RBAC permissions and for adding EMR on EKS service-linked role into aws-auth configmap

```
kubectl create namespace spark

eksctl create iamidentitymapping --cluster eksworkshop-eksctl  --namespace spark --service-name "emr-containers"
```

### Enable IAM Roles for Service Account (IRSA)

Your cluster should already have OpenID Connect provider URL. Only configuration that is needed is to associate IAM with OIDC. You can do that by running this command

```
eksctl utils associate-iam-oidc-provider --cluster eksworkshop-eksctl --approve
```

### Create IAM Role for job execution

Let's create the role that EMR will use for job execution. This is the role, EMR jobs will assume when they run on EKS.

```
cat <<EoF > ~/environment/emr-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EoF

aws iam create-role --role-name EMRContainers-JobExecutionRole --assume-role-policy-document file://~/environment/emr-trust-policy.json

```

Next, we need to attach the required IAM policies to the role so it can write logs to s3 and cloudwatch. 
```
cat <<EoF > ~/environment/EMRContainers-JobExecutionRole.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}  
EoF
aws iam put-role-policy --role-name EMRContainers-JobExecutionRole --policy-name EMR-Containers-Job-Execution --policy-document file://~/environment/EMRContainers-JobExecutionRole.json
```

### Update trust relationship for job execution role

Now we need to update the trust relationship between IAM role we just created with EMR service identity.

```
aws emr-containers update-role-trust-policy --cluster-name eksworkshop-eksctl --namespace spark --role-name EMRContainers-JobExecutionRole
```

### Register EKS cluster with EMR

The final step is to register EKS cluster with EMR.

```
aws emr-containers create-virtual-cluster \
--name eksworkshop-eksctl \
--container-provider '{
    "id": "eksworkshop-eksctl",
    "type": "EKS",
    "info": {
        "eksInfo": {
            "namespace": "spark"
        }
    }
}'
```
After you register, you should get confirmation that your EMR virtual cluster is created. A virtual cluster is an EMR concept which means that EMR service is registered to Kubernetes namespace and it can run jobs in that namespace.

```output
    "id": "av6h2hk8fsyu12m5ru8zjg8ht",
    "name": "eksworkshop-eksctl",
    "arn": "arn:aws:emr-containers:xx-xxxx-x:xxxxxxxxxxxx:/virtualclusters/av6h2hk8fsyu12m5ru8zjg8ht"
```


### Create S3 code bucket
Let's create a s3 bucket to upload sample scripts and logs.

```sh
export s3DemoBucket=s3://emr-eks-demo-${ACCOUNT_ID}-${AWS_REGION}
aws s3 mb $s3DemoBucket
```
