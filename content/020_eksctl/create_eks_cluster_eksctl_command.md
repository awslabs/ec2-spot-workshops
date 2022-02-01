---
title: "Create EKS cluster Command"
chapter: false
disableToc: true
hidden: true
---

Create an eksctl deployment file (eksworkshop.yaml) to create an EKS cluster:


```
cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.21"
iam:
  withOIDC: true
managedNodeGroups:
- amiFamily: AmazonLinux2
  instanceType: m5.large
  name: mng-od-m5large
  desiredCapacity: 2
  maxSize: 3
  minSize: 0
  labels:
    alpha.eksctl.io/cluster-name: eksworkshop-eksctl
    alpha.eksctl.io/nodegroup-name: mng-od-m5large
    intent: control-apps
  tags:
    alpha.eksctl.io/nodegroup-name: mng-od-m5large
    alpha.eksctl.io/nodegroup-type: managed
    k8s.io/cluster-autoscaler/node-template/label/intent: control-apps
  iam:
    withAddonPolicies:
      autoScaler: true
      cloudWatch: true
      albIngress: true
  privateNetworking: true

EOF
```

Next, use the file you created as the input for the eksctl cluster creation.

```
eksctl create cluster -f eksworkshop.yaml
```
