---
title: "EC2 Spot deployments"
date: 2021-11-07T11:05:19-07:00
weight: 60
draft: false
---

In the previous sections we've already used EC2 Spot instances. We have learned so far that when using EC2 Spot Karpenter selects a diversified list of instances and uses the allocation strategy `capacity-optimized-prioritized` to select the EC2 Spot pools that are optimal to reduce the frequency of Spot terminations while still being ideal for reducing the waste of the pending pods to place. 

In this section we will check how to set up the node termination handler to gracefully handle Spot terminations and rebalancing recommendation signals. To support this configuration we will use the `default` Provisioner. 

Before moving to the exercises. Let's apply Spot Best practices and make sure we handle Spot instances properly from now on.

## Deploy Node-Termination-Handler on EC2 Spot Instances

When users requests On-Demand Instances from a pool to the point that the pool is depleted, the system will select a set of Spot Instances from the pool to be terminated. A Spot Instance pool is a set of unused EC2 instances with the same instance type (for example, m5.large), operating system, Availability Zone, and network platform. The Spot Instance is sent an interruption notice two minutes ahead to gracefully wrap up things.

Amazon EC2 terminates, your Spot Instance when Amazon EC2 needs the capacity back (or the Spot price exceeds the maximum price for your request). More recently Spot instances support also instance rebalancing recommendation. Amazon EC2 emits an instance rebalance recommendation signal to notify you that a Spot Instance is at an elevated risk of interruption. This signal gives you the opportunity to proactively rebalance your workloads across existing or new Spot Instances without having to wait for the two-minute Spot Instance interruption notice.

To capture this signals and handle graceful termination of our nodes, we will deploy a project called **[AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler)**. Node termination handler operates in two different modes Queue Mode and Instance Metadata Mode. We will use Instance Metadata mode. In this mode the aws-node-termination-handler [Instance Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) Monitor will run a small pod ([DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)) on each host to perform monitoring of IMDS paths like /spot or /events and react accordingly to drain and/or cordon the corresponding node.

To deploy the Node Termination Handler run the following command:
```
helm repo add eks https://aws.github.io/eks-charts
helm install aws-node-termination-handler \
             --namespace kube-system \
             --version 0.16.0 \
             --set nodeSelector."node\\.k8s\\.aws/capacity-type"=spot \
             eks/aws-node-termination-handler
```

{{% notice note %}}
The helm command above does make use of the `nodeSelector` pointing to `node.k8s.aws/capacity-type: spot`. This way will only install the node-termination-handler in Spot nodes.
{{% /notice %}}


## Create a Spot Deployment

Let's create a deployment that uses Spot instances. 

```
cat <<EOF > inflate-spot.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate-spot
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate-spot
  template:
    metadata:
      labels:
        app: inflate-spot
    spec:
      nodeSelector:
        intent: apps
        node.k8s.aws/capacity-type: spot
      containers:
      - image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
        name: inflate-spot
        resources:
          requests:
            cpu: "1"
            memory: 256M
EOF
kubectl apply -f inflate-spot.yaml
```


## Challenge

{{% notice tip %}}
You can use **Kube-ops-view** or just plain **kubectl** cli to visualize the changes and answer the questions below. In the answers we will provide the CLI commands that will help you check the resposnes. Remember: to get the url of **kube-ops-view** you can run the following command `kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'`
{{% /notice %}}

Answer the following questions. You can expand each question to get a detailed answer and validate your understanding.

#### 1) Scale up the number of replicas to 2. How can you confirm only the Spot instance has the **Node-Termination-Handler** installed ? 

{{%expand "Click here to show the answer" %}} 

Let's start with increasing the number of replicas for the `inflate-spot` deployment to 2. Run the following command 

```
kubectl scale deployment inflate-spot --replicas 2
```

A new Spot node will be provisioned, once it's done you can run the following command to describe the content of the new Spot node:

```
kubectl describe node $(kubectl get node --selector=intent=apps,node.k8s.aws/capacity-type=spot -o json | jq ".items[].metadata.name"| sed s/\"//g)
```

