---
title: "Set up the environment"
date: 2021-11-07T11:05:19-07:00
weight: 10
draft: false
---

Before we install Karpenter, there are a few things that we will need to prepare in our environment for it to work as expected.

## Create the IAM Role and Instance profile for Karpenter Nodes 

Instances launched by Karpenter must run with an InstanceProfile that grants permissions necessary to run containers and configure networking. Karpenter discovers the InstanceProfile using the name `KarpenterNodeRole-${ClusterName}`.

```
export KARPENTER_VERSION=v0.18.1
echo "export KARPENTER_VERSION=${KARPENTER_VERSION}" >> ~/.bash_profile
TEMPOUT=$(mktemp)
curl -fsSL https://karpenter.sh/"${KARPENTER_VERSION}"/getting-started/getting-started-with-eksctl/cloudformation.yaml > $TEMPOUT \
&& aws cloudformation deploy \
  --stack-name Karpenter-${CLUSTER_NAME} \
  --template-file ${TEMPOUT} \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides ClusterName=${CLUSTER_NAME}
```

{{% notice tip %}}
This step may take about 2 minutes. In the meantime, you can [download the file](https://karpenter.sh/v0.18.1/getting-started/getting-started-with-eksctl/cloudformation.yaml) and check the content of the CloudFormation Stack. Check how the stack defines a policy, a role and and Instance profile that will be used to associate to the instances launched. You can also head to the **CloudFormation** console and check which resources does the stack deploy.
{{% /notice %}}

Second, grant access to instances using the profile to connect to the cluster. This command adds the Karpenter node role to your aws-auth configmap, allowing nodes with this role to connect to the cluster.

```
eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster  ${CLUSTER_NAME} \
  --arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME} \
  --group system:bootstrappers \
  --group system:nodes
```

You can verify the entry is now in the AWS auth map by running the following command. 

```
kubectl describe configmap -n kube-system aws-auth
```

## Create KarpenterController IAM Role

Before adding the IAM Role for the service account we need to create the IAM OIDC Identity Provider for the cluster. 

```
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve
```

Karpenter requires permissions like launching instances. This will create an AWS IAM Role, Kubernetes service account, and associate them using [IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)

```
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME --name karpenter --namespace karpenter \
  --role-name "${CLUSTER_NAME}-karpenter" \
  --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/KarpenterControllerPolicy-$CLUSTER_NAME \
  --role-only \
  --approve
```

{{% notice note %}}
This step may take up to 2 minutes. eksctl will create and deploy a CloudFormation stack that defines the role and create the kubernetes resources that define the Karpenter `serviceaccount` and the `karpenter` namespace that we will use during the workshop. You can also check in the **CloudFormation** console, the resources this stack creates.
{{% /notice %}}

## Create the EC2 Spot Linked Role

Finally, we will create the spot [EC2 Spot Linked role](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html#service-linked-roles-spot-instance-requests).

{{% notice warning %}}
This step is only necessary if this is the first time you’re using EC2 Spot in this account. If the role has already been successfully created, you will see: *An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.* . Just ignore the error and proceed with the rest of the workshop.
{{% /notice %}}

```
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```
