---
title: "Configure Horizontal Pod Autoscaler (HPA)"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

So far we have scaled the number of replicas manually. We also have built an understanding around how Cluster Autoscaler does scale the cluster.
In this section we will deploy the **[Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)** and a rule to scale our application once it reaches a CPU threshold. The Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment or replica set based on observed CPU utilization or memory. 

For HPA to evaluate metrics we must first deploy Metric Server ! 

### Deploy the Metrics Server
Metrics Server is a cluster-wide aggregator of resource usage data. These metrics will drive the scaling behavior of the [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). We will deploy the metrics server using `Helm` configured earlier in this workshop.

```
helm install stable/metrics-server \
    --name metrics-server \
    --version 2.8.3 \
    --namespace metrics
```

{{% notice note %}}
Horizontal Pod Autoscaler is more versatile than just scaling on CPU and Memory. There are other projects different from the metric server that can be consider when looking scaling on the back of other metrics. For example [prometheus-adapter](https://github.com/helm/charts/tree/master/stable/prometheus-adapter) can be used wit custom metrics imported from [prometheus](https://prometheus.io/)
{{% /notice %}}

### Confirm the Metrics API is available.

Return to the terminal in the Cloud9 Environment
```
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```
If all is well, you should see a status message similar to the one below in the response
```
status:
  conditions:
  - lastTransitionTime: 2018-10-15T15:13:13Z
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available
```


### Create an HPA resource associated with the Monte Carlo Pi Service

We will set up a rule to scales up when CPU exceeds 50% of the allocated container resource.

```
kubectl autoscale deployment monte-carlo-pi-service --cpu-percent=50 --min=3 --max=100
```

View the HPA using kubectl. You probably will see `<unknown>/50%` for 1-2 minutes and then you should be able to see `0%/50%`
```
kubectl get hpa
```



