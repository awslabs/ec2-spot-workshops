---
title: "Consolidation"
date: 2021-11-07T11:05:19-07:00
weight: 50
draft: false
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

In the previous section we did set the default provisioner configured with a specific `ttlSecondsAfterEmpty`. This instructs Karpenter to remove nodes after `ttlSecondsAfterEmpty` of a node being empty. Note Karpenter will take Daemonset into consideration.We also know that nodes can be removed when they reach the `ttlSecondsUntilExpired`. This is ideal to force node termination on the cluster while bringing new nodes that will pick up the latest AMI's.

{{% notice note %}}
Automated deprovisioning is configured through the ProvisionerSpec `.ttlSecondsAfterEmpty`, `.ttlSecondsUntilExpired` and `.consolidation.enabled` fields. If these are not configured, Karpenter will not default values for them and will not terminate nodes.
{{% /notice %}}

There is another way to configure Karpenter to deprovision nodes called **Consolidation**. This mode is preferred for workloads such as microservices and is imcompatible with setting up the `ttlSecondsAfterEmpty` . When set in consolidation mode Karpenter works to actively reduce cluster cost by identifying when nodes can be removed as their workloads will run on other nodes in the cluster and when nodes can be replaced with cheaper variants due to a change in the workloads.

Before we proceed to see how Consolidation works, let's change the default provisioner configuration:
```
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  consolidation:
    enabled: true
  labels:
    intent: apps
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
    - key: karpenter.k8s.aws/instance-size
      operator: NotIn
      values: [nano, micro, small, medium, large]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  ttlSecondsUntilExpired: 2592000
  providerRef:
    name: default
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: eksspotworkshop
  securityGroupSelector:
    karpenter.sh/discovery: eksspotworkshop
  tags:
    KarpenerProvisionerName: "default"
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
EOF
```

{{% notice tip %}}
When consolidation is enabled it is recommended you configure requests=limits for all non-CPU resources. As an example, pods that have a memory limit that is larger than the memory request can burst above the request. If several pods on the same node burst at the same time, this can cause some of the pods to be terminated due to an out of memory (OOM) condition. Consolidation can make this more likely to occur as it works to pack pods onto nodes only considering their requests.
{{% /notice %}}

## Challenge

{{% notice tip %}}
You can use **Kube-ops-view** or just plain **kubectl** cli to visualize the changes and answer the questions below. In the answers we will provide the CLI commands that will help you check the resposnes. Remember: to get the url of **kube-ops-view** you can run the following command `kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'`.
Note the current version of Kube-ops-view sometimes takes time to reflect the correct state of the cluster.
{{% /notice %}}

Before we start to deep dive into consolidation, lets set up the environment in an initial state. First lets scale the `inflate` application to 3 replicas, so that we provision a small node. You can do that by running: 

```
kubectl scale deployment inflate --replicas 3
```

You can then check the number of nodes using the following command `kubectl get nodes` ; Once that there are 3 nodes in the cluster you can run again:

```
kubectl scale deployment inflate --replicas 10
```

That will create up yet another node. In total there should be now 4 nodes, 2 for the managed nodegroup, and 2 on-demand nodes, one holding 3 of our `inflate` replicas of size **xlarge** and a **2xlarge**


Answer the following questions. You can expand each question to get a detailed answer and validate your understanding.

#### 1) Scale the `inflate` deployment to 6 replicas, What should happen ?

{{%expand "Click here to show the answer" %}} 

Scaling to 6 replicas should be easy:

```
kubectl scale deployment inflate --replicas 6
```

As for what should happen, check out karpenter logs, remember you can read karpenter logs using the following command 
```
alias kl='kubectl -n karpenter logs -l app.kubernetes.io/name=karpenter --all-containers=true -f --tail=20'
kl
```

Karpenter logs will display the following lines

