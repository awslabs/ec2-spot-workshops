---
title: "Multi-Architecture deployments"
date: 2021-11-07T11:05:19-07:00
weight: 80
draft: false
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

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
        karpenter.sh/capacity-type: on-demand
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

Before we check the selected node, let's cover what Karpenter is expected to do in this scenario. Node selectors are an opt-in mechanism which allow users to specify the nodes on which a pod can scheduled. Karpenter recognizes well-known node selectors on unschedulable pods and uses them to constrain the nodes it provisions. `kubernetes.io/arch` is one of the [well-known node selectors](https://kubernetes.io/docs/reference/labels-annotations-taints/)  supported by Karpenter. When Karpenter finds that the `kubernetes.io/arch` was set to `amd64` it does ensure that provisioned nodes are constrained accordingly to `amd64` instances.

Let's confirm that was the case and only `amd64` considered for scaling up. We can check karpenter logs by running the following command.

```
alias kl='kubectl -n karpenter logs -l app.kubernetes.io/name=karpenter --all-containers=true -f --tail=20'
kl
```

The output should show something similar to the lines below

```bash
...
2022-09-05T11:00:36.834Z        DEBUG   controller.provisioning 27 out of 509 instance types were excluded because they would breach provisioner limits {"commit": "b157d45"}
2022-09-05T11:00:36.842Z        INFO    controller.provisioning Found 2 provisionable pod(s)    {"commit": "b157d45"}
2022-09-05T11:00:36.842Z        INFO    controller.provisioning Computed 1 new node(s) will fit 2 pod(s)        {"commit": "b157d45"}
2022-09-05T11:00:36.857Z        INFO    controller.provisioning Launching node with 2 pods requesting {"cpu":"2125m","memory":"512M","pods":"5"} from types t3a.xlarge, c6a.xlarge, c5a.xlarge, t3.xlarge, c6i.xlarge and 332 other(s)  {"commit": "b157d45", "provisioner": "default"}
2022-09-05T11:00:37.072Z        DEBUG   controller.provisioning.cloudprovider  Discovered ami-044d355a56926f0c6 for query "/aws/service/eks/optimized-ami/1.23/amazon-linux-2/recommended/image_id"     {"commit": "b157d45", "provisioner": "default"}
2022-09-05T11:00:37.290Z        DEBUG   controller.provisioning.cloudprovider  Created launch template, Karpenter-eksworkshop-eksctl-10619024032654607850      {"commit": "b157d45", "provisioner": "default"}
2022-09-05T11:00:39.176Z        INFO    controller.provisioning.cloudprovider  Launched instance: i-0c42c1c80fe4188f9, hostname: ip-192-168-94-187.eu-west-1.compute.internal, type: t3a.xlarge, zone: eu-west-1a, capacityType: on-demand     {"commit": "b157d45", "provisioner": "default"}
...
```

There are a few things to highlight from the logs above. The first one is in relation with the Provisioner that was used to make the instance selection. The logs point to the `controller.allocation.provisioner/default` making the selection. We will learn in the next sections how to select and use alternative Provisioners. 

In the scenario above, the log shows the instance selected was an `on-demand` instance of type **t3a.xlarge** and it was considered from the instance diversified selection: t3a.xlarge, c6a.xlarge, c5a.xlarge, c6i.xlarge, t3.xlarge and 332 other(s). All the instances in the list are of type `amd64` or x86_64 and all of them are of the right size to at least fit the deployment of 2 replicas .

Let's understand first why the instance selected was `on-demand`. As we stated before NodeSelectors are an opt-in mechanism which allow users to specify the nodes on which a pod can be scheduled. Karpenter uses the NodeSelectors defined in the pending pods and provisions capacity accordingly. In this case, the `inflate-amd64` deployment did not state any NodeSelector (like `spot` or `on-demand`) for the `kubernetes.sh/capacity-type`. In these situations Karpenter reverts to the default value for that well-known label. In the case of `kubernetes.sh/capacity-type` Karpenter uses `on-demand` as the default option.

So far so good. This explains why the instance was `on-demand` but not why the **t3a.xlarge** was the one selected out from the diversified selection. Internally Karpenter uses the **lowest-price** allocation strategy for `on-demand` instances. This explains why the **t3a.xlarge** was selected in this case. You can confirm this statements by running the following optional exercise. We will use CloudTrail to extract read what was the latest call to `CreateFleet` (EC2 Fleet instant mode call). Run the following command. 

```
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateFleet --max-items=1
```

This will display the last call to the `CreateFleet` done in this account. The output of `CloudTrailEvent` will display a escaped JSON document. On Cloud9 console you can type "Control-F" (or Command-F on Mac) and serch for `lowest-price`. This will highlight the section of the Create Fleet as the one below (formatted to make it easy to read).

```
"OnDemandOptions":{
    "AllocationStrategy": "lowest-price"
}
"SpotOptions":{ 
    "AllocationStrategy":"price-capacity-optimized"
}
```
 
We can also get more information about the instance selected by running the following command that filters for `intent:apps` and `kubernetes.io/arch:amd64`.

