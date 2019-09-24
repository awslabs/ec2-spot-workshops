---
title: "Adding Spot Workers with eksctl"
date: 2018-08-07T11:05:19-07:00
weight: 30
draft: false
---

In this section we will deploy the instance types we selected and request nodegroups that adhere to Spot diversification best practices. For that we will use **[eksctl create nodegroup](https://eksctl.io/usage/managing-nodegroups/)** and eksctl configuration files to add the new nodes to the cluster.

Let's first create the configuration file:
```
cat <<EoF > ~/environment/spot_nodegroups.yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl
    region: $AWS_REGION
nodeGroups:
    - name: dev-4vcpu-16gb-spot
      availabilityZones: ["${AWS_REGION}a","${AWS_REGION}b","${AWS_REGION}c"]
      minSize: 1
      maxSize: 5
      instancesDistribution:
        instanceTypes: ["m5.xlarge", "m5d.xlarge", "m4.xlarge","t3.xlarge","t3a.xlarge","m5a.xlarge","t2.xlarge"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotInstancePools: 4
      labels:
        lifecycle: Ec2Spot
        intent: apps
      taints:
        spotInstance: "true:PreferNoSchedule"
      iam:
        withAddonPolicies:
          autoScaler: true
          cloudWatch: true
          albIngress: true
    - name: dev-8vcpu-32gb-spot
      availabilityZones: ["${AWS_REGION}a","${AWS_REGION}b","${AWS_REGION}c"]
      minSize: 1
      maxSize: 5
      instancesDistribution:
        instanceTypes: ["m5.2xlarge", "m5d.2xlarge", "m4.2xlarge","t3.2xlarge","t3a.2xlarge","m5a.2xlarge","t2.2xlarge"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotInstancePools: 4
      labels:
        lifecycle: Ec2Spot
        intent: apps
      taints:
        spotInstance: "true:PreferNoSchedule"
      iam:
        withAddonPolicies:
          autoScaler: true
          cloudWatch: true
          albIngress: true
EoF
```

This will create a `spot_nodegroups.yml` file that we will use to instruct eksctl to create two nodegroups, both with a diversified configuration.

```bash
eksctl create nodegroup -f spot_nodegroups.yml
```

{{% notice note %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these nodegroups.

 * We did set up **onDemandPercentageAboveBaseCapacity** and **onDemandPercentageAboveBaseCapacity** both to **0**. which implies all nodes in the nodegroup would be **Spot instances**.
 * We did set up a **lifecycle: Ec2Spot** label so we can identify Spot nodes and use [affinities](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) and [nodeSlectors](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) later on.
 * We did also add an extra label **intent: apps**. We will use this label to force a hard partition
 of the cluster for our applications. During this workshop we will deploy control applications on
 nodes that have been labeled with **intent: control-apps** while our applications get deployed to nodes labeled with **intent: apps**.
 * We are also applying a **[Taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)** using `spotInstance: "true:PreferNoSchedule"`.  **PreferNoSchedule** is used to indicate we prefer pods not be scheduled on Spot Instances. This is a “preference” or “soft” version of **NoSchedule** – the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required.

### Confirm the Nodes

Confirm that the new nodes joined the cluster correctly. You should see the nodes added to the cluster.

```bash
kubectl get nodes
```

You can use the node-labels to identify the lifecycle of the nodes

```bash
kubectl get nodes --show-labels --selector=lifecycle=Ec2Spot
```

The output of this command should return **Ec2Spot** nodes. At the end of the node output, you should see the node label **lifecycle=Ec2Spot**

![Spot Output](/images/using_ec2_spot_instances_with_eks/spotworkers/spot_get_spot.png)

Now we will show all nodes with the **lifecycle=OnDemand**. The output of this command should return OnDemand nodes (the ones that we tagged when
creating the cluster).

```bash
kubectl get nodes --show-labels --selector=lifecycle=OnDemand
```

![OnDemand Output](/images/using_ec2_spot_instances_with_eks/spotworkers/spot_get_od.png)

You can use the `kubectl describe nodes` with one of the spot nodes to see the taints applied to the EC2 Spot Instances.

![Spot Taints](/images/using_ec2_spot_instances_with_eks/spotworkers/instance_taints.png)

{{% notice note %}}
Explore your cluster using kube-ops-view and find out the nodes that have just been created.
{{% /notice %}}


### On-Demand and Spot mixed worker groups

When deploying nodegroups, [eksctl](https://eksctl.io/usage/managing-nodegroups/) creates a CloudFormation template that deploys a [LaunchTemplate](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-launchtemplate.html) and an [Autoscaling Group](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-as-group.html) with the settings we provided in the configuration. Autoscaling groups using LaunchTemplate support not only mixed instance types but also purchasing options within the group. You can
mix **On-Demand, Reserved Instances, and Spot** within the same nodegroup. 

#### Label and Taint strategies on mixed workers 

The configuration we have used creates two diversified instance group with just Spot instances. We have attached to the all the nodes in the group the same `lifecycle: Ec2Spot` Label and a `spotInstance: "true:PreferNoSchedule"` taint.  When using a mix of On-demand and Spot instances within the same nodegroup, we need to implement conditional logic on the back of the instance attribute **InstanceLifecycle"** and set the labels and taints accordingly.

This can be achieved in multiple ways by extending the bootstrapping sequence.

 * **[eksctl_mixed_workers_bootstrap.yml](spotworkers.files/eksctl_mixed_workers_bootstrap.yml)** Provides an example file for [overriding eksctl boostrap process](https://github.com/weaveworks/eksctl/issues/929) in eksctl nodegroups. Note you may need to change the region details when using this example.


* **[cloudformation_mixed_workers.yml](spotworkers.files/cloudformation_mixed_workers.yml)** Provides a cloudformation template
to set up an autoscaling group with mixed on-demand and spot workers and insert bootstrap parameters to each depending on the node "InstanceLifecycle".


### Optional Exercise

 * Delete the current configuration and instead create 2 nodegroups one with 4vCPU's and 16GB ram and another one with 8vCPU's and 32GB of ram. The nodegroups must implement a set of mixed instances balanced at 50% between on-demand and spot. On-Demand instances must have a label `lifecycle: OnDemand`. Spot instances must have a label `lifecycle: Ec2Spot` and a taint `spotInstance: "true:PreferNoSchedule"`

{{%expand "Show me a hint for implementing this." %}}
You can delete the previous nodegroup created using  

```bash
eksctl delete nodegroup -f spot_nodegroups.yml
```

Download the example file [eksctl_mixed_workers_bootstrap.yml](spotworkers.files/eksctl_mixed_workers_bootstrap.yml), change the region to the current one where 
your cluster is running and create the nodegroups using the following command:

```bash
eksctl create nodegroup -f eksctl_mixed_workers_bootstrap.yml
```
{{% /expand %}}









