---
title: "Configure Cluster Autoscaler (CA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

We will start by deploying [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler). Cluster Autoscaler for AWS provides integration with Auto Scaling groups. It enables users to choose from four different options of deployment:

* One Auto Scaling group
* Multiple Auto Scaling groups
* **Auto-Discovery** - This is what we will use
* Master Node setup

In this workshop we will configure Cluster Autoscaler to scale using **[Cluster Autoscaler Auto-Discovery functionality](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md)**. When configured in Auto-Discovery mode on AWS, Cluster Autoscaler will call the EKS DescribeNodegroup API to get the information it needs about managed node group resources, labels, and taints. 

### Deploy the Cluster Autoscaler
Let's take advantage of using EKS Blueprints, and simply enable the Cluster Autoscaler addon.

In your Cloud9 workspace, open the Terraform template file (`main.tf`). Go to the `eks_blueprints_kubernetes_addons` section in the Terraform template, below the `enable_metrics_server = true` line, include the following lines:

```  
  enable_cluster_autoscaler = true
```

Now your `main.tf` file should look like this:

![EKS Blueprints - Cluster Autoscaler Plugin](/images/using_ec2_spot_instances_with_eks/prerequisites/eksblueprints_clusterautoscaler.png)

To apply this change with Terraform, run the following commands:

```
terraform fmt
terraform apply --auto-approve
```

Cluster Autoscaler gets deployed like any other pod. In this case we will use the **[kube-system namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)**, similar to what we do with other management pods.

To watch Cluster Autoscaler logs we can use the following command:

```
kubectl logs -f deployment/cluster-autoscaler-aws-cluster-autoscaler -n kube-system --tail=10
```

We are now ready to scale our cluster!!