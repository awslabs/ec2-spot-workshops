---
title: "Using Alternative Provisioners"
date: 2021-11-07T11:05:19-07:00
weight: 90
draft: false
---

So far we have seen some advanced use cases of Karpenter. In this section we will see how Karpenter can define different Provisioners. This allows to handle different configurations. 

Each Provisioner CRD (Custom Resource Definition) provides a set of unique configurations, this that define the resources it supports as well as labels and taints that will also be applied to the newly resources created by that Provisioner. In large clusters with multiple applications, new applications may need to create nodes with specific Taints or specific labels. In these scenarios you can configure alternative Provisioners. For this workshop we have already defined a `team1` Provisioner. You can list the available Provisioners by running the following command:

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
        maxSkew: 1
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

But there is something that does not match with what we have seen so far with Karpenter. In previous scenarios Karpenter will be bin-packing instances to fit the workload. In this case 2 instances have been created one on each AZ (in this case eu-west-1a and eu-west-1b) !
{{% /expand %}}


#### 2) Why did Karpenter split the creation into two different nodes instead of bin-packing like in the previous scenarios ? 

{{%expand "Click here to show the answer" %}} 

Well, let's check first Karpenter log. 

```
kubectl logs -f deployment/karpenter -c controller -n karpenter
```

The output of Karpenter should look similar to the one below

```
...
2022-07-01T04:12:15.781Z        INFO    controller.provisioning Found 4 provisionable pod(s)    {"commit": "1f7a67b"}
2022-07-01T04:12:15.781Z        INFO    controller.provisioning Computed 2 new node(s) will fit 4 pod(s)        {"commit": "1f7a67b"}
2022-07-01T04:12:15.967Z        DEBUG   controller.provisioning.cloudprovider   Discovered subnets: [subnet-0e528fbbaf13542c2 (eu-west-1b) subnet-0a9bd9b668d8ae58d (eu-west-1a) subnet-03aec03eee186dc42 (eu-west-1a) subnet-03ff683f2535bcd8d (eu-west-1b)]   {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:16.063Z        DEBUG   controller.provisioning.cloudprovider   Discovered security groups: [sg-076f0ca74b68addb2 sg-09176f21ae53f5d60] {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:16.071Z        DEBUG   controller.provisioning.cloudprovider   Discovered kubernetes version 1.21      {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:16.179Z        DEBUG   controller.provisioning.cloudprovider   Discovered ami-015933fe34749f648 for query "/aws/service/bottlerocket/aws-k8s-1.21/x86_64/latest/image_id"      {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:16.456Z        DEBUG   controller.provisioning.cloudprovider   Created launch template, Karpenter-eksworkshop-eksctl-641081096202606695        {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:17.277Z        DEBUG   controller.node-state   Discovered 531 EC2 instance types       {"commit": "1f7a67b", "node": "ip-192-168-25-60.eu-west-1.compute.internal"}
2022-07-01T04:12:17.418Z        DEBUG   controller.node-state   Discovered EC2 instance types zonal offerings   {"commit": "1f7a67b", "node": "ip-192-168-25-60.eu-west-1.compute.internal"}
2022-07-01T04:12:18.287Z        INFO    controller.provisioning.cloudprovider   Launched instance: i-0e81a84185e589749, hostname: ip-192-168-37-210.eu-west-1.compute.internal, type: t3a.xlarge, zone: eu-west-1b, capacityType: on-demand     {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:18.302Z        INFO    controller.provisioning.cloudprovider   Launched instance: i-03c9fc74527b401f4, hostname: ip-192-168-7-134.eu-west-1.compute.internal, type: t3a.xlarge, zone: eu-west-1a, capacityType: on-demand      {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:18.306Z        INFO    controller.provisioning Created node with 2 pods requesting {"cpu":"2125m","memory":"512M","pods":"4"} from types t3a.xlarge, c6a.xlarge, c5a.xlarge, c6i.xlarge, t3.xlarge and 315 other(s)    {"commit": "1f7a67b", "provisioner": "team1"}
2022-07-01T04:12:18.306Z        DEBUG   controller.events       Normal  {"commit": "1f7a67b", "object": {"kind":"Pod","namespace":"default","name":"inflate-team1-865b77c748-dp9k5","uid":"5b682809-1ae9-4ed2-85c9-451abc11cf75","apiVersion":"v1","resourceVersion":"43463"}, "reason": "NominatePod", "message": "Pod should schedule on ip-192-168-37-210.eu-west-1.compute.internal"}
...
```

It's interesting to see how the nodes were selected in different availability zones.  
As you are probably guessing by now, this may have to do with the section of the deployment section for `topologySpreadConstraints:` . Latest versions of Karpenter (>0.4.1) support Kubernetes [Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/). You can define one or multiple topologySpreadConstraint to instruct the kube-scheduler how to place each incoming Pod in relation to the existing Pods across your cluster. 

To all effect the bin-packing is still happening is just that the topologySpreadConstraint is applied and forces us to spread the workload across the available `kubernetes.io/zone`

Check out as well the details in the log. If you recall the Node template in the provider section for the `team1` Provisioner, used Bottlerocket with a custom additional bootstrapping. You can see how the logs showcase Karpenter creating the `Karpenter-eksworkshop-eksctl-641081096202606695` launch template, and adapting it according to the latest version of the AMI and the bootstrapping added to the configuration. This simlifies significantly the life-cycle management and patching of EC2 Instances.

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

* For EKS, AL2, Ubuntu and Bottlerocket AMI's Karpenter does the heavy-lifting managing the underlying Launch Templates keeping AMI's up to dates. Karpenter also allows us to configure extra bootstrappign parameters without us having to manage Launch Templates, this significanlty simplifies the life-cycle management and patching of EC2 Instances while removing the heavy-lifting required to apply bootstrapping additional parameters.