```
kubectl get node --selector=intent=apps -L kubernetes.io/arch -L node.kubernetes.io/instance-type -L karpenter.sh/provisioner-name -L topology.kubernetes.io/zone -L karpenter.sh/capacity-type
```

This should display the instance with all the labels it has, similar to the output below. 

```bash
kubectl get node --selector=intent=apps -L kubernetes.io/arch -L node.kubernetes.io/instance-type -L karpenter.sh/provisioner-name -L topology.kubernetes.io/zone -L karpenter.sh/capacity-type
NAME                                           STATUS   ROLES    AGE     VERSION                ARCH    INSTANCE-TYPE   PROVISIONER-NAME   ZONE         CAPACITY-TYPE
ip-192-168-49-164.us-east-2.compute.internal   Ready    <none>   14m     v1.23.13-eks-fb459a0   amd64   c5ad.2xlarge    default            us-east-2b   spot
ip-192-168-52-232.us-east-2.compute.internal   Ready    <none>   3m19s   v1.23.13-eks-fb459a0   amd64   c6a.xlarge      default            us-east-2b   on-demand
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
alias kl='kubectl -n karpenter logs -l app.kubernetes.io/name=karpenter --all-containers=true -f --tail=20'
kl
```

The output should show something similar to the lines below

```bash
...
2022-09-05T11:02:52.560Z        DEBUG   controller.provisioning 27 out of 509 instance types were excluded because they would breach provisioner limits {"commit": "b157d45"}
2022-09-05T11:02:52.566Z        INFO    controller.provisioning Found 2 provisionable pod(s)    {"commit": "b157d45"}
2022-09-05T11:02:52.566Z        INFO    controller.provisioning Computed 1 new node(s) will fit 2 pod(s)        {"commit": "b157d45"}
2022-09-05T11:02:52.566Z        INFO    controller.provisioning Launching node with 2 pods requesting {"cpu":"2125m","memory":"512M","pods":"5"} from types c6g.xlarge  {"commit": "b157d45", "provisioner": "default"}
2022-09-05T11:02:52.756Z        DEBUG   controller.provisioning.cloudprovider  Discovered ami-0fe832d5034e25cce for query "/aws/service/eks/optimized-ami/1.23/amazon-linux-2-arm64/recommended/image_id"       {"commit": "b157d45", "provisioner": "default"}
2022-09-05T11:02:52.992Z        DEBUG   controller.provisioning.cloudprovider  Created launch template, Karpenter-eksworkshop-eksctl-906121585403847898 {"commit": "b157d45", "provisioner": "default"}
2022-09-05T11:02:54.909Z        INFO    controller.provisioning.cloudprovider  Launched instance: i-0b4bd3ff55895298a, hostname: ip-192-168-56-110.eu-west-1.compute.internal, type: c6g.xlarge, zone: eu-west-1b, capacityType: spot   {"commit": "b157d45", "provisioner": "default"}
...
```

Unlike in the previous step with the `inflate-amd64`, the instance selected was `spot` and the well-known lable selected the instance type to use.

{{% notice tip %}}
We leave as an optional exersice the following setup. What would happen if you change the deployment and remove the `nodeSelector` section that defines the line `node.kubernetes.io/instance-type: c6g.xlarge`. If you want to try changing the deployment and checking what happens, first scale down the replicas to 0, re-deploy the `inflate-amd64` deployment, and then scale up to 2 pods. What is the difference ? What is the diversified selection now ?
{{% /notice %}}


We can also get more information about the instance selected by running the following command that filters for `intent:apps` and `kubernetes.io/arch:arm64`.

```
kubectl get node --selector=intent=apps,kubernetes.io/arch=arm64 -L kubernetes.io/arch -L node.kubernetes.io/instance-type -L karpenter.sh/provisioner-name -L topology.kubernetes.io/zone -L karpenter.sh/capacity-type
```

This should display the instance with all the labels it has, similar to the output below. 

```bash
$ kubectl get node --selector=intent=apps,kubernetes.io/arch=arm64 -L kubernetes.io/arch -L node.kubernetes.io/instance-type -L karpenter.sh/provisioner-name -L topology.kubernetes.io/zone -L karpenter.sh/capacity-type
NAME                                          STATUS   ROLES    AGE   VERSION                ARCH    INSTANCE-TYPE   PROVISIONER-NAME   ZONE         CAPACITY-TYPE
ip-192-168-5-202.us-east-2.compute.internal   Ready    <none>   66s   v1.23.13-eks-fb459a0   arm64   c6g.xlarge      default            us-east-2a   spot
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

* When NodeSelectors are not specified, Karpenter will revert to the default configuration setup for that label. In this case, the property for `kubernetes.sh/capacity-type` was not set in the case of the `arm64` deployment, meaning that `spot` instances were selected even if the `default` provisioner supports both `spot` and `on-demand`. 

* Karpenter scales `on-demand` instances using a diversified selection as well. Similar to Spot, instances are chosen by the ability of those to bin-pack well the pending pods. Karpenter uses the OnDemand allocation strategy **[lowest-price](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-configuration-strategies.html)** to select which instance to pick from the those with available capacity.
