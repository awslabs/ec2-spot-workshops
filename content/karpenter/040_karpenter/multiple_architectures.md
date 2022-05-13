---
title: "Multi-Archtiecture deployments"
date: 2021-11-07T11:05:19-07:00
weight: 70
draft: false
---

In the previous section we defined two Provisioners, both supporting `amd64` (x86_64) and `arm64` architectures. In this section we will deploy applications that require a specific architecture. 



{{% notice tip %}}
If you are not familiar with the AWS support for `arm64` instances, we recommend to take a look at the documentation for **[AWS Graviton instances](https://aws.amazon.com/ec2/graviton/)**. AWS Graviton processors are custom built by Amazon Web Services using 64-bit Arm Neoverse. They power Amazon EC2 instances such as: M6g, M6gd, T4g, C6g, C6gd, C6gn, R6g, R6gd, X2gd. Graviton instances provide up to 40% better price performance over comparable current generation x86-based instances for a wide variety of workloads.
{{% /notice %}}

{{% notice info %}}
At re:Invent 2021 tuesday 30th Nov Keynote we announced the new release of a new third generation of Graviton instances. You can learn more about this anouncement **[here](https://aws.amazon.com/blogs/aws/join-the-preview-amazon-ec2-c7g-instances-powered-by-new-aws-graviton3-processors/)**
{{% /notice %}}

## Creating Multi-Architecture Deployments

Let's create our new deployments. Like in the previous section, we will create two new deployments, one for each architecture. We will start the deployments with 0 replicas.

First, let's create the `amd64` deployment. Run the following command.

```
cat <<EOF > inflate-amd64.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate-amd64
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate-amd64
  template:
    metadata:
      labels:
        app: inflate-amd64
    spec:
      nodeSelector:
        intent: apps
        kubernetes.io/arch: amd64
      containers:
      - image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
        name: inflate-amd64
        resources:
          requests:
            cpu: "1"
            memory: 256M
EOF
kubectl apply -f inflate-amd64.yaml
```

Let's create now the `arm64` Deployment.

```
cat <<EOF > inflate-arm64.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate-arm64
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate-arm64
  template:
    metadata:
      labels:
        app: inflate-arm64
    spec:
      nodeSelector:
        intent: apps
        kubernetes.io/arch: arm64
        node.kubernetes.io/instance-type: c6g.xlarge
      containers:
      - image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
        name: inflate-arm64
        resources:
          requests:
            cpu: "1"
            memory: 256M
EOF
kubectl apply -f inflate-arm64.yaml
```

As you see the main difference between both Deployments, is the nodeSelector 
`kubernetes.io/arch` and the names, all pointing to the architecture selection for that deployment. 

{{% notice note %}}
In this part off the workshop we will keep using Deployments with the Pause Image. Notice as well how both deployments point to the same container image. Amazon ECR (Elastic Container Repository) does support multi-architecture container images. You can read more about it **[here](https://aws.amazon.com/blogs/containers/introducing-multi-architecture-container-images-for-amazon-ecr/)**
{{% /notice %}}


## Challenge

{{% notice tip %}}
You can use **Kube-ops-view** or just plain **kubectl** cli to visualize the changes and answer the questions below. In the answers we will provide the CLI commands that will help you check the resposnes. Remember: to get the url of **kube-ops-view** you can run the following command `kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'`
{{% /notice %}}

Answer the following questions. You can expand each question to get a detailed answer and validate your understanding.

#### 1) How would you Scale the `inflate-amd64` deployment to 2 replicas ? What nodes were selected by Karpenter ? 

{{%expand "Click here to show the answer" %}} 

To scale up the deployment run the command:

```
kubectl scale deployment inflate-amd64 --replicas 2
```

Before we check the selected node, let's cover what Karpenter is expected to do in this scenario. Node selectors are an opt-in mechanism which allow users to specify the nodes on which a pod can scheduled. Karpenter recognizes well-known node selectors on unschedulable pods and uses them to constrain the nodes it provisions. `kubernetes.io/arch` is one of the [well-known node selectors](https://kubernetes.io/docs/reference/labels-annotations-taints/)  supported by Karpenter. When Karpenter finds that the `kubernetes.io/arch` was set to `amd64` it does ensure ensure that provisioned nodes are constrained accordingly to `amd64` instances.

Let's confirm that was the case and only `amd64` considered for scaling up. We can check karpenter logs by running the following command.

```
kubectl logs -f deployment/karpenter -c controller -n karpenter
```

The output should show something similar to the lines below

```bash
...
2022-05-12T04:15:10.593Z        INFO    controller      Batched 2 pod(s) in 1.009818195s        {"commit": "00661aa"}
2022-05-12T04:15:10.770Z        DEBUG   controller      Discovered subnets: [subnet-0204b1b3b885ca98d (eu-west-1a) subnet-037d1d97a6a473fd1 (eu-west-1b) subnet-04c2ca248972479e7 (eu-west-1b) subnet-063d5c7ba912986d5 (eu-west-1a)]   {"commit": "00661aa"}
2022-05-12T04:15:10.851Z        DEBUG   controller      Discovered security groups: [sg-03ab1d5d49b00b596 sg-06e7e2ca961ab3bed]{"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:15:10.854Z        DEBUG   controller      Discovered kubernetes version 1.21      {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:15:10.940Z        DEBUG   controller      Discovered ami-0440c10a3f77514d8 for query "/aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id"    {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:15:10.977Z        DEBUG   controller      Discovered launch template Karpenter-eksworkshop-eksctl-13001267661656074018    {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:15:13.081Z        INFO    controller      Launched instance: i-0d19d3eeb2d59578d, hostname: ip-192-168-22-165.eu-west-1.compute.internal, type: m4.xlarge, zone: eu-west-1a, capacityType: spot   {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:15:13.093Z        INFO    controller      Created node with 2 pods requesting {"cpu":"2125m","memory":"512M","pods":"5"} from types c4.xlarge, c6i.xlarge, c5a.xlarge, c5.xlarge, c6a.xlarge and 267 other(s)     {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:15:13.103Z        INFO    controller      Waiting for unschedulable pods  {"commit": "00661aa"}
...
```

There are a few things to highlight from the logs above. The first one is in relation with the Provisioner that was used to make the instance selection. The logs point to the `controller.allocation.provisioner/default` making the selection. We will learn in the next sections how to select and use alternative Provisioners. 

In the scenario above, the log shows the instance selected was an `on-demand` instance of type **t3a.xlarge** and it was considered from the instance diversified selection: c5a.xlarge c5d.xlarge c3.xlarge c4.xlarge c5ad.xlarge c5.xlarge c6i.xlarge c1.xlarge c5n.xlarge m1.xlarge m3.xlarge t3.xlarge t3a.xlarge m5dn.xlarge m5ad.xlarge m4.xlarge m5zn.xlarge m5n.xlarge m6i.xlarge m5d.xlarge. All the instances in the list are of type `amd64` or x86_64 and all of them are of the right size to bin-pack the deployment of 2 replicas we just did.

Let's understand first why the instance selected was `on-demand`. As we stated before NodeSelectors are an opt-in mechanism which allow users to specify the nodes on which a pod can be scheduled. Karpenter uses the NodeSelectors defined in the pending pods and provisions capacity accordingly. In this case, the `inflate-amd64` deployment did not state any NodeSelector (like `spot` or `on-demand`) for the `kubernetes.sh/capacity-type`. In these situations Karpenter reverts to the default value for that well-known label. In the case of `kubernetes.sh/capacity-type` Karpenter uses `on-demand` as the default option.

So far so good. This explains why the instance was `on-demand` but not why the **t3a.xlarge** was the one selected out from the diversified selection. Internally Karpenter uses the **lowest-price** allocation strategy for `on-demand` instances. This explains why the **t3a.xlarge** was selected in this case. You can confirm this statements by running the following optional exercise. We will use CloudTrail to extract read what was the latest call to `CreateFleet` (EC2 Fleet instant mode call). Run the following command. 

```
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateFleet --max-items=1
```

This will display the last call to the `CreateFleet` done in this account. The output of `CloudTrailEvent` will display a escaped JSON document. On Cloud9 console you can type "Control-F" (or Command-F on Mac) and serch for `lowest-price`. This will highlight the section of the Create Fleet as the one below (formatted to make it easy to read).

```
"OnDemandOptions":{
    "AllocationStrategy": "lowest-price"\
}
"SpotOptions":{ 
    "AllocationStrategy":"capacity-optimized-prioritized"
}
```
 
We can also get more information about the instance selected by running the following command that filters for `intent:apps` and `kubernetes.io/arch:amd64`.

```
kubectl get node --selector=intent=apps,kubernetes.io/arch=amd64 --show-labels
```

This should display the instance with all the labels it has, similar to the output below. 

```bash
$ kubectl get node --selector=intent=apps,kubernetes.io/arch=amd64 --show-labels
NAME                                          STATUS   ROLES    AGE   VERSION               LABELS
xxxxxxxxxxxxxxxx.compute.internal   Ready    <none>   43m   v1.21.5-eks-bc4871b   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=t3a.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=eu-west-1,failure-domain.beta.kubernetes.io/zone=eu-west-1a,intent=apps,karpenter.sh/provisioner-name=default,kubernetes.io/arch=amd64,kubernetes.io/hostname=xxxxxxxxxxxxxxxx.compute.internal,kubernetes.io/os=linux,kubernetes.hs/capacity-type=on-demand,node.kubernetes.io/instance-type=t3a.xlarge,topology.kubernetes.io/region=eu-west-1,topology.kubernetes.io/zone=eu-west-1a
``` 
{{% /expand %}}

#### 2) How would you Scale the `inflate-arm64` deployment to 2 replicas ? What nodes were selected by Karpenter ? 

{{%expand "Click here to show the answer" %}} 

Let's do the same with the `inflate-arm64` deployment

To scale up the deployment run the command:

```
kubectl scale deployment inflate-arm64 --replicas 2
```

The same process for instance selection applies in this case, but note in this case the deployment had a node selector to a well-known label set up.

{{% notice info %}}
Karpenter does support the nodeSelector well-known label `node.kubernetes.io/instance-type`. This means you could set the instance type selected for the pod to a specific type, for example for the Graviton ARM64, we could select  **m6g.xlarge** instances type.
{{% /notice %}}

So in this case we should expect just one instance being considered. You can check Karpenter logs by running:

```
kubectl logs -f deployment/karpenter -c controller -n karpenter
```

The output should show something similar to the lines below

```bash
...
2022-05-12T04:20:51.896Z        INFO    controller      Batched 2 pod(s) in 1.014499438s        {"commit": "00661aa"}
2022-05-12T04:20:52.665Z        DEBUG   controller      Discovered 401 EC2 instance types       {"commit": "00661aa"}
2022-05-12T04:20:52.790Z        DEBUG   controller      Discovered EC2 instance types zonal offerings   {"commit": "00661aa"}
2022-05-12T04:20:52.960Z        DEBUG   controller      Discovered subnets: [subnet-0204b1b3b885ca98d (eu-west-1a) subnet-037d1d97a6a473fd1 (eu-west-1b) subnet-04c2ca248972479e7 (eu-west-1b) subnet-063d5c7ba912986d5 (eu-west-1a)]   {"commit": "00661aa"}
2022-05-12T04:20:53.055Z        DEBUG   controller      Discovered security groups: [sg-03ab1d5d49b00b596 sg-06e7e2ca961ab3bed]{"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:20:53.071Z        DEBUG   controller      Discovered kubernetes version 1.21      {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:20:53.140Z        DEBUG   controller      Discovered ami-05dc8c3028bc33fd6 for query "/aws/service/eks/optimized-ami/1.21/amazon-linux-2-arm64/recommended/image_id"      {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:20:53.310Z        DEBUG   controller      Created launch template, Karpenter-eksworkshop-eksctl-13655185630813568172      {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:20:55.201Z        INFO    controller      Launched instance: i-013c73aa33c952ace, hostname: ip-192-168-60-157.eu-west-1.compute.internal, type: c6g.xlarge, zone: eu-west-1b, capacityType: spot  {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:20:55.214Z        INFO    controller      Created node with 2 pods requesting {"cpu":"2125m","memory":"512M","pods":"5"} from types c6g.xlarge    {"commit": "00661aa", "provisioner": "default"}
2022-05-12T04:20:55.229Z        INFO    controller      Waiting for unschedulable pods  {"commit": "00661aa"}
...
```

As in the previous step with the `inflate-amd64`, the instance selected was `on-demand` but unlike the previous time, the well-known lable selected the instance type to use.

{{% notice tip %}}
We leave as an optional exersice the following setup. What would happen if you change the deployment and remove the `nodeSelector` section that defines the line `node.kubernetes.io/instance-type: c6g.xlarge`. If you want to try changing the deployment and checking what happens, first scale down the replicas to 0, re-deploy the `inflate-amd64` deployment, and then scale up to 2 pods. What is the difference ? What is the diversified selection now ?
{{% /notice %}}


We can also get more information about the instance selected by running the following command that filters for `intent:apps` and `kubernetes.io/arch:arm64`.

```
kubectl get node --selector=intent=apps,kubernetes.io/arch=arm64 --show-labels
```

This should display the instance with all the labels it has, similar to the output below. 

```bash
$ kubectl get node --selector=intent=apps,kubernetes.io/arch=arm64 --show-labels
NAME                                          STATUS   ROLES    AGE     VERSION               LABELS
xxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal   Ready    <none>   5m55s   v1.21.5-eks-bc4871b   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/instance-type=c6g.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=eu-west-1,failure-domain.beta.kubernetes.io/zone=eu-west-1b,intent=apps,karpenter.sh/provisioner-name=default,kubernetes.io/arch=arm64,kubernetes.io/hostname=xxxxxxxxxxxxxxxxxxxxxxxxxx.compute.internal,kubernetes.io/os=linux,kubernetes.sh/capacity-type=on-demand,node.kubernetes.io/instance-type=a1.xlarge,topology.kubernetes.io/region=eu-west-1,topology.kubernetes.io/zone=eu-west-1b
``` 
{{% /expand %}}


#### 3) Scale both deployments to 0 replicas ?

{{%expand "Click here to show the answer" %}} 

This one should be really easy. Just run the following command

To scale up the deployment run the command:

```
kubectl scale deployment inflate-amd64 --replicas 0
kubectl scale deployment inflate-arm64 --replicas 0
```
{{% notice info %}}
By setting the replicas to 0 we will be able to decommission resources and clear down the cluster in preparation for the next section.
{{% /notice %}}

{{% /expand %}}


## What Have we learned in this section : 

In this section we have learned:

* Karpenter uses well-known labels in the NodeSelector pods to Override the type instance selected. In this section we used the NodeSelector `kubernetes.io/arch` to select instances of type `amd64` x86_64 and `arm64`. We also learned that we can select a specific instance type by using the well-known lable `node.kubernetes.io/instance-type` (i.e **c6g.xlarge**).

* When NodeSelectors are not specified, Karpenter will revert to the default configuration setup for that label. In this case, the property for `kubernetes.sh/capacity-type` was not set, meaning that `spot` instances were selected even if the `default` provisioner supports both `spot` and `on-demand`.

* Karpenter scales `on-demand` instances using a diversified selection as well. Similar to Spot, instances are chosen by the ability of those to bin-pack well the pending pods. Karpenter uses the OnDemand allocation strategy **[lowest-price](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html)** to select which instance to pick from the those with available capacity.
