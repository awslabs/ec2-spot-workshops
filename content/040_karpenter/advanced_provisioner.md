---
title: "Deploying Multiple Provisioners"
date: 2021-11-07T11:05:19-07:00
weight: 50
draft: false
---

In the previous sections, we did set up a default Provisioner and did scale a simple application. We did learn also about a few best practices when using Spot and how Karpenter simplifies the application of implementing Spot best practices. The tests that we did were however relatively simple. In the next sections we will extend the previous scenario and cover more concepts relevant to Karpenter Provisioner such as: 

* \(a\) Multi-Architecture deployments 
* \(c\) Using Multiple Provisioners in one cluster.

## Setting up the Provisioners CRD

To start the exercises, let's set up our Provisioner CRD (Custom Resource Definition). We will set up one for the `default`, overriding the previous one we created, and a new Provisioner named `team1`.

{{% notice tip%}}
Spend some time familiarizing yourself with the configuration. You can read more about Provisioner CRD configuration for the AWS Cloud Provider **[here](https://karpenter.sh/docs/cloud-providers/aws/)**
{{% /notice %}}

Run the following command to change the configuration of the `default` Provisioner.

```
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  labels:
    intent: apps
  requirements:
    - key: node.k8s.aws/capacity-type
      operator: In
      values: ["on-demand","spot"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64","arm64"]
  provider:
    apiVersion: extensions.karpenter.sh/v1alpha1
    kind: AWS
    cluster:
      endpoint: ${CLUSTER_ENDPOINT}
      name: ${CLUSTER_NAME}
    instanceProfile: KarpenterNodeInstanceProfile-${CLUSTER_NAME}
  ttlSecondsAfterEmpty: 30
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
    - key: node.k8s.aws/capacity-type
      operator: In
      values: ["on-demand"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64","arm64"]
  provider:
    apiVersion: extensions.karpenter.sh/v1alpha1
    kind: AWS
    cluster:
      endpoint: ${CLUSTER_ENDPOINT}
      name: ${CLUSTER_NAME}
    instanceProfile: KarpenterNodeInstanceProfile-${CLUSTER_NAME}
  taints:
  - effect: NoSchedule
    key: team1
  ttlSecondsAfterEmpty: 30
EOF
```

Let's spend some time covering a few points in the Provisioners configuration.

* Both Provisioners set up the label `intent: apps`. This discriminate the capacity from the one that has been set up in the Managed Node group which has a `intent: control-apps`.

* Both of them allow architectures `amd64` (equivalent to x86_64) and `arm64`. The section Multi-Architecture deployments will explain how applications can make use of different architectures.

* The `default` Provisioner does now support both `spot` and `on-demand` capacity types. The `team1` provisioner however does only support `on-demand`

* The `team1` Provisioner does only support Pods or Jobs that provide a Toleration for the key `team1`. Nodes procured by this provisioner will be tainted using the Taint with key `team1` and effect `NoSchedule`.

Before closing this section let's confirm that we have the correct configuration. Run the following command to list the current provisioners.

```
kubectl get provisioners
```

The command should list both the `default` and the `team1` provisioner. We can also describe the provisioners and check what is the description for the configuration/CRD. Let's describe the `default` provisioner. You can do the same later on with the `team1` and confirm your changes were applied.

```
kubectl describe provisioners default
```

## (Optional Read) Customizing AMIs and Node Bootstrapping 

{{% notice info %}}
In this workshop we will stick to the default AMI's used by Karpenter. This section does not contain any exercise or command. The section describes how the AMI and node bootsrapping can be adapted when needed.
{{% /notice %}}

By default, Karpenter generates [launch templates](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchTemplates.html) that use [EKS Optimized AMI](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) for nodes. Often, users need to customize the node image to integrate with existing infrastructure, meet compliance requirements, add extra storage, etc. Karpenter supports custom node images and bootsrapping through Launch Templates. If you need to customize the node, then you need a custom launch template. 

{{% notice note %}}
By customizing the image, you are taking responsibility for maintaining it, including security updates. In the default configuration, Karpenter will use the latest version of the EKS optimized AMI, which is maintained by AWS. 
{{% /notice %}}

The selection of the Launch Template can be configured in the provider by setting up the `launchTemplate` property.

```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
spec:
  provider:
    launchTemplate: CustomKarpenterLaunchTemplateDemo
  ...
```

Launch Teplates specifies instance configuration information. It includes the ID of the Amazon Machine Image (AMI), the instance type, a key pair, storage, user data and other parameters used to launch EC2 instances. Launch Template user data can be used to customize the node bootstrapping to the cluster. In the default configuration, Karpenter uses an EKS optimized version of AL2 and passes the hostname of the Kubernetes API server, and a certificate for the node to bootstrap the process with the default configuration. The EKS Optimized AMI includes a `bootstrap.sh` script which connects the instance to the cluster, based on the passed data. Alternatively, you may reference AWS's [`bootstrap.sh`
file](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh)
when building a custom base image. 

{{% notice warning %}}
Specifying max-pods can break Karpenter's bin-packing logic (it has no way to know what this setting is). If Karpenter attempts to pack more than this number of pods, the instance may be oversized, and additional pods will reschedule.
{{% /notice %}}




