---
title: "Using Alternative Provisioners"
date: 2021-11-07T11:05:19-07:00
weight: 80
draft: false
---

So far we have seen some advanced use cases of Karpenter. In this section we will see how Karpenter can define different Provisioners. This allows to handle different configurations. 

Each Provisioner CRD (Custom Resource Definition) provides a set of uniques configurations, this that define the resources it supports as well as labels and taints that will also be applied to the newly resources created by that Provisioner. In large clusters with multiple applications, new applications may need to create nodes with specific Taints or specific labels. In these scenarios you can configure alternative Provisioners. For this workshop we have already defined a `team1` Provisioner. You can list the available listeners by running the following command:

```
kubectl get provisioners
```

## Creating a Deployment that uses the `team1` Provisioner.

Let's create a new deployment this time, let's force the deployment to use the `team1` provisioner.

```
cat <<EOF > inflate-team1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate-team1
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate-team1
  template:
    metadata:
      labels:
        app: inflate-team1
    spec:
      nodeSelector:
        intent: apps
        kubernetes.io/arch: amd64
        karpenter.sh/provisioner-name: team1
      containers:
      - image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
        name: inflate-team1
        resources:
          requests:
            cpu: "1"
            memory: 256M
      tolerations:
      - key: team1
        operator: Exists
      topologySpreadConstraints:
      - labelSelector:
          matchLabels:
            app: inflate-team1
        maxSkew: 100
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: ScheduleAnyway
EOF
kubectl apply -f inflate-team1.yaml
```

There seem to be quite a few new entries in this section! Let's cover a few of those. The rest we will discuss in the **Challenge** section.

* The deployment sets the NodeSelector `intent: apps` so that this application does not overlap with the Managed Node group created with the cluster.

* The Node Selector `karpenter.sh/provisioner-name: team1` is also set. This NodeSelector is used by Karpenter to select which Provisioner configuration should be used when Provisioning capacity for this deployment. This allow different provisioner to for example define different [Taint](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) sections.

* The NodeSelector `kubernetes.io/arch` has been set to use x86_64 `amd64` instances.

* If you recall well the `team1` provisioner had a section that defined a `team1` taint. The deployment must add also that toleration so it's allowed to be placed in the newly created instances with the Taint `team1: NoSchedule`. Note the **NoSchedule** means that only applications that have the toleration for `team1` will be allowed on it.



## Challenge

{{% notice tip %}}
You can use **Kube-ops-view** or just plain **kubectl** cli to visualize the changes and answer the questions below. In the answers we will provide the CLI commands that will help you check the resposnes. Remember: to get the url of **kube-ops-view** you can run the following command `kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'`
{{% /notice %}}

Answer the following questions. You can expand each question to get a detailed answer and validate your understanding.

#### 1) How would you Scale the `inflate-team1` deployment to 4 replicas ? 

{{%expand "Click here to show the answer" %}} 

To scale up the deployment run the command:

```
kubectl scale deployment inflate-team1 --replicas 4
```

We should be able to see the number of replicas deployed by running the command below and looking for the instances of `inflate-team1` pods. There should be 4 of them. 

```
kubectl get pods
```

{{% /expand %}}

#### 2) Which Provisioner did Karpenter use ? Which Nodes where selected ? 

{{%expand "Click here to show the answer" %}}

Over this workshop we've used a few mechanisms. We can run the following command to check the nodes created and the properties label properties for those.

```
kubectl get node --selector=intent=apps,karpenter.sh/provisioner-name=team1 --show-labels
```

This should display an output similar to the one that follows. From this output below in our example we can see that the instance selected was `on-demand` and of type `t3a.xlarge`. 

```
NAME                                            STATUS     ROLES    AGE   VERSION               LABELS
xxxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal   Ready      <none>   66s   v1.21.5-eks-bc4871b   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3a.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=eu-west-1,failure-domain.beta.kubernetes.io/zone=eu-west-1b,intent=apps,karpenter.sh/provisioner-name=team1,kubernetes.io/arch=amd64,kubernetes.io/hostname=xxxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal,kubernetes.io/os=linux,kubernetes.sh/capacity-type=on-demand,node.kubernetes.io/instance-type=t3a.xlarge,topology.kubernetes.io/region=eu-west-1,topology.kubernetes.io/zone=eu-west-1b
xxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal    Ready      <none>   66s   v1.21.5-eks-bc4871b   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3a.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=eu-west-1,failure-domain.beta.kubernetes.io/zone=eu-west-1a,intent=apps,karpenter.sh/provisioner-name=team1,kubernetes.io/arch=amd64,kubernetes.io/hostname=xxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal,kubernetes.io/os=linux,kubernetes.sh/capacity-type=on-demand,node.kubernetes.io/instance-type=t3a.xlarge,topology.kubernetes.io/region=eu-west-1,topology.kubernetes.io/zone=eu-west-1a
```

