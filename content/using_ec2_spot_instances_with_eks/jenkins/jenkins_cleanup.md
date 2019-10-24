---
title: "Jenkins cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 90
---


### Removing the Jenkins server
```
helm delete cicd
```

### Removing the Jenkins nodegroup from cluster-autoscaler
```
kubectl edit deployment cluster-autoscaler -n kube-system
```
Delete the third **\-\-nodes=** line that contains the Jenkins nodegroup name.

### Removing the Jenkins nodegroup
```
eksctl delete nodegroup -f spot_nodegroup_jenkins.yml --approve
```
