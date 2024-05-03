---
title: "Deploying Multiple Provisioners"
date: 2021-11-07T11:05:19-07:00
weight: 60
draft: false
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

In the previous sections, we did set up a default Provisioner and did scale a simple application. We did learn also about a few best practices when using Spot and how Karpenter simplifies the application of implementing Spot best practices. The tests that we did were however relatively simple. In the next sections we will extend the previous scenario and cover more concepts relevant to Karpenter Provisioner such as: 

* \(a\) Multi-Architecture deployments 
* \(b\) Using Multiple Provisioners in one cluster.


## Setting up the Provisioners CRD

To start the exercises, let's set up our Provisioner CRD (Custom Resource Definition). We will set up one for the `default`, overriding the previous one we created, and a new Provisioner named `team1`.

{{% notice tip%}}
Spend some time familiarizing yourself with the configuration. You can read more about Provisioner CRD configuration for the AWS Cloud Provider **[here](https://karpenter.sh/docs/concepts/provisioners/)**
{{% /notice %}}

Run the following command to change the configuration of the `default` Provisioner.

```
cat <<EOF | kubectl apply -f -
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
  subnetSelector:
    karpenter.sh/discovery: eksspotworkshop
  securityGroupSelector:
    karpenter.sh/discovery: eksspotworkshop
  tags:
    KarpenerProvisionerName: "default"
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
EOF
```

We will now deploy a secondary Provisioner named `team1`.

```
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: team1
spec:
  labels:
    intent: apps
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64","arm64"]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  ttlSecondsAfterEmpty: 30
  ttlSecondsUntilExpired: 2592000
  taints:
  - effect: NoSchedule
    key: team1
  providerRef:
    name: team1
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: team1
spec:
  amiFamily: Bottlerocket
  subnetSelector:
    karpenter.sh/discovery: eksspotworkshop
  securityGroupSelector:
    karpenter.sh/discovery: eksspotworkshop
  tags:
    KarpenerProvisionerName: "team1"
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
  userData:  |
    [settings.kubernetes]
    kube-api-qps = 30
    [settings.kubernetes.eviction-hard]
    "memory.available" = "20%"
EOF
```

Let's spend some time covering a few points in the Provisioners configuration.

* Both Provisioners set up the label `intent: apps`. This discriminate the capacity from the one that has been set up in the Managed Node group which has a `intent: control-apps`.

* Both of them allow architectures `amd64` (equivalent to x86_64) and `arm64`. The section Multi-Architecture deployments will explain how applications can make use of different architectures.

* The `default` Provisioner does now support both `spot` and `on-demand` capacity types. The `team1` provisioner however does only support `on-demand`

* The `team1` Provisioner does only support Pods or Jobs that provide a Toleration for the key `team1`. Nodes procured by this provisioner will be tainted using the Taint with key `team1` and effect `NoSchedule`.

* The `team1` Provisioner does define a different `AWSNodeTemplate` and changes the AMI from the default [EKS optimized AMI](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) to [bottlerocket](https://aws.amazon.com/bottlerocket/). It does also adapts the UserData bootstrapping for this particular provider. 

* The `default` Provisioner is setting up a weight of 100. The evaluation of provisioners can use weights, this is useful to force scenarios where you want karpenter to evaluate a provisioner before other. The higher the weightthe higher the priority in the evaluation. The first provisioner to match the workload is the one that gets used.


{{% notice note %}}
If Karpenter encounters a taint in the Provisioner that is not tolerated by a Pod, Karpenter won’t use that Provisioner to provision the pod. It is recommended to create Provisioners that are mutually exclusive. So no Pod should match multiple Provisioners. If multiple Provisioners are matched, Karpenter will randomly choose which to use.
{{% /notice %}}


Before closing this section let's confirm that we have the correct configuration. Run the following command to list the current provisioners.

```
kubectl get provisioners
```

The command should list both the `default` and the `team1` provisioner. We can also describe the provisioners and check what is the description for the configuration/CRD. Let's describe the `default` provisioner. You can do the same later on with the `team1` and confirm your changes were applied.

```
kubectl describe provisioners default
```

You can repeat the same commands with `kubectl get AWSNodeTemplate` to check the provider section within the provisioner.