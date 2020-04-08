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
mkdir -p ~/environment/cluster-autoscaler
curl -o ~/environment/cluster-autoscaler/cluster_autoscaler.yml https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/using_ec2_spot_instances_with_eks/scaling/deploy_ca.files/cluster_autoscaler.yml
sed -i "s/--AWS_REGION--/${AWS_REGION}/g" ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

### Configure the ASG
We will need to provide the names of the Autoscaling Groups that we want CA to manipulate.  

Your next task is to collect the names of the Auto Scaling Groups (ASGs) containing your Spot worker nodes. Record the names somewhere. We will use this later in the manifest file.

You can find the names in the console by **[following this link](https://console.aws.amazon.com/ec2/autoscaling/home?#AutoScalingGroups:filter=eksctl-eksworkshop-eksctl-nodegroup-dev;view=details)**. 

![ASG](/images/using_ec2_spot_instances_with_eks/scaling/scaling-asg-spot-groups.png)

You will need to save both ASG names for the next section.

### Configure the Cluster Autoscaler

Using the file browser on the left, open **cluster-autoscaler/cluster_autoscaler.yml** and amend the file:

 * Search for the block in the file containing this two lines.
 ```
            - --nodes=0:5:<AUTOSCALING GROUP NAME 4vCPUS 16GB RAM>
            - --nodes=0:5:<AUTOSCALING GROUP NAME 8vCPUS 32GB RAM>
 ```

 * Replace the content **<AUTOSCALING GROUP NAME xVPUS xxGB RAM>** with the actual names of the two nodegroups. The following shows an example configuration.
 ```
            - --nodes=0:5:eksctl-eksworkshop-eksctl-nodegroup-dev-4vcpu-16gb-spot-NodeGroup-1V6PX51MY0KGP
            - --nodes=0:5:eksctl-eksworkshop-eksctl-nodegroup-dev-8vcpu-32gb-spot-NodeGroup-S0A0UGWAH5N1
 ```

 * **Save** the file

This command contains all of the configuration for the Cluster Autoscaler. Each `--nodes` entry defines a new Autoscaling Group mapping to a Cluster Autoscaler nodegroup. Cluster Autoscaler will consider the nodegroups selected when scaling the cluster. The syntax of the line is minimum nodes **(0)**, max nodes **(5)** and **ASG Name**.


### Deploy the Cluster Autoscaler

Cluster Autoscaler gets deploy like any other pod. In this case we will use the **[kube-system namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)**, similar to what we do with other management pods.

```
kubectl apply -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
```

To watch Cluster Autoscaler logs we can use the following command:
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system --tail=10
```

#### We are now ready to scale our cluster !!

{{%attachments title="Related files" pattern=".yml"/%}}
