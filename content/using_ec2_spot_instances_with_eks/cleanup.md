---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

## Cleaning up eks cluster
```
helm delete --purge kube-ops-view metrics-server
od_nodegroup=$(eksctl get nodegroup --cluster eksworkshop-eksctl | tail -n 1 | awk '{print $2}')
eksctl delete nodegroup --cluster eksworkshop-eksctl --name $od_nodegroup
eksctl delete cluster --name eksworkshop-eksctl
```