```
2022-09-05T08:24:35.548Z        INFO    controller.consolidation        Consolidating via Delete, terminating 1 nodes ip-192-168-31-208.eu-west-1.compute.internal/t3a.xlarge   {"commit": "b157d45"}
2022-09-05T08:24:35.600Z        INFO    controller.termination  Cordoned node   {"commit": "b157d45", "node": "ip-192-168-31-208.eu-west-1.compute.internal"}
2022-09-05T08:24:36.707Z        INFO    controller.termination  Deleted node    {"commit": "b157d45", "node": "ip-192-168-31-208.eu-west-1.compute.internal"}
```

At this point, Karpenter has issued a consolidation via deletion of one of it's nodes. Karpenter has two mechanisms for cluster consolidation: 

* **Deletion** - A node is eligible for deletion if all of its pods can run on free capacity of other nodes in the cluster.
* **Replace**  - A node can be replaced if all of its pods can run on a combination of free capacity of other nodes in the cluster and a single cheaper replacement node. 


When there are multiple nodes that could be potentially deleted or replaced, Karpenter choose to consolidate the node that overall disrupts your workloads the least by preferring to terminate: 
* nodes running fewer pods
* nodes that will expire soon
* nodes with lower priority pods


In this case 4 pods were termimnated. This resulted in Karpenter deleting the **xlarge** node and consolidating the 6 pods remaining in the **2xlarge** capacity, resulting in the operation that reduced the cost while disrupting less the cluster.

The log does also show something interesting lines that refer to `Cordon` and `Deletion`. Karpenter sets a Kubernetes finalizer on each node it provisions. The finalizer specifies additional actions the Karpenter controller will take in response to a node deletion request. By adding the finalizer, Karpenter improves the default Kubernetes process of node deletion. When you run kubectl delete node on a node without a finalizer, the node is deleted without triggering the finalization logic. The instance will continue running in EC2, even though there is no longer a node object for it. The kubelet isn’t watching for its own existence, so if a node is deleted the kubelet doesn’t terminate itself. All the pod objects get deleted by a garbage collection process later, because the pods’ node is gone.

{{% /expand %}}

#### 2) What should happen when we move to just 3 replicas ?
{{%expand "Click here to show the answer" %}} 
To scale up the deployment run the following command: 

```
kubectl scale deployment inflate --replicas 3
```

Following the description from the previous question, in this case we expect Karpenter to issue a **Replace** order and use instead of the **2xlarge** instance a consolidation into a **xlarge** instance. You can follow the changes on `kube-ops-view` or by running `kubectl get nodes`; The steps that follow are, first a new **xlarge** instance gets created and started and finally, the **2xlarge** instance is terminated. 

Karpenter logs will show the sequence of events on the output, similar to the ones below :
```
2022-09-05T08:36:20.652Z        INFO    controller.consolidation        Consolidating via Replace, terminating 1 nodes ip-192-168-15-83.eu-west-1.compute.internal/t3a.2xlarge and replacing with a node from types c6id.xlarge, c5ad.xlarge, r5ad.xlarge, t3a.xlarge, r6i.xlarge and 26 other(s)     {"commit": "b157d45"}
2022-09-05T08:36:20.684Z        INFO    controller.consolidation        Launching node with 3 pods requesting {"cpu":"3125m","memory":"4608Mi","pods":"5"} from types t3a.xlarge, c6a.xlarge, c5a.xlarge, t3.xlarge, c6i.xlarge and 26 other(s)       {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:36:20.966Z        DEBUG   controller.consolidation.cloudprovider  Created launch template, Karpenter-eksworkshop-eksctl-10619024032654607850      {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:36:22.694Z        INFO    controller.consolidation.cloudprovider  Launched instance: i-0a4609a533f1dc157, hostname: ip-192-168-73-120.eu-west-1.compute.internal, type: t3a.xlarge, zone: eu-west-1a, capacityType: on-demand   {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:37:38.649Z        INFO    controller.termination  Deleted node    {"commit": "b157d45", "node": "ip-192-168-15-83.eu-west-1.compute.internal"}
```


{{% /expand %}}

#### 3) Increase the replicas to 10. What will happen if we change the provisioner to support both `on-demand` and `spot` ?
{{%expand "Click here to show the answer" %}} 
To scale up the deployment bach to 10 ,run the following command: 

