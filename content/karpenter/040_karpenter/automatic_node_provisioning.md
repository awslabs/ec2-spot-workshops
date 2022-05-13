---
title: "Automatic Node Provisioning"
date: 2021-11-07T11:05:19-07:00
weight: 40
draft: false
---

## Automatic Node Provisioning

With Karpenter now active, we can begin to explore how Karpenter provisions nodes. In this section we are going to create some pods using a `deployment` we will watch Karpenter provision nodes in response.


{{% notice note %}}
In this part off the workshop we will use a Deployments with the pause image. If you are not familiar with **Pause Pods** [you can read more about them here](https://www.ianlewis.org/en/almighty-pause-container). 
{{% /notice %}}

Run the following command and try to answer the questions below:

```
cat <<EOF > inflate.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate
  template:
    metadata:
      labels:
        app: inflate
    spec:
      nodeSelector:
        intent: apps
      containers:
        - name: inflate
          image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
          resources:
            requests:
              cpu: 1
              memory: 1.5Gi
EOF
kubectl apply -f inflate.yaml
```



## Challenge

{{% notice tip %}}
You can use **Kube-ops-view** or just plain **kubectl** cli to visualize the changes and answer the questions below. In the answers we will provide the CLI commands that will help you check the resposnes. Remember: to get the url of **kube-ops-view** you can run the following command `kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'`
{{% /notice %}}

Answer the following questions. You can expand each question to get a detailed answer and validate your understanding.

#### 1) Why did Karpenter not scale the cluster after making the initial deployment ?

{{%expand "Click here to show the answer" %}} 
The deployment was created with `replicas: 0`. We've done this for two reasons. In this section we will mention the first reason: We did set the replicas to 0, just for your convenience, so you can check out Karpenter logs once that you increase the number of replicas in the deployment. 

In the answer to question number 8, we will explain the second reason we are starting from zero.
{{% /expand %}}

#### 2) How would you scale the deployment to 1 replicas?
{{%expand "Click here to show the answer" %}} 
To scale up the deployment run the following command: 

```
kubectl scale deployment inflate --replicas 1
```

You can check the state of the replicas by running the following command. Once Karpenter provisions the new instance the pod will be placed in the new node.

```
kubectl get deployment inflate 
```
{{% /expand %}}

#### 3) Which instance type did Karpenter use when increasing the instances ? Why that instance ?
{{%expand "Click here to show the answer" %}} 

You can check which instance type was used running the following command:

```
kubectl get node --selector=intent=apps --show-labels
```

This will show a single instance created with the label set to `intent: apps`. To get the type of instance in this case, we can describe the node and look at the label `beta.kubernetes.io/instance-type` 

```
echo type: $(kubectl describe node --selector=intent=apps | grep "beta.kubernetes.io/instance-type" | sed s/.*=//g)
```

There is something even more interesting to learn about how the node was provisioned. Check out Karpenter logs and look at the new Karpenter created. The lines should be similar to the ones below 

```bash 
2022-05-12T03:38:15.698Z        INFO    controller      Batched 1 pod(s) in 1.000075807s        {"commit": "00661aa"}
2022-05-12T03:38:16.485Z        DEBUG   controller      Discovered 401 EC2 instance types       {"commit": "00661aa"}
2022-05-12T03:38:16.601Z        DEBUG   controller      Discovered EC2 instance types zonal offerings   {"commit": "00661aa"}
2022-05-12T03:38:16.768Z        DEBUG   controller      Discovered subnets: [subnet-0204b1b3b885ca98d (eu-west-1a) subnet-037d1d97a6a473fd1 (eu-west-1b) subnet-04c2ca248972479e7 (eu-west-1b) subnet-063d5c7ba912986d5 (eu-west-1a)]        {"commit": "00661aa"}
2022-05-12T03:38:16.953Z        DEBUG   controller      Discovered security groups: [sg-03ab1d5d49b00b596 sg-06e7e2ca961ab3bed] {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:38:16.955Z        DEBUG   controller      Discovered kubernetes version 1.21      {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:38:17.046Z        DEBUG   controller      Discovered ami-0440c10a3f77514d8 for query "/aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id"    {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:38:17.213Z        DEBUG   controller      Created launch template, Karpenter-eksworkshop-eksctl-7600085100718942941       {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:38:19.400Z        INFO    controller      Launched instance: i-0f47f9dc3fa486c35, hostname: ip-192-168-37-165.eu-west-1.compute.internal, type: t3.medium, zone: eu-west-1b, capacityType: spot        {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:38:19.412Z        INFO    controller      Created node with 1 pods requesting {"cpu":"1125m","memory":"1536Mi","pods":"3"} from types c4.large, c6a.large, t3a.medium, c5a.large, c6i.large and 306 other(s)   {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:38:19.426Z        INFO    controller      Waiting for unschedulable pods  {"commit": "00661aa"}
```


We explained earlier on about group-less cluster scalers and how that simplifies operations and maintenance. Let's deep dive for a second into this concept. Notice how Karpenter picks up the instance from a diversified selection of instances. In this case it selected the following instances:

```
c4.large, c6a.large, t3a.medium, c5a.large, c6i.large and 306 other(s)
```

{{% notice note %}}
Instances types might be different depending on the region selected.
{{% /notice %}}


All this instances are the suitable instances that reduce the waste of resources (memory and CPU) for the pod submitted. If you are interested in Algorithms, internally Karpenter is using a [First Fit Decreasing (FFD)](https://en.wikipedia.org/wiki/Bin_packing_problem#First_Fit_Decreasing_(FFD)) approach. Note however this can change in the future.

We did set Karpenter Provisioner to use [EC2 Spot instances](https://aws.amazon.com/ec2/spot/), and there was no `instance-types` [requirement section in the Provisioner to filter the type of instances](https://karpenter.sh/v0.10.0/provisioner/#instance-types). This means that Karpenter will use the default value of instances types to use. The default value includes all instance types with the exclusion of metal (non-virtualized), [non-HVM](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/virtualization_types.html), and GPU instances.Internally Karpenter used **EC2 Fleet in Instant mode** to provision the instances. You can read more about EC2 Fleet Instant mode [**here**](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instant-fleet.html). Here are a few properties to mention about EC2 Fleet instant mode that are key for Karpenter. 

* EC2 Fleet instant mode provides a synchronous call to procure instances, including EC2 Spot, this simplifies and avoid error when provisioning instances. For those of you familiar with [Cluster Autoscaler on AWS](https://github.com/kubernetes/autoscaler/blob/c4b56ea56136681e8a8ff654dfcd813c0d459442/cluster-autoscaler/cloudprovider/aws/auto_scaling_groups.go#L33-L36), you may know about how it uses `i-placeholder` to coordinate instances that have been created in asynchronous ways.

* The call to EC2 Fleet in instant mode is done using `capacity-optimized-prioritized` selecting the instances that reduce the likelihood of provisioning an extremely large instance. `Capacity-optimized` allocation strategies select instances from the Spot capacity pools with optimal capacity for the number of instances launched thus reducing the frequency of Spot terminations for the instances selected. You can read more about [Allocation Strategies here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-allocation-strategy.html) 

* Calls to EC2 Fleet in instant mode are not considered as Spot fleets. They do not count towards the Spot Fleet limits. The implication is that Karpenter can make calls to this API as many times over time as needed.


By implementing techniques such as: Bin-packing using First Fit Decreasing, Instance diversification using EC2 Fleet instant fleet and `capacity-optimized-prioritized`, Karpenter removes the need from customer to define multiple Auto Scaling groups each one for the type of capacity constraints and sizes that all the applications need to fit in. This simplifies considerably the operational support of kubernetes clusters.

{{% /expand %}}


#### 4) What are the new instance properties and Labels ?

{{%expand "Click here to show the answer" %}} 

You can use the following command to display all the node attributes including labels:

```
kubectl describe node --selector=intent=apps
```

Let's now focus in a few of those parameters starting with the Labels:

```bash
Labels:             ...
                    intent=apps
                    karpenter.sh/capacity-type=spot
                    node.kubernetes.io/instance-type=t3.medium
                    topology.kubernetes.io/region=eu-west-1
                    topology.kubernetes.io/zone=eu-west-1a
                    karpenter.sh/provisioner-name=default
                    ...
```

* Note the node was created with the `intent=apps` as we did state in the Provisioner configuration
* Same applies to the Spot configuration. Note how the `karpenter.sh/capacity-type` label has been set to `spot`
* Karpenter AWS implementation will also add the Labels `topology.kubernetes.io` for `region` and `zone`.
* Karpenter does support multiple Provisioners. Note how the `karpenter.sh/provisioner-name` uses the `default` as the Provisioner in charge of managing the instance lifecycle.

Another thing to note from the node description is the following section:

```bash
System Info:
  ...
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.4.6
  ...
```

* The instance selected has been created with the default architecture Karpenter will use when the Provisioner CRD requirement for `kubernetes.io/arch` [Architecture](https://karpenter.sh/v0.6.2/provisioner/#architecture) has not been provided.

* The Container Runtime used for Karpenter nodes is containerd. You can read more about containerd [**here**](https://containerd.io/)  


{{% notice info%}}
At this time, Karpenter only supports Linux OS nodes.
{{% /notice %}}

{{% /expand %}}

#### 5) Why did the newly created `inflate` pod was not scheduled into the managed node group ?

{{%expand "Click here to show the answer" %}}

The On-Demand Managed Node group was provisioned with the label `intent` set to `control-apps`. In our case the deployment defined the followin section, where the `intent` is set to `apps`.

```yaml
spec:
      nodeSelector:
        intent: apps
      containers:
        ...
```

Karpenter default Provisioner was also created with the the section:

```yaml
spec:
  labels:
    intent: apps
```

[NodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector), [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/), can be used to split the topology of your cluster and indicate Karpenter where to place your Pods and Jobs. 

Both Karpenter and [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) do take into consideration NodeSelector, Taints and Tolerations. Mixing  Autoscaling management solution in the same cluster may cause side effects as auto scaler systems like Cluster Autoscaler and Karpenter both scale up nodes in response to unschedulable pods. To avoid race conditions a clear division of the resources using NodeSelectors, Taints and Tolerations must be used. This is outside of the scope of this workshop.

{{% /expand %}}

#### 6) How would you scale the number of replicas to 6? What do you expect to happen? Which instance types were selected in this case ?

{{%expand "Click here to show the answer" %}}

This one should be easy! 

```
kubectl scale deployment inflate --replicas 6
```

This will set a few pods pending. Karpenter will get the pending pod signal and run a new provisioning cycle similar to the one below (confirm by checking Karpenter logs). This time, the capacity should get provisioned with a slightly different set of characteristics. Given the new size of aggregated pod requirements, Karpenter will check which type of instance diversification makes sense to use.


```bash
2022-05-12T03:47:17.907Z        INFO    controller      Batched 5 pod(s) in 1.056343494s        {"commit": "00661aa"}
2022-05-12T03:47:18.692Z        DEBUG   controller      Discovered 401 EC2 instance types       {"commit": "00661aa"}
2022-05-12T03:47:18.848Z        DEBUG   controller      Discovered EC2 instance types zonal offerings   {"commit": "00661aa"}
2022-05-12T03:47:19.011Z        DEBUG   controller      Discovered subnets: [subnet-0204b1b3b885ca98d (eu-west-1a) subnet-037d1d97a6a473fd1 (eu-west-1b) subnet-04c2ca248972479e7 (eu-west-1b) subnet-063d5c7ba912986d5 (eu-west-1a)]   {"commit": "00661aa"}2022-05-12T03:47:19.094Z        DEBUG   controller      Discovered security groups: [sg-03ab1d5d49b00b596 sg-06e7e2ca961ab3bed] {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:47:19.097Z        DEBUG   controller      Discovered kubernetes version 1.21      {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:47:19.134Z        DEBUG   controller      Discovered ami-0440c10a3f77514d8 for query "/aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id"    {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:47:19.175Z        DEBUG   controller      Discovered launch template Karpenter-eksworkshop-eksctl-7600085100718942941     {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:47:21.199Z        INFO    controller      Launched instance: i-066971cf53a56a2f7, hostname: ip-192-168-38-49.eu-west-1.compute.internal, type: t3.2xlarge, zone: eu-west-1b, capacityType: spot   {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:47:21.208Z        INFO    controller      Created node with 5 pods requesting {"cpu":"5125m","memory":"7680Mi","pods":"7"} from types c4.2xlarge, c6i.2xlarge, c6a.2xlarge, c5a.2xlarge, c5.2xlarge and 222 other(s)      {"commit": "00661aa", "provisioner": "default"}
2022-05-12T03:47:21.236Z        INFO    controller      Waiting for unschedulable pods  {"commit": "00661aa"}
```

Indeed the instances selected this time are larger ! The instances selected in this example were:

```bash
c4.2xlarge, c6i.2xlarge, c6a.2xlarge, c5a.2xlarge, c5.2xlarge and 222 other(s)
```

Finally to check out the configuration of the `intent=apps` node execute again:

```
kubectl describe node --selector=intent=apps
```

This time around you'll see the description for both instances created.

{{% /expand %}}

#### 8) How would you scale the number of replicas to 0?  what do you expect to happen?
{{%expand "Show me the answers" %}} 
To scale the number of replicas to 0, run the following command: 

```
kubectl scale deployment inflate --replicas 0
```

In the previous section, we configured the default Provisioner with `ttlSecondsAfterEmpty` set to 30 seconds. Once the nodes don't have any pods scheduled on them, Karpenter will terminate the empty nodes using cordon and drain [best practices](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/)


Let's cover the second reason why we started with 0 replicas and why we also end with 0 replicas! Karpenter does support scale to and from Zero. Karpenter only launches or terminates nodes as necessary based on aggregate pod resource requests. Karpenter will only retain nodes in your cluster as long as there are pods using them. 
{{% /expand %}}


## What Have we learned in this section : 

In this section we have learned:

* Karpenter scales up nodes in a group-less approach. Karpenter select which nodes to scale , based on the number of pending pods and the *Provisioner* configuration. It selects how the best instances for the workload should look like, and then provisions those instances. This is unlike what Cluster Autoscaler does. In the case of Cluster Autoscaler, first all existing node group are evaluated and to find which one is the best placed to scale, given the Pod constraints.

* Karpenter uses cordon and drain [best practices](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/) to terminate nodes. The configuration of when a node is terminated can be controlled with `ttlSecondsAfterEmpty`

* Karpenter can scale up from zero and scale in to zero.