But there is something that does not match with what we have seen so far with Karpenter. In previous scenarios Karpenter will be bin-packing instances to fit the workload. In this case 2 instances have been created one on each eu-west-1a !
{{% /expand %}}


#### 2) Why did Karpenter split the creation into two different nodes instead of bin-packing like in the previous scenarios ? 

{{%expand "Click here to show the answer" %}} 

Well, let's check first Karpenter log. 

```
kubectl logs -f deployment/karpenter-controller -n karpenter
```

The output of Karpenter should look similar to the one below

```
...
2021-11-16T05:41:30.292Z        INFO    controller.allocation.provisioner/team1 Starting provisioning loop      {"commit": "6468992"}
2021-11-16T05:41:30.293Z        INFO    controller.allocation.provisioner/team1 Waiting to batch additional pods        {"commit": "6468992"}
2021-11-16T05:41:31.476Z        INFO    controller.allocation.provisioner/team1 Found 4 provisionable pods      {"commit": "6468992"}
2021-11-16T05:41:32.490Z        INFO    controller.allocation.provisioner/team1 Computed packing for 2 pod(s) with instance type option(s) [c5.xlarge c6i.xlarge c3.xlarge c5a.xlarge c5d.xlarge c4.xlarge c1.xlarge c5n.xlarge m3.xlarge m1.xlarge m6i.xlarge m5zn.xlarge m5.xlarge m4.xlarge m5ad.xlarge m5d.xlarge t3.xlarge m5dn.xlarge m5a.xlarge t3a.xlarge]  {"commit": "6468992"}
2021-11-16T05:41:32.509Z        INFO    controller.allocation.provisioner/team1 Computed packing for 2 pod(s) with instance type option(s) [c6i.xlarge c5.xlarge c4.xlarge c5a.xlarge c5ad.xlarge c5d.xlarge c3.xlarge c1.xlarge c5n.xlarge m1.xlarge m3.xlarge m5zn.xlarge m5.xlarge m6i.xlarge t3a.xlarge m5ad.xlarge m5a.xlarge t3.xlarge m5dn.xlarge m5n.xlarge]        {"commit": "6468992"}
2021-11-16T05:41:34.216Z        INFO    controller.allocation.provisioner/team1 Launched instance: i-0f92acfe9a25a80c4, hostname: xxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal, type: t3a.xlarge, zone: eu-west-1a, capacityType: on-demand   {"commit": "6468992"}
2021-11-16T05:41:34.242Z        INFO    controller.allocation.provisioner/team1 Bound 2 pod(s) to node xxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal     {"commit": "6468992"}
2021-11-16T05:41:34.305Z        INFO    controller.allocation.provisioner/team1 Launched instance: i-02adc32c53c19fcec, hostname: xxxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal, type: t3a.xlarge, zone: eu-west-1b, capacityType: on-demand  {"commit": "6468992"}
2021-11-16T05:41:34.335Z        INFO    controller.allocation.provisioner/team1 Bound 2 pod(s) to node xxxxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal    {"commit": "6468992"}
...
```

It's interesting to see how the nodes were selected in different availability zones.  
As you are probably guessing by now, this may have to do with the section of the deployment section for `topologySpreadConstraints:` . Latest versions of Karpenter (>4.1) support Kubernetes [Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/). You can define one or multiple topologySpreadConstraint to instruct the kube-scheduler how to place each incoming Pod in relation to the existing Pods across your cluster. 

To all effect the bin-packing is still happening is just that the topologySpreadConstraint is applied and forces us to spread the workload across the available `kubernetes.io/zone`
{{% /expand %}}


#### 3) Scale both deployments to 0 replicas ?

{{%expand "Click here to show the answer" %}} 

This one should be really easy. Just run the following command

To scale up the deployment run the command:

```
kubectl scale deployment inflate-team1 --replicas 0
```

{{% /expand %}}


## What Have we learned in this section : 

In this section we have learned:

* Applications requiring specific labels or Taints can make use of alternative Provisioners that are customized for that set of applications. This is a common setup for large clusters.

* Pods can select the Provisioner by setting a nodeSelector with the lable `karpenter.sh/provisioner-name` pointing to the right Provisioner.

* Karpenter supports **[topologySpreadConstraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/)**. Topology Spread constraints  instruct the kube-scheduler how to place each incoming Pod in relation to the existing Pods across your cluster. In this scenario we discover how to balance pods across Availability Zones.
