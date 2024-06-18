---
title: "Create self managed node groups with Spot Instances"
date: 2018-08-07T11:05:19-07:00
weight: 30
draft: false
---


{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}


{{% notice warning %}}

If you are starting with **self managed Spot workers** chapter directly and planning to run only self managed node groups with Spot Instances, then first complete below chapters and then return back here:<br>
<br>
[Start the workshop]({{< relref "/using_ec2_spot_instances_with_eks/010_prerequisites" >}})<br>,
[Launch using Terraform]({{< relref "/using_ec2_spot_instances_with_eks/021_terraform" >}})<br>,
[Install Kubernetes Tools]({{< relref "/using_ec2_spot_instances_with_eks/030_k8s_tools" >}})<br>, and 
[Select Instance Types for Diversification]({{< relref "/using_ec2_spot_instances_with_eks/040_eksmanagednodegroupswithspot/selecting_instance_types.md" >}})

{{% /notice %}}

{{% notice info %}}

If you are have already completed **EKS managed Spot workers** chapters and still want to explore self managed node groups with Spot Instances, then continue with this chapter.

{{% /notice %}}

In this section we will create self managed node groups with Spot best practices. To adhere to the best practice of instance diversification we will include instance types we identified in [Select Instance Types for Diversification]({{< relref "/using_ec2_spot_instances_with_eks/040_eksmanagednodegroupswithspot/selecting_instance_types.md" >}}) chapter. **Remember to continue using your Cloud9 workspace to run all commands.**

Within the `main.tf` template file, there's a seccion within the `eks_blueprints` module with the following comment:

```
// ### -->> SPOT SELF-MANAGED NODE GROUPS GO HERE <<--- ###
```

Just below that line, paste the following code snippet to create two Spot self-managed node groups:

```
  self_managed_node_groups = {
    smng_spot_4vcpu_16mem = {
      node_group_name            = "smng-spot-4vcpu-16mem"
      capacity_rebalance         = true
      use_mixed_instances_policy = true      
      create_iam_role            = false
      iam_role_arn               = aws_iam_role.managed_ng.arn
      instance_type              = "m5.xlarge"

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=eks.amazonaws.com/capacityType=SPOT,intent=apps,type=self-managed-spot --register-with-taints=spotInstance=true:PreferNoSchedule'"

      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          spot_allocation_strategy                 = "price-capacity-optimized"
        }

        override = [
          { instance_type = "m4.xlarge" },
          { instance_type = "m5.xlarge" },
          { instance_type = "m5a.xlarge" },
          { instance_type = "m5ad.xlarge" },
          { instance_type = "m5d.xlarge" },
          { instance_type = "t2.xlarge" },
          { instance_type = "t3.xlarge" },
          { instance_type = "t3a.xlarge" }
        ]
      }

      max_size     = 4
      desired_size = 2
      min_size     = 0

      subnet_ids         = module.vpc.private_subnets
      launch_template_os = "amazonlinux2eks"
    }

    smng_spot_8vcpu_32mem = {
      node_group_name            = "smng-spot-8vcpu-32mem"
      capacity_rebalance         = true
      use_mixed_instances_policy = true      
      create_iam_role            = false
      iam_role_arn               = aws_iam_role.managed_ng.arn
      instance_type              = "m5.2xlarge"

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=eks.amazonaws.com/capacityType=SPOT,intent=apps,type=self-managed-spot --register-with-taints=spotInstance=true:PreferNoSchedule'"

      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          spot_allocation_strategy                 = "price-capacity-optimized"
        }

        override = [
          { instance_type = "m4.2xlarge" },
          { instance_type = "m5.2xlarge" },
          { instance_type = "m5a.2xlarge" },
          { instance_type = "m5ad.2xlarge" },
          { instance_type = "m5d.2xlarge" },
          { instance_type = "t2.2xlarge" },
          { instance_type = "t3.2xlarge" },
          { instance_type = "t3a.2xlarge" }
        ]
      }

      max_size     = 2
      desired_size = 1
      min_size     = 0

      subnet_ids         = module.vpc.private_subnets
      launch_template_os = "amazonlinux2eks"      
    }
  }
```

Run a `terraform fmt` to fix any identation problem (if any), then run:

```
terraform apply --auto-approve
```

{{% notice note %}}
The creation of the workers will take about 3-4 minutes.
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these nodegroups.

 * First node group has **xlarge** (4 vCPU and 16 GB) instance types with **minSize** 0, **maxSize** 4 and **desiredCapacity** 2.
 * Second node group has **2xlarge** (8 vCPU and 32 GB) instance types with **minSize** 0, **maxSize** 2 and **desiredCapacity** 1.
 * All nodes in the node group would be **Spot instances**.
 * The **Spot allocation strategy** is set as **[Price-Capacity Optimized](https://aws.amazon.com/blogs/compute/introducing-price-capacity-optimized-allocation-strategy-for-ec2-spot-instances/)**. This will ensure the capacity we provision in our node groups is procured from the pools that will have less chances of being interrupted.
 * We applied a **[Taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)** `spotInstance: "true:PreferNoSchedule"`. **PreferNoSchedule** is used to indicate we prefer pods not be scheduled on Spot Instances. This is a “preference” or “soft” version of **NoSchedule** – the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required.

{{% notice info %}}
If you are wondering at this stage: *Where is spot bidding price ?* you are missing some of the changes EC2 Spot Instances had since 2017. Since November 2017 [EC2 Spot price changes infrequently](https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/) based on long term supply and demand of spare capacity in each pool independently. You can still set up a **maxPrice** in scenarios where you want to set maximum budget. By default *maxPrice* is set to the On-Demand price; Regardless of what the *maxPrice* value, Spot Instances will still be charged at the current spot market price.
{{% /notice %}}

### Confirm the Nodes

{{% notice tip %}}
Aside from familiarizing yourself with the kubectl commands below to obtain the cluster information, you should also explore your cluster using **kube-ops-view** and find out the nodes that were just created.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see the nodes added to the cluster.

```bash
kubectl get nodes
```

You can use the node-labels to identify the lifecycle of the nodes

```bash
kubectl get nodes --selector=type=self-managed-spot
```

```
ip-192-168-11-135.ap-southeast-1.compute.internal   NotReady   <none>   13s   v1.21.4-eks-033ce7e   SPOT
ip-192-168-78-145.ap-southeast-1.compute.internal   NotReady   <none>   5s    v1.21.4-eks-033ce7e   SPOT
ip-192-168-78-41.ap-southeast-1.compute.internal    NotReady   <none>   12s   v1.21.4-eks-033ce7e   SPOT
```

You can use the `kubectl describe nodes` with one of the spot nodes to see the taints applied to the EC2 Spot Instances.

![Spot Taints](/images/using_ec2_spot_instances_with_eks/spotworkers/spot-self-mng-taint.png)

{{% notice note %}}
Explore your cluster using kube-ops-view and find out the nodes that have just been created.
{{% /notice %}}