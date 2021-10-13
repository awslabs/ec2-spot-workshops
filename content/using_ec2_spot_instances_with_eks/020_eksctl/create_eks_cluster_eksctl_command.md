---
title: "Create EKS cluster Command"
chapter: false
disableToc: true
hidden: true
---
<!--
This markdown file is used as part of another file using 'insert-md-from-file' shortcode
-->

Create an eksctl deployment file (eksworkshop.yaml) use in creating your cluster using the following syntax:

```bash
cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.21"

managedNodeGroups:
- amiFamily: AmazonLinux2
  instanceType: m5.large
  name: mng-od-m5large
  desiredCapacity: 2
  maxSize: 2
  minSize: 0
  labels:
    alpha.eksctl.io/cluster-name: eksworkshop-eksctl
    alpha.eksctl.io/nodegroup-name: mng-od-m5large
    intent: control-apps
  tags:
    alpha.eksctl.io/nodegroup-name: mng-od-m5large
    alpha.eksctl.io/nodegroup-type: managed
    k8s.io/cluster-autoscaler/node-template/label/intent: control-apps
  ssh:
    enableSsm: true
  iam:
    withAddonPolicies:
      autoScaler: true
  privateNetworking: true

# To enable all of the control plane logs, uncomment below:
# cloudWatch:
#  clusterLogging:
#    enableTypes: ["*"]

EOF
```

Next, use the file you created as the input for the eksctl cluster creation.

```bash
eksctl create cluster -f eksworkshop.yaml
```

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}