```
kubectl scale deployment inflate --replicas 10
```

There should not be any surprise here, like in previous cases a new **2xlarge** node might be selected to place the extra 7 pods. Note, the provisioned instance type can depend on available spot capacity.

To apply the change to the provisioner, we will re-deploy the default provisioner, this time using both `on-demand` and `spot`. Run the following command
```
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  # Enables consolidation which attempts to reduce cluster cost by both removing un-needed nodes and down-sizing those
  # that can't be removed.  Mutually exclusive with the ttlSecondsAfterEmpty parameter.
  consolidation:
    enabled: true
  labels:
    intent: apps
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand","spot"]
    - key: karpenter.k8s.aws/instance-size
      operator: NotIn
      values: [nano, micro, small, medium, large]
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  ttlSecondsUntilExpired: 2592000
  providerRef:
    name: default
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: eksspotworkshop
  securityGroupSelector:
    karpenter.sh/discovery: eksspotworkshop
  tags:
    KarpenerProvisionerName: "default"
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
EOF
```

For deployments that do not provide a preference, Karpenter prioritizes Spot offerings if the provisioner allows Spot and on-demand instances. Changes in a Provisioner do also result in a re-evaluation of the consolidation policies. As a result of this changes, we should expect for Karpenter to change the nodes in the cluster from `on-demand` to Spot. As we learned in the solution to the first challenge, when there are multiple nodes that can be consolidated, Karpenter will start from the one that causes less disruption. In this case we are expecting the **xlarge** instance to be **Replaced** first. The replacement follows the same steps that we have seen previously. First a new `spot` instance is created and then the `on-demand` instance that was selected to be replaced will be terminated. The same sequence of events happens after that with the **2xlarge** instance.

Karpenter logs should show a sequence of events similar to the one below.
```
2022-09-05T08:54:53.601Z        INFO    controller.consolidation        Consolidating via Replace, terminating 1 nodes ip-192-168-73-120.eu-west-1.compute.internal/t3a.xlarge and replacing with a node from types m5n.xlarge, m5d.xlarge, m6i.xlarge, c6a.2xlarge, m5a.xlarge and 44 other(s)       {"commit": "b157d45"}
2022-09-05T08:54:53.636Z        INFO    controller.consolidation        Launching node with 3 pods requesting {"cpu":"3125m","memory":"4608Mi","pods":"5"} from types t3a.xlarge, t3.xlarge, c6a.xlarge, c6i.xlarge, c6id.xlarge and 44 other(s)      {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:54:54.020Z        DEBUG   controller.consolidation.cloudprovider  Created launch template, Karpenter-eksworkshop-eksctl-6351194516503745500       {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:54:56.072Z        INFO    controller.consolidation.cloudprovider  Launched instance: i-0949483dbf32ca4c2, hostname: ip-192-168-49-94.eu-west-1.compute.internal, type: c5.xlarge, zone: eu-west-1b, capacityType: spot  {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:55:51.936Z        INFO    controller.termination  Deleted node    {"commit": "b157d45", "node": "ip-192-168-73-120.eu-west-1.compute.internal"}
2022-09-05T08:56:02.531Z        INFO    controller.consolidation        Consolidating via Replace, terminating 1 nodes ip-192-168-8-39.eu-west-1.compute.internal/t3a.2xlarge and replacing with a node from types r6a.4xlarge, c5d.2xlarge, c6a.4xlarge, c6a.2xlarge, z1d.2xlarge and 49 other(s)    {"commit": "b157d45"}
2022-09-05T08:56:02.568Z        INFO    controller.consolidation        Launching node with 7 pods requesting {"cpu":"7125m","memory":"10752Mi","pods":"9"} from types inf1.2xlarge, c3.2xlarge, r3.2xlarge, c5a.2xlarge, t3a.2xlarge and 49 other(s) {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:56:02.860Z        DEBUG   controller.consolidation.cloudprovider  Discovered launch template Karpenter-eksworkshop-eksctl-6351194516503745500     {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:56:05.328Z        INFO    controller.consolidation.cloudprovider  Launched instance: i-00e7459e351c4992f, hostname: ip-192-168-29-219.eu-west-1.compute.internal, type: c5a.2xlarge, zone: eu-west-1a, capacityType: spot       {"commit": "b157d45", "provisioner": "default"}
2022-09-05T08:57:06.000Z        INFO    controller.termination  Deleted node    {"commit": "b157d45", "node": "ip-192-168-8-39.eu-west-1.compute.internal"}
```

