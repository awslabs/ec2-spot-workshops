---
title: "Install Karpenter"
date: 2021-11-07T11:05:19-07:00
weight: 20
draft: false
---

In this section we will install Karpenter and learn how to configure a default [Provisioner CRD](https://karpenter.sh/docs/provisioner-crd/) to set the configuration. Karpenter is installed in clusters with a [helm](https://kubernetes.io/docs/concepts/overview/kubernetes-api/) chart. Karpenter follows best practices for kubernetes controllers for its configuration. Karpenter uses [Custom Resource Definition(CRD)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) to declare its configuration. Custom Resources are extensions of the Kubernetes API. One of the premises of Kubernetes is the [declarative aspect of its APIs](https://kubernetes.io/docs/concepts/overview/kubernetes-api/). Karpenter similifies its configuration by adhering to that principle.

## Install Karpenter Helm Chart

We will use helm to deploy Karpenter to the cluster. 

```
helm repo add karpenter https://charts.karpenter.sh
helm repo update
helm upgrade --install karpenter karpenter/karpenter --namespace karpenter \
  --create-namespace --set serviceAccount.create=false --version 0.4.2 \
  --set nodeSelector.intent=control-apps \
  --wait # for the defaulting webhook to install before creating a Provisioner
```

The command above:
* uses the  service account that we created in the previous step, hence it sets the `--set serviceAccount.create=false`

* Uses the argument `--set nodeSelector.intent=control-apps` to deploy the controllers in the On-Demand managed node group that was created with the cluster.

* Karpenter configuration is provided through a Custom Resource Definition. We will be learning about providers in the next section, the `--wait` notifies the webhook controller to wait until the Provisioner CRD has been deployed.

To check Karpenter is running you can check the Pods, Deployment and Service are Running.

To check running pods
```
kubectl get pods --namespace karpenter
```

To check the deployment
```
kubectl get deployment -n karpenter
```

{{% notice note %}}
You can increase the number of Karpenter replicas in the deployment for resilience. Karpenter will elect a leader controller that in charge of running operations.
{{% /notice %}}


