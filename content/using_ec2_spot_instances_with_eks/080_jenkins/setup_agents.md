---
title: "Create Spot workers for Jenkins"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}


#### Create EKS managed node group with Spot capacity for Jenkins agent

Earlier in the workshop, in the **Add EKS managed Spot workers** chapter, we created node groups that run a diversified set of Spot Instances to run our applications. Let's create a new nodegroup configuration section within the `main.tf` Terraform template. **Remember to continue using your Cloud9 workspace to run all commands.** 

The Jenkins default resource requirements (Request and Limit CPU/Memory) are 512m (~0.5 vCPU) and 512Mi (~0.5 GB RAM), and since we are not going to perform any large build jobs in this workshop, we can stick to the defaults and also choose relatively small instance types that can accommodate the Jenkins agent pods.

Within the `main.tf` template file, in the `managed_node_groups` section, paste the following code snippet to create the Jenkins Spot node group:

```
    jenkins_agents_mng_spot_2vcpu_8gb = {
      node_group_name = "jenkins-agents-mng-spot-2vcpu-8gb"
      capacity_type   = "SPOT"
      instance_types  = ["m4.large", "m5.large", "m5a.large", "m5ad.large", "m5d.large", "t2.large", "t3.large", "t3a.large"]
      max_size        = 3
      desired_size    = 1
      min_size        = 0

      subnet_type = "private"
      subnet_ids  = []

      k8s_labels = {
        intent = "jenkins-agents"
      }
    }
```

Run a `terraform fmt` to fix any identation problem (if any), then run:

```
terraform apply --auto-approve
```

{{% notice note %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these node groups.

 * Node groups configurations are set under the **managed_node_groups** section, this indicates that the node groups are managed by EKS.
 * The node group has **large** (2 vCPU and 8 GB) instance types with **min_size** 0, **max_size** 3 and **desired_size** 1.
 * The configuration **capacity_type= "SPOT"** indicates that the node group being created is a EKS managed node group with Spot capacity.
 * Notice that the we added a node label per node:

  * **intent**, to allow you to deploy jenkins agents on nodes that have been labeled with value **jenkins-agents**.