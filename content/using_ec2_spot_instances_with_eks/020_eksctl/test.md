---
title: "Test the Cluster"
date: 2018-08-07T13:36:57-07:00
weight: 30
---
#### Test the cluster:
Confirm your Nodes, if we see 2 nodes then we know we have authenticated correctly:

```
kubectl get nodes 
```

Export the Managed Group Worker Role Name for use throughout the workshop.

{{% notice tip %}}
Some of the optional exercises may require you to add extra IAM policies to the managed group role
for the nodes to get access to services like Cloudwatch, AppMesh, X-Ray. You can always com back to this section or the environment variable `$ROLE_NAME` to refer to the role.
{{% /notice %}}

```
NODE_GROUP_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].Name')
ROLE_NAME=$(aws eks describe-nodegroup --cluster-name eksworkshop-eksctl --nodegroup-name $NODE_GROUP_NAME | jq -r '.nodegroup["nodeRole"]' | cut -f2 -d/)
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile
```

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!

{{% notice tip %}}
Explore the Elastic Kubernetes Service (EKS) section in the AWS Console and the properties of the newly created EKS cluster.
{{% /notice %}}

{{% notice warning %}}
You might see **Error loading Namespaces** while exploring the cluster on the AWS Console. It could be because the console user role doesnt have necessary permissions on the EKS cluster's RBAC configuration in the control plane. Please expand and follow the below instructions to add necessary permissions. 
{{% /notice %}}

{{%expand "Click to reveal detailed instructions" %}}

### Console Credentials

The EKS console allows you to see not only the configuration aspects of your cluster, but also to view Kubernetes cluster objects such as Deployments, Pods, and Nodes. For this type of access, the console IAM User or Role needs to be granted permission within the cluster.

By default, the credentials used to create the cluster are automatically granted these permissions. Following along in the workshop, you've created a cluster using temporary IAM credentials from within Cloud9. This means that you'll need to add your AWS Console credentials to the cluster.

#### Import your EKS Console credentials to your new cluster:

IAM Users and Roles are bound to an EKS Kubernetes cluster via a ConfigMap named `aws-auth`. We can use `eksctl` to do this with one command.

You'll need to determine the correct credential to add for your AWS Console access. If you know this already, you can skip ahead to the `eksctl create iamidentitymapping` step below.

If you've built your cluster from Cloud9 as part of this tutorial, invoke the following within your environment to determine your IAM Role or User ARN. 

```
c9builder=$(aws cloud9 describe-environment-memberships --environment-id=$C9_PID | jq -r '.memberships[].userArn')
if echo ${c9builder} | grep -q user; then
	rolearn=${c9builder}
        echo Role ARN: ${rolearn}
elif echo ${c9builder} | grep -q assumed-role; then
        assumedrolename=$(echo ${c9builder} | awk -F/ '{print $(NF-1)}')
        rolearn=$(aws iam get-role --role-name ${assumedrolename} --query Role.Arn --output text) 
        echo Role ARN: ${rolearn}
fi
```

With your ARN in hand, you can issue the command to create the identity mapping within the cluster.

```
eksctl create iamidentitymapping --cluster eksworkshop-eksctl --arn ${rolearn} --group system:masters --username admin
```

Note that permissions can be restricted and granular but as this is a workshop cluster, you're adding your console credentials as administrator.

Now you can verify your entry in the AWS auth map within the console.

```
kubectl describe configmap -n kube-system aws-auth
```

Now you're all set to move on. For more information, check out the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) on this topic.

{{% /expand%}}
