---
title: "Create EKS managed node groups with Spot capacity"
date: 2018-08-07T11:05:19-07:00
weight: 30
draft: false
---

In this section we will deploy the instance types we selected in previous chapter and create managed node groups that adhere to Spot diversification best practices. We will use **[`eksctl create nodegroup`](https://eksctl.io/usage/managing-nodegroups/)** to achieve this.

Let's first create the configuration file:

```
cat << EOF > add-mngs-spot.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

managedNodeGroups:
- name: mng-spot-4vcpu-16gb
  amiFamily: AmazonLinux2
  desiredCapacity: 2
  minSize: 0
  maxSize: 4
  spot: true
  instanceTypes:
  - m4.xlarge
  - m5.xlarge
  - m5a.xlarge
  - m5ad.xlarge
  - m5d.xlarge
  - t2.xlarge
  - t3.xlarge
  - t3a.xlarge
  iam:
    withAddonPolicies:
      autoScaler: true
  privateNetworking: true
  taints:
    - key: spotInstance
      value: "true"
      effect: PreferNoSchedule
  labels:
    alpha.eksctl.io/cluster-name: eksworkshop-eksctl
    alpha.eksctl.io/nodegroup-name: mng-spot-4vcpu-16gb
    intent: apps
  tags:
    alpha.eksctl.io/nodegroup-name: mng-spot-4vcpu-16gb
    alpha.eksctl.io/nodegroup-type: managed
    k8s.io/cluster-autoscaler/node-template/label/intent: apps
    k8s.io/cluster-autoscaler/node-template/taint/spotInstance: "true:PreferNoSchedule"

- name: mng-spot-8vcpu-32gb
  amiFamily: AmazonLinux2
  desiredCapacity: 1
  minSize: 0
  maxSize: 2
  spot: true
  instanceTypes:
  - m4.2xlarge
  - m5.2xlarge
  - m5a.2xlarge
  - m5ad.2xlarge
  - m5d.2xlarge
  - t2.2xlarge
  - t3.2xlarge
  - t3a.2xlarge
  iam:
    withAddonPolicies:
      autoScaler: true
  privateNetworking: true
  taints:
    - key: spotInstance
      value: "true"
      effect: PreferNoSchedule
  labels:
    alpha.eksctl.io/cluster-name: eksworkshop-eksctl
    alpha.eksctl.io/nodegroup-name: mng-spot-8vcpu-32gb
    intent: apps
  tags:
    alpha.eksctl.io/nodegroup-name: mng-spot-8vcpu-32gb
    alpha.eksctl.io/nodegroup-type: managed
    k8s.io/cluster-autoscaler/node-template/label/intent: apps
    k8s.io/cluster-autoscaler/node-template/taint/spotInstance: "true:PreferNoSchedule"

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.21"

EOF
```
Create new EKS managed node groups with Spot Instances. 

```
eksctl create nodegroup --config-file=add-mngs-spot.yaml
```
{{% notice info %}}
Creation of node groups will take 3-4 minutes. 
{{% /notice %}}


There are a few things to note in the configuration that we just used to create these node groups.

 * Node groups configurations are set under the **managedNodeGroups** section, this indicates that the node groups are managed by EKS.
 * First node group has **xlarge** (4 vCPU and 16 GB) instance types with **minSize** 0, **maxSize** 4 and **desiredCapacity** 2.
 * Second node group has **2xlarge** (8 vCPU and 32 GB) instance types with **minSize** 0, **maxSize** 2 and **desiredCapacity** 1.
 * The configuration **spot: true** indicates that the node group being created is a EKS managed node group with Spot capacity.
 * We applied a **[Taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)** `spotInstance: "true:PreferNoSchedule"`. **PreferNoSchedule** is used to indicate we prefer pods not be scheduled on Spot Instances. This is a “preference” or “soft” version of **NoSchedule** – the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required.
 * Notice that the we added 3 node labels per node:

  * **alpha.eksctl.io/cluster-name**, to indicate the nodes belong to **eksworkshop-eksctl** cluster.
  * **alpha.eksctl.io/nodegroup-name**, to indicate the nodes belong to **mng-spot-4vcpu-16gb** or **mng-spot-8vcpu-32gb** node groups.
  * **intent**, to allow you to deploy stateless applications on nodes that have been labeled with value **apps**

 * Notice that the we added 2 cluster autoscaler related tags to node groups:  
  * **k8s.io/cluster-autoscaler/node-template/label/intent** and **k8s.io/cluster-autoscaler/node-template/taint** are used by cluster autoscaler when node groups scale down to 0 (and scale up from 0). Cluster autoscaler acts on Auto Scaling groups belonging to node groups, therefore it requires same tags on ASG as well. Currently managed node groups do not auto propagate tags to ASG, see this [open issue](https://github.com/aws/containers-roadmap/issues/1524). Therefore, we will be adding these tags to ASG manually. 

Let's add these tags to Auto Scaling groups of each node group using AWS cli.

```
ASG_4VCPU_16GB=$(eksctl get nodegroup -n mng-spot-4vcpu-16gb --cluster eksworkshop-eksctl -o json | jq -r '.[].AutoScalingGroupName')
ASG_8VCPU_32GB=$(eksctl get nodegroup -n mng-spot-8vcpu-32gb --cluster eksworkshop-eksctl -o json | jq -r '.[].AutoScalingGroupName')

aws autoscaling create-or-update-tags --tags \
ResourceId=$ASG_4VCPU_16GB,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/node-template/label/intent,Value=apps,PropagateAtLaunch=true \
ResourceId=$ASG_4VCPU_16GB,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/node-template/taint/spotInstance,Value="true:PreferNoSchedule",PropagateAtLaunch=true

aws autoscaling create-or-update-tags --tags \
ResourceId=$ASG_8VCPU_32GB,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/node-template/label/intent,Value=apps,PropagateAtLaunch=true \
ResourceId=$ASG_8VCPU_32GB,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/node-template/taint/spotInstance,Value="true:PreferNoSchedule",PropagateAtLaunch=true
  
```

{{% notice info %}}
If you are wondering at this stage: *Where is spot bidding price ?* you are missing some of the changes EC2 Spot Instances had since 2017. Since November 2017 [EC2 Spot price changes infrequently](https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/) based on long term supply and demand of spare capacity in each pool independently. You can still set up a **maxPrice** in scenarios where you want to set maximum budget. By default *maxPrice* is set to the On-Demand price; Regardless of what the *maxPrice* value, Spot Instances will still be charged at the current Spot market price.
{{% /notice %}}

### Confirm the Nodes

{{% notice tip %}}
Aside from familiarizing yourself with the kubectl commands below to obtain the cluster information, you should also explore your cluster using **kube-ops-view** and find out the nodes that were just created.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see the nodes added to the cluster.

```
kubectl get nodes
```

Managed node groups automatically create a label **eks.amazonaws.com/capacityType** to identify which nodes are Spot Instances and which are On-Demand Instances so that we can schedule the appropriate workloads to run on Spot Instances. You can use this node label to identify the lifecycle of the nodes

```
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=SPOT
```
The output of this command should return nodes running on Spot Instances. The output of the command shows the **CAPACITYTYPE** for the current nodes is set to **SPOT**.

```
NAME                                                 STATUS     ROLES    AGE   VERSION               CAPACITYTYPE
ip-192-168-101-235.ap-southeast-1.compute.internal   Ready   <none>   14m   v1.21.4-eks-033ce7e   SPOT
ip-192-168-130-210.ap-southeast-1.compute.internal   Ready   <none>   14m   v1.21.4-eks-033ce7e   SPOT
ip-192-168-176-250.ap-southeast-1.compute.internal   Ready   <none>   14m   v1.21.4-eks-033ce7e   SPOT
```

Now we will show all nodes running on On Demand Instances. The output of the command shows the **CAPACITYTYPE** for the current nodes is set to **ON_DEMAND**.

```
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=ON_DEMAND
```
```
NAME                                                 STATUS   ROLES    AGE     VERSION               CAPACITYTYPE
ip-192-168-165-163.ap-southeast-1.compute.internal   Ready    <none>   51m   v1.21.4-eks-033ce7e   ON_DEMAND
ip-192-168-99-237.ap-southeast-1.compute.internal    Ready    <none>   51m   v1.21.4-eks-033ce7e   ON_DEMAND
```
