---
title: "Create EKS cluster Command"
chapter: false
disableToc: true
hidden: true
---
<!--
This markdown file is used as part of another file using 'insert-md-from-file' shortcode
-->

```bash
eksctl create cluster \
    --version=1.20 \
    --name=eksworkshop-eksctl \
    --node-private-networking \
    --managed --nodes=2 \
    --alb-ingress-access \
    --region=${AWS_REGION} \
    --node-labels="intent=control-apps" \
    --asg-access
```
