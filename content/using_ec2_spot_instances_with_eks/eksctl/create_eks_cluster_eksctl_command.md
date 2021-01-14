---
title: "Create EKS cluster Command"
chapter: false
disableToc: true
hidden: true
---
<!--
This markdown file is used as part of another file using 'insert-md-from-file' shortcode
-->

```
eksctl create cluster --version=1.18 --name=eksworkshop-eksctl --node-private-networking  --managed --nodes=2 --alb-ingress-access --region=${AWS_REGION} --node-labels="lifecycle=OnDemand,intent=control-apps" --asg-access
```
