---
title: "Cleanup Scaling"
date: 2018-08-07T08:30:11-07:00
weight: 60
hidden: true
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

## Cleaning up HPA, CA, and the Microservice
```
kubectl delete hpa monte-carlo-pi-service
kubectl delete -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
kubectl delete -f monte-carlo-pi-service.yml
```


## Removing eks Spot nodes from the cluster

```
eksctl delete nodegroup -f spot_nodegroups.yml --approve
```
