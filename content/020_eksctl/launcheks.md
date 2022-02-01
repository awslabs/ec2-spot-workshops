---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role]({{< relref "../010_prerequisites/update_workspaceiam.md#validate_iam" >}}) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:
**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}

### Validate the IAM role {#validate_iam}

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

You can verify what the output an correct role shoulld be in the **[validate the IAM role section]({{< relref "../010_prerequisites/update_workspaceiam.md" >}})**. If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}


### Create an EKS cluster

Create an eksctl deployment file (eksworkshop.yaml) to create an EKS cluster:


```
cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.21"
iam:
  withOIDC: true
managedNodeGroups:
- amiFamily: AmazonLinux2
  instanceType: m5.large
  name: mng-od-m5large
  desiredCapacity: 2
  maxSize: 3
  minSize: 0
  labels:
    alpha.eksctl.io/cluster-name: eksworkshop-eksctl
    alpha.eksctl.io/nodegroup-name: mng-od-m5large
    intent: control-apps
  tags:
    alpha.eksctl.io/nodegroup-name: mng-od-m5large
    alpha.eksctl.io/nodegroup-type: managed
    k8s.io/cluster-autoscaler/node-template/label/intent: control-apps
  iam:
    withAddonPolicies:
      autoScaler: true
      cloudWatch: true
      albIngress: true
  privateNetworking: true

EOF
```

Next, use the file you created as the input for the eksctl cluster creation.

```
eksctl create cluster -f eksworkshop.yaml
```

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}

`eksctl create cluster` command allows you to create the cluster and managed nodegroups in sequence. There are a few things to note in the configuration that we just used to create the cluster and a managed nodegroup.

 * Nodegroup configurations are set under the **managedNodeGroups** section, this indicates that the node group is managed by EKS.
 * Nodegroup instance type is **m5.large** with **minSize** to 0, **maxSize** to 3 and **desiredCapacity** to 2. This nodegroup has capacity type set to On-Demand Instances by default.

 * Notice that the we add 3 node labels:
   * **alpha.eksctl.io/cluster-name**, to indicate the nodes belong to **eksworkshop-eksctl** cluster.
   * **alpha.eksctl.io/nodegroup-name**, to indicate the nodes belong to **mng-od-m5large** nodegroup.
   * **intent**, to allow you to deploy control applications on nodes that have been labeled with value **control-apps**
  
 * Amazon EKS adds an additional Kubernetes label **eks.amazonaws.com/capacityType: ON_DEMAND**, to all On-Demand Instances in your managed node group. You can use this label to schedule stateful applications on On-Demand nodes.