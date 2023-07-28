---
title: "Upgrading Kubernetes nodes"
date: 2021-11-07T11:05:19-07:00
weight: 100
draft: false
---

In the previous section we created a Karpenter provisioner and explored different compute requirements. In this section, we will explore two mechnisms to support upgrades of node provisioned with Karpenter when there is a newer AMI using `ttlSecondsUntilExpired` or Drift. Using these mechnisms can simplify managing operational activities and help you patch at scale.

The `ttlSecondsUntilExpired` provisioner setting can be used to instruct Karpenter to deprovision nodes that have reached an expiry. Karpenter will annotate nodes that have expired and deprovision.  One use case for node expiry is to periodically recycle nodes. Old nodes (with a potentially outdated Kubernetes version or operating system) are deleted, and replaced with nodes on the latest version of the AMI (assuming that you requested the latest version, rather than a specific version).

{{% notice warning %}}
Keep in mind that a small `ttlSecondsUntilExpired` results in a higher churn in cluster activity. For a small enough ttlSecondsUntilExpired, nodes may expire faster than Karpenter can safely deprovision them, resulting in constant node deprovisioning.
{{% /notice %}}

Alternatively, Karpenter drift will annotate nodes as drifted (`karpenter.sh/voluntary-disruption: "drifted"`) and deprovision nodes that have drifted from their desired specification. Checkout the Karpenter drift [documentation](https://karpenter.sh/docs/concepts/deprovisioning/#drift) to see which resources support Drift.

Node deprovisoning uses the K8s Eviction API to respect Pod Disruption Budget (PDBs), while ignoring all non-daemonset pods and static pods. This helps to safely manage your workload during volunrary disruptions.

# Using Drift to upgrade Kubernetes node(s) AMI

1. Enable Drift. Drift is not enabled by default.

```
kubectl edit configmap -n karpenter karpenter-global-settings
```

Change `featureGates.driftEnabled` to true.

```
apiVersion: v1
data:
  ...  
  featureGates.driftEnabled: "true"
```

You need to restart Karpenter for the change to take affect.

```
kubectl rollout restart deploy karpenter -n karpenter
```

2. Simulate drift by modifying the `AWSNodeTemplate` and `amiSelector`.

{{% notice info %}}
If there is no `amiSelector` specified in the AWSNodeTemplate, Karpenter monitors the SSM parameters published for the Amazon EKS optimized AMIs. You can either specify an `amiFamily` (e.g. AL2, Bottlerocket, Ubuntu etc.) for Karpenter to consider a specific AMI family, or leave it blank to default to AL2 AMI (Amazon EKS Optimized Linux AMI). Karpenter will detect when a new AMI is released for the clusters Kubernetes version, and annotate the existing nodes as drifted. Those nodes will be de-provisioned, and replaced with worker nodes with the latest AMI. With this approach, the nodes with older AMIs will be recycled automatically. By using `amiSelector` you have more control on when the nodes would be upgraded. Consider the difference and select the approach suitable for your application. Karpenter currently doesn’t support custom SSM parameters.
{{% /notice %}}

To simulate drift let's update the `default` provisioner and `AWSNodeTemplate` with an old AMI.


```
export AMI_OLD=$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.26/amazon-linux-2/recommended/image_id --region $AWS_REGION --query "Parameter.Value" --output text)

cat << EOF > outdatedami_template.yaml

apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  consolidation:
    enabled: true
  weight: 100
  labels:
    intent: apps
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand","spot"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64","arm64"]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  ttlSecondsUntilExpired: 2592000
  providerRef:
    name: default
---

apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  amiSelector:
    aws::ids: $AMI_OLD
  subnetSelector:
    alpha.eksctl.io/cluster-name: ${CLUSTER_NAME}
  securityGroupSelector:
    alpha.eksctl.io/cluster-name: ${CLUSTER_NAME}
  tags:
    KarpenerProvisionerName: "default"
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
EOF

kubectl apply -f outdatedami_template.yaml
```

Scale a workload and get nodes to checkout the AMI used:

```
kubectl scale deployment inflate --replicas 3

kubectl get nodes

```

You will see a version 1.26 (v1.23.xx-eks-xxxx) when the node is ready.

```
...
ip-10-0-11-157.eu-west-1.compute.internal           Ready    <none>   55s     v1.26.6-eks-a5565ad
ip-10-0-12-106.eu-west-1.compute.internal           Ready    <none>   114s    v1.26.6-eks-a5565ad
...
```

3. Now let's remove the `amiSelector` to enable Karpenter to select the latets AMI from the SSM param.

```
cat << EOF > updated_nodetemplate.yaml
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    alpha.eksctl.io/cluster-name: ${CLUSTER_NAME}
  securityGroupSelector:
    alpha.eksctl.io/cluster-name: ${CLUSTER_NAME}
  tags:
    KarpenerProvisionerName: "default"
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
EOF

kubectl apply -f updated_nodetemplate.yaml

```

Karpenter will detect a drift and start to deprovision.

Watch the Kubernetes nodes upgrade by running the following:

```
kubectl get nodes -w
```

You should see something like this after sometime:

```
ip-10-0-11-131.eu-west-1.compute.internal           Ready                      <none>   47h     v1.27.1-eks-61789d8
ip-10-0-11-187.eu-west-1.compute.internal           Ready                      <none>   80s     v1.27.3-eks-a5565ad
ip-10-0-12-111.eu-west-1.compute.internal           Ready                      <none>   2m19s   v1.27.3-eks-a5565ad
```

You can also check drift related log messages.

```
kubectl -n karpenter logs -l app.kubernetes.io/name=karpenter | grep drift
```

```
2023-07-28T09:43:39.045Z        INFO    controller.deprovisioning       deprovisioning via drift replace, terminating 1 machines ip-10-0-10-12.eu-west-1.compute.internal/m5.large/spot and replacing with machine from types m5a.4xlarge, c6i.4xlarge, c6i.large, m5dn.large, m5dn.2xlarge and 433 other(s)  {"commit": "7131be2-dirty"}
```

## What Have we learned in this section : 

In this section we have learned:
* Two different mechanisms for upgrading Kubernetes nodes AMI, using `ttlSecondsUntilExpired` or Karpenter drift which uses the K8s Eviction API when deprovisioning nodes to respect PDBs.
* Demonstrated how Karpenter drift can be used to promote AMIs between environments using the `amiSelector`.
* Demonstrated how by using Karpenter with Drift or `ttlSecondsUntilExpired` it can help you achieve operations at scale, mobing patching from a point in time strategy to a continous mechnism.
