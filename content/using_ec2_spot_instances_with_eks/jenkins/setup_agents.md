---
title: "Setting up Jenkins agents"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

We now have our Jenkins Master running inside our EKS cluster, and we can reach the Jenkins dashboard via an ELB. We can create jobs which will be executed by Jenkins agents in pods within our cluster, but before we do that, let's create a dedicated Spot based nodegroup for our Jenkins agents, which will be slightly different from our existing nodegroups.

#### Creating a new Spot Instances nodegroup for our Jenkins agent pods
Earlier in the workshop, in the **Adding Spot Workers with eksctl** step, we created nodegroups that run a diversified set of Spot Instances to run our applications.

Let's create a new eksctl nodegroup configuration file called `spot_nodegroup_jenkins.yml`. The Jenkins default resource requirements (Request and Limit CPU/Memory) are 512m (~0.5 vCPU) and 512Mi (~0.5 GB RAM), and since we are not going to perform any large build jobs in this workshop, we can stick to the defaults and also choose relatively small instance types that can accommodate the Jenkins agent pods.

```
cat <<EoF > ~/environment/spot_nodegroup_jenkins.yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
    name: eksworkshop-eksctl
    region: $AWS_REGION
nodeGroups:
    - name: jenkins-agents-2vcpu-8gb-spot
      minSize: 1
      maxSize: 5
      instancesDistribution:
        instanceTypes: ["m5.large", "m5d.large", "m4.large","t3.large","t3a.large","m5a.large","t2.large"] 
        onDemandBaseCapacity: 0
        onDemandPercentageAboveBaseCapacity: 0
        spotInstancePools: 4
      labels:
        lifecycle: Ec2Spot
        intent: jenkins-agents
      tags:
          k8s.io/cluster-autoscaler/node-template/label/intent: jenkins-agents
EoF
```

This will create a `spot_nodegroup_jenkins.yml` file that we will use to instruct eksctl to create one nodegroup (EC2 Auto Scaling group), with the labels `intent: jenkins-agents` and `lifecycle: Ec2Spot`. The ASG will also have a custom tag key `k8s.io/cluster-autoscaler/node-template/label/intent` with the value `jenkins-agents` - This is in order for Kubernetes cluster-autoscaler to respect the node selector configuration that we will apply later in the module.

```
eksctl create nodegroup -f spot_nodegroup_jenkins.yml
```

{{% notice note %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}


#### Instructing Jenkins to run jobs on the new, Spot dedicated nodegroup
1. In  the Jenkins dashboard, browse to **Manage Jenkins** -> **Configure System**
2. At the very bottom of the page, near the end of the Pod template section, click the **Advanced** button (right above **Delete Template**)
3. In the **Node Selector** field, add the following: `intent=jenkins-agents,lifecycle=Ec2Spot`
4. Click **Save**

![Jenkins Login](/images/jenkinslabels.png)


Now, when Jenkins creates new pods, these will be created with a Node Selector that instructs the kube-scheduler to only deploy the pods on nodes with the above mentioned labels, which only exist in the dedicated Jenkins nodegroup.

Move to the next step in the workshop to learn how to increase the resilience of your Jenkins jobs.

\
\
\
\
\
\
\
\
\
\
\

# probably will not be included



#### Configuring a new Kubernetes namespace 

```bash
kubectl create namespace jenkins-agents
```

#### pointing the Jenkins agents to run within the new dedicated namespace

1. From the Jenkins home screen, click **Manage Jenkins** and go to **Configure System** 
2. Scroll down in the page, and under the Cloud -> Kubernetes section, find the **Kubernetes Namespace** field
3. Replace **default** with **jenkins-agents**
4. Click **Save** at the bottom of the dashboard.