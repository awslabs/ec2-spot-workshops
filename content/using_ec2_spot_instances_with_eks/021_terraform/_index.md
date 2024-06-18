---
title: "Test the Cluster"
weight: 25
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

#### Terraform

The CloudFormation stack created the EKS cluster using [**Terraform**](https://www.terraform.io/) using the [**EKS Blueprints for Terraform**](https://github.com/aws-ia/terraform-aws-eks-blueprints). 

**Terraform** is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently in AWS. **EKS Blueprints for Terraform** helps you compose complete EKS clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads. With EKS Blueprints, you describe the configuration for the desired state of your EKS environment, such as the control plane, worker nodes, and Kubernetes add-ons, as an IaC blueprint. Once a blueprint is configured, you can use it to stamp out consistent environments across multiple AWS accounts and Regions using continuous deployment automation.

{{< youtube DhoZMbqwwsw >}}

#### Update the kube-config file:
Before you can start running all the commands included in this workshop, you need to update the kube-config file with the proper credentials to access the cluster. To do so, in your Cloud9 workspace run the following command:

```
aws eks update-kubeconfig --region ${AWS_REGION} --name eksspotworkshop
```

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