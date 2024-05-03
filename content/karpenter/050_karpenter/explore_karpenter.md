---
title: "Explore Karpenter Installation"
date: 2021-11-07T11:05:19-07:00
weight: 20
draft: false
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

In this section, we will review Karpenter which we have pre-installed and learn how to configure a default [Provisioner CRD](https://karpenter.sh/docs/concepts/provisioners/) to set the configuration. Karpenter can installed in clusters with a [helm](https://helm.sh/) chart, we used Amazon EKS blueprints. Karpenter follows best practices for kubernetes controllers for its configuration. Karpenter uses [Custom Resource Definition(CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) to declare its configuration. Custom Resources are extensions of the Kubernetes API. One of the premises of Kubernetes is the [declarative aspect of its APIs](https://kubernetes.io/docs/concepts/overview/kubernetes-api/). Karpenter simplifies its configuration by adhering to that principle.

## Explore the Karpenter installation

There are two main configuration mechanisms that can be used to configure Karpenter: Environment Variables / CLI parameters to the controller and webhook binaries and the karpenter-global-settings config-map. Let's explore the `karpenter-global-settings` ConfigMap.

Execute the following:

```bash
kubectl -n karpenter get cm/karpenter-global-settings -o yaml
```

The command above outputs the following settings:

* `aws.clusterEndpoint` so that Karpenter controller can contact the Cluster API Server.

* `aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${CLUSTER_NAME}` to use the instance profile to grant permissions necessary to instances to run containers and configure networking.

* `aws.interruptionQueueName=${CLUSTER_NAME}` to use the SQS queue created to handle Spot interruption notifications and AWS Health events.

*  `batchIdleDuration` is the maximum amount of time with no new pending pods that if exceeded ends the current batching window. If pods arrive faster than this time, the batching window will be extended up to the maxDuration. If they arrive slower, the pods will be batched separately.

* `batchMaxDuration` is the maximum length of a batch window. The longer this is, the more pods we can consider for provisioning at one time which usually results in fewer but larger nodes.

Checkout the [Karpenter documentation](https://karpenter.sh/v0.30/concepts/settings/) for information on the other configuration options.

To check Karpenter is running you can check the Pods, Deployment and Service are Running.

To check running pods run the command below. There should be at least two pods names `karpenter`

```
kubectl get pods --namespace karpenter
```

You should see an output similar to the one below. 
```
NAME                         READY   STATUS    RESTARTS   AGE
karpenter-75f6596894-pgrsd   1/1     Running   0          48s
karpenter-75f6596894-t4mrx   1/1     Running   0          48s
```


To check the deployment. There should be one deployment  `karpenter`
```
kubectl get deployment -n karpenter
```

{{% notice info %}}
Since **v0.16.0** Karpenter deploys 2 replicas. One of the replicas is elected as a Leader while the other stays in standby mode. The karpenter deployment also uses `podAntiAffinity` to spread each replica across different hosts and `topologySpreadConstraints` to increase the controller resilience by distributing pods across the cluster zones.
{{% /notice %}}
