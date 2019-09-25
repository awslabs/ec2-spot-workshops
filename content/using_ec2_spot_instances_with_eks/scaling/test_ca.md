---
title: "Scale a Cluster with CA"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

### Visualizing Cluster Autoscaler Logs and Actions 

{{% notice note %}}
During this section we recommend arranging your window so that you can see Cloud9 Console and Kube-ops-view and starting a new terminal in Cloud9 to tail Cluster Autoscaler logs. This will help you visualize the effect of your scaling commands.
{{% /notice %}}

{{%expand "Show me how to get kube-ops-view url" %}}
Execute the following command on Cloud9 terminal
```
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```
{{% /expand %}}


{{%expand "Show me how to tail Cluster Autoscaler logs" %}}
Execute the following command on Cloud9 terminal
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system --tail=10
```
{{% /expand %}}

### Scale our ReplicaSet

OK, let's scale out the replicaset to 10
```
kubectl scale deployment/monte-carlo-pi-service --replicas=10
```

You can confirm the state of the pods using
```
kubectl get pods --watch
```

```
NAME                                     READY   STATUS    RESTARTS   AGE
monte-carlo-pi-service-584f6ddff-fk2nj   1/1     Running   0          20m21s
monte-carlo-pi-service-584f6ddff-fs9x6   1/1     Running   0          103s
monte-carlo-pi-service-584f6ddff-jst55   1/1     Running   0          103s
monte-carlo-pi-service-584f6ddff-mncqv   1/1     Running   0          103s
monte-carlo-pi-service-584f6ddff-n5qvk   1/1     Running   0          103s
monte-carlo-pi-service-584f6ddff-nfnqx   1/1     Running   0          103s
monte-carlo-pi-service-584f6ddff-p8ghf   1/1     Running   0          2m29s
monte-carlo-pi-service-584f6ddff-q8ckn   1/1     Running   0          20m21s
monte-carlo-pi-service-584f6ddff-t9tdr   1/1     Running   0          103s
monte-carlo-pi-service-584f6ddff-zlg8b   1/1     Running   0          103s
```
You should also be able to visualize the scaling action using kube-ops-view. Kube-ops-view provides an option to highlight pods meeting a regular expression. All pods in green are **monte-carlo-pi-service** pods.
![Scaling up to 10 replicas](/images/using_ec2_spot_instances_with_eks/scaling/scaling-kov-10-replicas.png)

{{% notice info %}}
So far Cluster Autoscaler did not scale the cluster. Note how the pods deployed by the replicaset ended up distributed in the two available nodes. Kube-ops-view does also display a bar on the left of each node, showing the node capacity status. Both nodes appear to be under capacity pressure !
{{% /notice %}}

#### Challenge

Try to answer the following questions:

 - Could you predict what should happen if we increase the number of replicas to 13 ? 
 - How would you scale up the replicas to 13 ? 
 - If you are expecting a new node, which size will it be: (a) 4vCPU's 16GB RAM or (b) 8vCPU's 32GB RAM ?
 - Which AWS instance type you would expect to be selected ?
 - How would you confirm your predictions ?

{{%expand "Show me the answers" %}}
To scale up the number of replicas run:
```
kubectl scale deployment/monte-carlo-pi-service --replicas=13
```

When the number of replicas scales up, there will be a few pods pending. You can confirm which pods are pending running the command below. 
```
kubectl get pods --watch
```

Kube-ops-view, will show 3 pending yellow pods outside the node.
![Scale Up](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-up-kov.png)

When inspecting cluster-autoscaler logs with the command line below 
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```
you will notice Cluster Autoscaler events similar to:
![CA Scale Up events](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-up2.png)


To confirm which type of node has been added you can either use kube-ops-view or execute:
```
kubectl get node --selector=intent=apps --show-labels
```

You can verify in AWS Management Console to confirm that the Auto Scaling groups are scaling up to meet demand. This may take a few minutes. You can also follow along with the pod deployment from the command line. You should see the pods transition from pending to running as nodes are scaled up.

![Scale Up](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-up.png)

{{% notice info %}}
Cluster Autoscaler expands capacity according to the [Expander](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-expanders) configuration. By default, Cluster Autoscaler uses the **random** expander. This means that there is equal probability of cluster autoscaler selecting the 4vCPUs 16GB RAM group or the 8vCPUs 32GB RAM group. 
{{% /notice %}}

As for the node that was selected, by default the Autoscaling Groups that we created with eksctl use [lowest-price allocation strategy](https://docs.aws.amazon.com/en_pv/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies) and are configured to distribute across the lowest 4 spot Instance Pools (out from the ones that we defined).  

The Autoscaling group selected by Cluster Autoscaler, will invoke the lowest-price allocation strategy and pick an instance from the cheapest pools. 

{{% /expand %}}

After you've completed the exercise, scale down your replicas back down in preparation for the configuration of Horizontal Pod Autoscheduler.
```
kubectl scale deployment/monte-carlo-pi-service --replicas=4
```


### Optional Exercises

{{% notice warning %}}
Some of this exercises will take time for Cluster Autoscaler to scale up and down. If you are running this
workshop at a AWS event or with limited time, we recommend to come back to this section once you have 
completed the workshop, and before getting into the **cleanup** section.
{{% /notice %}}

 * How would you expect Cluster Autoscaler to Scale-in the cluster ? How about scaling out ? How much time you'll expect for it to take ?

 * How will pods be removed when scaling down? From which nodes they will be removed? What is the effect of adding [Pod Disruption Budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) to this mix ? 

 * What will happen when modifying Cluster Autoscaler **expander** configuration from **random**  to **least-waste**. What happens when we increase the replicas back to 13 ? What happens if we increase the number of replicas to 20? Can you predict which group of node will be expandeded in each case: (a) 4vCPUs 16GB RAM (b) 8vCPUs 32GB RAM? What's Cluster Autoscaler log looking like in this case? 

 * At the moment AWS auto-scaling groups backing up the nodegroups are setup to use the [lowest price](https://docs.aws.amazon.com/en_pv/autoscaling/ec2/userguide/asg-purchase-options.html#asg-allocation-strategies) allocation strategy, using the 4 cheapest pools in each AZ. Can you think of a different alternative **allocation strategy** to help reduce the frequency of interruptions on EC2 Spot nodes? What would be the pros and cons of using a different allocation strategy on a front-end production system ?