The output of the command will also showcase there is a new Pod in the node in the `kube-system` namespace running the node-termination handler. The output of the command will show a section similar to the one below

```bash
Non-terminated Pods:          (5 in total)
  Namespace                   Name                                  CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                  ------------  ----------  ---------------  -------------  ---
  default                     inflate-spot-76f4658fc6-jgtkb         1 (25%)       0 (0%)      256M (3%)        0 (0%)         16m
  default                     inflate-spot-76f4658fc6-ldnmm         1 (25%)       0 (0%)      256M (3%)        0 (0%)         16m
  kube-system                 aws-node-termination-handler-7bn86    50m (1%)      100m (2%)   64Mi (0%)        128Mi (1%)     15m
  kube-system                 aws-node-xdhvh                        10m (0%)      0 (0%)      0 (0%)           0 (0%)         15m
  kube-system                 kube-proxy-bbxx7                      100m (2%)     0 (0%)      0 (0%)           0 (0%)         15m
```

While this confirms that the `aws-node-termination-handler` has only been deployed in the Spot instances, we should check the how many deployments of this type are to confirm it has only been deployed once (On Demand instances are not running node-termination handler)

Run the following command
```
kubectl get daemonset aws-node-termination-handler --namespace kube-system
```

The output should show just one instance of the node-termination-handler running.

{{% /expand %}}

#### 2) (Optional) Is that all for EC2 Spot Best practices ? 

{{%expand "Click here to show the answer" %}} 

Hmmmm nope... There are a few things that may worth advancing on what's to come with Karpenter

*  There are plans in Karpenter to embed part of the functionality of the node termination handler queue mode into the controller to integrate the handling of bothe Spot termination and rebalancing recommendation signals.  Rebalancing recommendation signals will allow Karpenter to procure new capacity in advance to a termination event and speed up the provisioning of instances. This functionality is already available in Spot Managed Node groups.

The following diagram depicts how the integration will consider rebalancing recommendations in the future. The diagram shows how when a **rebalancing recomendation** arrives indicating an instance is at elevated risk of termination, the controller will provision new instances from using `capacity-optimized-prioritized` this has the effect of rebalancing instances proactively and selecting them from the optimal pools that reduce the frequency of terminations. Once the new node is up and ready, the controller will follow node termination best practices to decommission the node at elevated risk of termination using cordon and drain, so that the pods migrate into the newly created instance. 

![Rebalancing Recommendations](/images/spotworkers/rebalance_recommendation.png)


* One question that comes often is what happens if the instances I selected cannot be provision. Since version 4.0, Karpenter supports pod affinity. This can be used with Spot or even on demand instances. For example in the case below the deployment defines a soft affinity for `node.k8s.aws/capacity-type` to run on Spot instances. If for whatever reason Karpenter cannot satisfy this condition, Karpenter will remove the soft constraint (in this case the request using Spot), and instead run with the default value (in this case OnDemand).


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate-spot
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate-spot
  template:
    metadata:
      labels:
        app: inflate-spot
    spec:
      nodeSelector:
        intent: apps
      affinity: 
        nodeAffinity: 
          preferredDuringSchedulingIgnoredDuringExecution: 
          - weight: 1
            preference: 
              matchExpressions: 
              - key: node.k8s.aws/capacity-type 
                operator: In 
                values: 
                - spot
      containers:
      - image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
        name: inflate-spot
        resources:
          requests:
            cpu: "1"
            memory: 256M
```

{{% /expand %}}


#### 3) Scale both deployments to 0 replicas ?

{{%expand "Click here to show the answer" %}} 

Before moving to the next section let's set the replicas down to 0

```
kubectl scale deployment inflate-spot --replicas 0
```

{{% /expand %}}


## What Have we learned in this section : 

In this section we have learned:

* How to apply Spot best practices and deploy the AWS Node Termination handler to manage Spot terminations and rebalancing recommendations.

* How future versions of Karpenter will enable a better integration of Spot Best practices by proactively managing rebalancing signals. 


