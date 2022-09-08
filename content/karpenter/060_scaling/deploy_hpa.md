---
title: "Configure HPA"
date: 2021-11-10T08:30:11-07:00
weight: 30
---

So far we have scaled the number of replicas manually. We also have built an understanding around how Karpenter scales capacity. In this section we will deploy the **[Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)** and a rule to scale our application once it reaches a CPU threshold. The Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment or replica set based on observed CPU utilization or memory. 

{{% notice note %}}
Horizontal Pod Autoscaler is more versatile than just scaling on CPU and Memory. There are other projects different from the metric server that can be consider when looking scaling on the back of other metrics. For example  **[KEDA](https://keda.sh/)** is a Kubernetes Event-driven Autoscaler. KEDA works alongside standard Kubernetes components like the Horizontal Pod Autoscaler and can drive the scaling of any container in Kubernetes based on the number of events needing to be processed.
{{% /notice %}}


### Create an HPA resource associated with the Monte Carlo Pi Service

We will set up a rule to scales up when CPU exceeds 50% of the allocated container resource.

```
kubectl autoscale deployment monte-carlo-pi-service --cpu-percent=50 --min=3 --max=100
```

View the HPA using kubectl. You probably will see `<unknown>/50%` for 1-2 minutes and then you should be able to see `0%/50%`
```
kubectl get hpa
```