#### 4) Scale the `inflate` service to 3 replicas, what should happen ?
{{%expand "Click here to show the answer" %}} 

Run the following command to set the number of replicas to 3.

```
kubectl scale deployment inflate --replicas 3
```

For spot nodes, Karpenter only uses the **Deletion** consolidation mechanism. It will not replace a spot node with a cheaper spot node. Spot instance types are selected with the `price-capacity-optimized` strategy and often the cheapest spot instance type is not launched due to the likelihood of interruption. Consolidation would then replace the spot instance with a cheaper instance negating the `price-capacity-optimized` strategy entirely and increasing interruption rate.

Effectively no changes will happen at this stage with your cluster.
{{% /expand %}}

#### 5) What other scenarios could prevent **Consolidation** events in your cluster ?
{{%expand "Click here to show the answer" %}} 

There are a few cases where requesting to deprovision a Karpenter node will not work. These include **Pod Disruption Budgets** and pods that have the **do-not-evict** annotation set. 

Karpenter respects Pod Disruption Budgets (PDBs) by using a backoff retry eviction strategy. Pods will never be forcibly deleted, so pods that fail to shut down will prevent a node from deprovisioning. Kubernetes PDBs let you specify how much of a Deployment, ReplicationController, ReplicaSet, or StatefulSet must be protected from disruptions when pod eviction requests are made. PDBs can be used to strike a balance by protecting the application’s availability while still allowing a cluster administrator to manage the cluster. 

If a pod exists with the annotation `karpenter.sh/do-not-evict: true` on a node, and a request is made to delete the node, Karpenter will not drain any pods from that node or otherwise try to delete the node. Nodes that have pods with a do-not-evict annotation are not considered for consolidation, though their unused capacity is considered for the purposes of running pods from other nodes which can ber consolidated.

There are other cases that Karpenter will consider when consolidating. Consolidation will be unable to consolidate a node if, as a result of its scheduling simulation, it determines that the pods on a node cannot run on other nodes due to:
* inter-pod affinity/anti-affinity
* topology spread constraints
* or some other scheduling restriction that couldn’t be fulfilled.

Finally, Karpenter consolidation will not attempt to consolidate a node that is running pods that are not owned by a controller (e.g. a ReplicaSet). In general we cannot assume that these pods would be recreated if they were evicted from the node that they are currently running on.
{{% /expand %}}

#### 6) Scale the replicas to 0.

In preparation for the next section, scale replicas to 0 using the following command.

```
kubectl scale deployment inflate --replicas 0
```


## What Have we learned in this section: 

In this section we have learned:

* Karpenter can be configured to consolidate workloads using the . The `ttlSecondsAfterEmpty` and `.consolidation.enabled` are mutually exclussive within a provisioner. 
  
* Consolidation helps to reduce the overal cost of the cluster in two situations. **Delete** can ocur when the capacity of a node can be safely distributed to other nodes. **Replace** ocurs when a node can be replace by a smaller node thus reducing the cost in the cluster

* Consolidation takes into consideration multiple nodes, but only acts on one node at a time. The node selected is the one that minimises the disruption in the cluster. 

* **Delete** Consolidation does also include events where instances are moved from `on-demand` to `spot`, however karpenter does not trigger **Replace** to make Spot node smaller as this can have an impact on the level of interruptions.

* Karpenter uses cordon and drain [best practices](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) to terminate nodes. to make it safer, Karpenter adds a finalizer so that a `kubernetes delete node` command, results in a graceful termination that remove the node safely from the cluster.