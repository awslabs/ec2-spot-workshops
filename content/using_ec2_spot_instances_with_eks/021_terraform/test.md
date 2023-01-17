---
title: "Test the Cluster"
weight: 30
---
#### Test the cluster:
Confirm your Nodes, if we see 2 nodes then we know we have authenticated correctly:

```
kubectl get nodes 
```

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!

{{% notice tip %}}
Explore the Elastic Kubernetes Service (EKS) section in the AWS Console and the properties of the newly created EKS cluster.
{{% /notice %}}

{{% notice warning %}}
You might see **Error loading Namespaces** while exploring the cluster on the AWS Console. It could be because the console user role doesnt have necessary permissions on the EKS cluster's RBAC configuration in the control plane. Please expand and follow the below instructions to add necessary permissions. 
{{% /notice %}}