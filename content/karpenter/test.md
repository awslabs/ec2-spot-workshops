---
title: "Test the Cluster"
date: 2018-08-07T13:36:57-07:00
weight: 20
---
## Test the cluster:
Confirm your Nodes, if we see 2 nodes then we know we have authenticated correctly:

```
kubectl get nodes 
```

Export the Managed Group Worker Role Name, Cluster Name, and AWS Default region for use throughout the workshop.


## Store Cluster setup into ".bash_profile"

During this workshop we will refer to a few environment variables that point to the cluster setup, such as the cluster name, the Roles used, the Cluster API-Server endpoint, etc. 

Run the following command so that the variables get stored in your `~/.bash_profile`. As a result you will be able to open multiple terminals in Cloud9 ide while still preserving the variables defined in this step.

```
export CLUSTER_NAME=eksworkshop-eksctl
NODE_GROUP_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].Name')
ROLE_NAME=$(aws eks describe-nodegroup --cluster-name eksworkshop-eksctl --nodegroup-name $NODE_GROUP_NAME | jq -r '.nodegroup["nodeRole"]' | cut -f2 -d/)
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile
echo "export CLUSTER_NAME=eksworkshop-eksctl" >> ~/.bash_profile
echo "export AWS_DEFAULT_REGION=$AWS_REGION" >> ~/.bash_profile
echo "export CLUSTER_ENDPOINT=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output json)" >> ~/.bash_profile
echo "export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)" >> ~/.bash_profile
source ~/.bash_profile
```

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!

