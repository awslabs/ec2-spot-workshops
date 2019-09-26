---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

{{% notice tip %}}
Before you clean up the resources and complete the workshop, take a look at the content and modules available at **[eksworkshop.com](https://eksworkshop.com/)**. Perhaps there are modules that you would like to try on spot instances !
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

## Cleaning up eks cluster
```
helm delete --purge kube-ops-view metrics-server
od_nodegroup=$(eksctl get nodegroup --cluster eksworkshop-eksctl | tail -n 1 | awk '{print $2}')
eksctl delete nodegroup --cluster eksworkshop-eksctl --name $od_nodegroup
eksctl delete cluster --name eksworkshop-eksctl
```