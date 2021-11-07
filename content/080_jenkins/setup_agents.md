---
title: "Create Spot workers for Jenkins"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

#### Create EKS managed node group with Spot capacity for Jenkins agent

Earlier in the workshop, in the **Add EKS managed Spot workers** chapter, we created node groups that run a diversified set of Spot Instances to run our applications. Let's create a new eksctl nodegroup configuration file called `add-mng-spot-jenkins.yml`. 

The Jenkins default resource requirements (Request and Limit CPU/Memory) are 512m (~0.5 vCPU) and 512Mi (~0.5 GB RAM), and since we are not going to perform any large build jobs in this workshop, we can stick to the defaults and also choose relatively small instance types that can accommodate the Jenkins agent pods.

```
cat <<EoF > ~/environment/add-mng-spot-jenkins.yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl
    region: $AWS_REGION

managedNodeGroups:
- name: jenkins-agents-mng-spot-2vcpu-8gb
  amiFamily: AmazonLinux2
  desiredCapacity: 1
  minSize: 0
  maxSize: 3
  spot: true
  instanceTypes:
  - m4.large
  - m5.large
  - m5a.large
  - m5ad.large
  - m5d.large
  - t2.large
  - t3.large
  - t3a.large
  iam:
    withAddonPolicies:
      autoScaler: true
      cloudWatch: true
      albIngress: true
  privateNetworking: true
  labels:
    alpha.eksctl.io/cluster-name: eksworkshop-eksctl
    alpha.eksctl.io/nodegroup-name: jenkins-agents-mng-spot-2vcpu-8gb
    intent: jenkins-agents
  tags:
    alpha.eksctl.io/nodegroup-name: jenkins-agents-mng-spot-2vcpu-8gb
    alpha.eksctl.io/nodegroup-type: managed
    k8s.io/cluster-autoscaler/node-template/label/intent: jenkins-agents

EoF
```

Create new EKS managed node groups with Spot capacity for Jenkins Agents. 

```
eksctl create nodegroup -f add-mng-spot-jenkins.yml
```

{{% notice note %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}

{{% notice note %}}
Since eksctl 0.41, integrates with the instance selector ! This can create more convenient configurations that apply diversification of instances in a concise way.
As an exercise, [read eks instance selector documentation](https://eksctl.io/usage/instance-selector/) and figure out which changes you may need to apply the configuration changes using instance selector.
At the time of writing this workshop, we have not included this functionality as there is a pending feature we'd need to deny a few instances [Read more about this here](https://github.com/weaveworks/eksctl/issues/3718)
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these node groups.

 * Node groups configurations are set under the **managedNodeGroups** section, this indicates that the node groups are managed by EKS.
 * The node group has **large** (2 vCPU and 8 GB) instance types with **minSize** 0, **maxSize** 3 and **desiredCapacity** 1.
 * The configuration **spot: true** indicates that the node group being created is a EKS managed node group with Spot capacity.
 * Notice that the we added 3 node labels per node:

  * **alpha.eksctl.io/cluster-name**, to indicate the nodes belong to **eksworkshop-eksctl** cluster.
  * **alpha.eksctl.io/nodegroup-name**, to indicate the nodes belong to **jenkins-agents-mng-spot-2vcpu-8gb** node group.
  * **intent**, to allow you to deploy jenkins agents on nodes that have been labeled with value **jenkins-agents**.

 * Notice that the we added 1 cluster autoscaler related tag to node groups:  
  * **k8s.io/cluster-autoscaler/node-template/label/intent** is used by cluster autoscaler when node groups scale down to 0 (and scale up from 0). Cluster autoscaler acts on Auto Scaling groups belonging to node groups, therefore it requires same tags on ASG as well. Currently managed node groups do not auto propagate tags to ASG, see this [open issue](https://github.com/aws/containers-roadmap/issues/1524). Therefore, we will be adding these tags to ASG manually. 


Let's add these tags to Auto Scaling groups of each node group using AWS cli.

```
ASG_JENKINS_2VCPU_8GB=$(eksctl get nodegroup -n jenkins-agents-mng-spot-2vcpu-8gb --cluster eksworkshop-eksctl -o json | jq -r '.[].AutoScalingGroupName')

aws autoscaling create-or-update-tags --tags \
ResourceId=$ASG_JENKINS_2VCPU_8GB,ResourceType=auto-scaling-group,Key=k8s.io/cluster-autoscaler/node-template/label/intent,Value=jenkins-agents,PropagateAtLaunch=true
  
```