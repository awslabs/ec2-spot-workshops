---
title: "Configure Cluster Autoscaler (CA)"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

We will start by deploying [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler). Cluster Autoscaler for AWS provides integration with Auto Scaling groups. It enables users to choose from four different options of deployment:

* One Auto Scaling group 
* **Multiple Auto Scaling groups** - This is what we will use
* Auto-Discovery
* Master Node setup

In this workshop we will configure Cluster Autoscaler to scale using the Autoscaling groups associated with the nodegroups that we created in the [Adding Spot Workers with eksctl]({{< ref "/using_ec2_spot_instances_with_eks/spotworkers/workers_eksctl.md" >}}) section.

### Configure the Cluster Autoscaler (CA)
We have provided a manifest file to deploy the CA. Copy the commands below into your Cloud9 Terminal.

```
mkdir ~/environment/cluster-autoscaler
cd ~/environment/cluster-autoscaler
wget https://eksworkshop.com/scaling/deploy_ca.files/cluster_autoscaler.yml
```

### Configure the ASG
We will need to provide the names of the Autoscaling Groups that we want CA to manipulate. 

Collect the names of the Auto Scaling Groups (ASGs) containing your Spot worker nodes. Record the names somewhere. We will use this later in the manifest file.

You can find the names in the console by following this [link](https://console.aws.amazon.com/ec2/autoscaling/home?#AutoScalingGroups:filter=eksctl-eksworkshop-eksctl-nodegroup-dev;view=details). 

![ASG](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-spot-groups.png)

You will need to note both names.

### Configure the Cluster Autoscaler

Using the file browser on the left, open **cluster-autoscaler/cluster_autoscaler.yml** and ammend the file:

 * Update the image to use CA v1.13.7. Search for the line containing `- image: k8s.gcr.io/cluster-autoscaler:v1.2.2` and replace the version with **v1.13.7**

 * Search for `command:` and within this block, replace the placeholder text `<AUTOSCALING GROUP NAME>` with the ASG name using 4vCPUs and 16GB of Ram. Duplicate the line this time using the ASG  name for the 8vCPUs and 32GB nodegroup.
 
 * In the lines that we just changed, modify the numbers from **2:8** to **1:5** insted. This are
 The min and max nodes for the ASG in each group. 

 * Update AWS_REGION value to reflect the region you are using.

 *  **Save** the file

The file should look similar to the following.
```bash
command:
  - ./cluster-autoscaler
  - --v=4
  - --stderrthreshold=info
  - --cloud-provider=aws
  - --skip-nodes-with-local-storage=false
  - --nodes=1:5:eksctl-eksworkshop-eksctl-nodegroup-dev-4vcpu-16gb-spot-NodeGroup-1V6PX51MY0KGP
  - --nodes=1:5:eksctl-eksworkshop-eksctl-nodegroup-dev-8vcpu-32gb-spot-NodeGroup-S0A0UGWAH5N1
env:
  - name: AWS_REGION
    value: us-east-1
```
This command contains all of the configuration for the Cluster Autoscaler. Each `--nodes` entry defines a new Autoscaling Group mapping to a Cluster Autoscaler nodegroup to be consider when scaling the cluster. The syntax of the line is minimum nodes **(1)**, max nodes **(5)** and **ASG Name**.

Although Cluster Autoscaler is the de facto standard for automatic scaling in K8s, it is not part of the main release. We deploy it like any other pod in the kube-system namespace, similar to other management pods.

### Deploy the Cluster Autoscaler

```
kubectl apply -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

Watch the logs
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system --tail=10
```

#### We are now ready to scale our cluster

{{%attachments title="Related files" pattern=".yml"/%}}
