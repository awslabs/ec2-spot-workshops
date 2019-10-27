---
title: "Auto scaling Jenkins nodes"
date: 2018-08-07T08:30:11-07:00
weight: 80
---

In a previous module in this workshop, we saw that we can use Kubernetes cluster-autoscaler to automatically increase the size of our nodegroups (EC2 Auto Scaling groups) when our Kubernetes deployment scaled out, and some of the pods remained in `pending` state due to lack of resources on the cluster. Let's implement the same concept for our Jenkins worker nodes and see this in action.

#### Configuring cluster-autoscaler to use our new Jenkins dedicated nodegroup
1\. Edit the cluster-autoscaler deployment configuration\
```bash
kubectl edit deployment cluster-autoscaler -n kube-system
```
2\. Under the two `--nodes=` lines where you configured your EC2 Auto Scaling group names in the previous module, add another line with the name of the new Jenkins dedicated nodegroup, so your file looks like this (but with different ASG names which you collected from the EC2 Management Console)\
```
--nodes=1:5:eksctl-eksworkshop-eksctl10-nodegroup-dev-8vcpu-32gb-spot-NodeGroup-16XJ6GMZCT3XQ
--nodes=1:5:eksctl-eksworkshop-eksctl10-nodegroup-dev-4vcpu-16gb-spot-NodeGroup-1RBXH0I6585MX
--nodes=1:5:eksctl-eksworkshop-eksctl10-nodegroup-jenkins-agents-2vcpu-8gb-spot-2-NodeGroup-7GE4LS6B34DK
```
3\. Once you save/quit the file with `:x!`, the new configuration will apply\

#### Running multiple Jenkins jobs to reach a Pending pods state
If we replicate our existing Sleep-2m job and run it 5 times, that should be enough for the EC2 Instance in the Jenkins dedicated nodegroup to run out of resources (CPU/Mem), triggering a Scale Up activity from cluster-autoscaler to increase the size of the EC2 Auto Scaling group.\

1\. On the Jenkins dashboard, in the left pane, click **New Item**\
2\. Under **Enter an item name**, enter `sleep-2m-2`\
3\. At the bottom of the page, in the **Copy from** field, start typing Sleep-2m until the job name is auto completed, click **OK**\
4\. In the job configuration page, click **Save**\
5\. Repeat steps 1-4 until you have 5 identical jobs with different names\
6\. In the Jenkins main dashboard page, click the "**Schedule a build for Sleep-2m-***" on all 5 jobs, to schedule all our jobs at the same time\
7\. Monitor `kubectl get pods -w` and see pods with `jenkins-agent-abcdef` name starting up, until some of them are stuck in `pending` state. You can also use the Kube-ops-view for that purpose.\
8\. Check the cluster-autoscaler log by running `kubectl logs -f deployment/cluster-autoscaler -n kube-system`\
9\. The following lines would indicate that cluster-autoscaler successfully identified the pending Jenkins agent pods, detremined that the nodegroups that we created in the previous workshop module are not suitable due to the node selectors, and finally increased the size of the Jenkins dedicated nodegroup in order to have the kube-scheduler schedule these pending pods on new EC2 Instances in our EC2 Auto Scaling group.\
```
Pod default/default-5tb2v is unschedulable
Pod default-5tb2v can't be scheduled on eksctl-eksworkshop-eksctl10-nodegroup-dev-8vcpu-32gb-spot-NodeGroup-16XJ6GMZCT3XQ, predicate failed: GeneralPredicates predicate mismatch, reason: node(s) didn't match node selector
Pod default-5tb2v can't be scheduled on eksctl-eksworkshop-eksctl10-nodegroup-dev-4vcpu-16gb-spot-NodeGroup-1RBXH0I6585MX, predicate failed: GeneralPredicates predicate mismatch, reason: node(s) didn't match node selector
Best option to resize: eksctl-eksworkshop-eksctl10-nodegroup-jenkins-agents-2vcpu-8gb-spot-2-NodeGroup-7GE4LS6B34DK
Estimated 1 nodes needed in eksctl-eksworkshop-eksctl10-nodegroup-jenkins-agents-2vcpu-8gb-spot-2-NodeGroup-7GE4LS6B34DK
Final scale-up plan: [{eksctl-eksworkshop-eksctl10-nodegroup-jenkins-agents-2vcpu-8gb-spot-2-NodeGroup-7GE4LS6B34DK 1->2 (max: 5)}]
Scale-up: setting group eksctl-eksworkshop-eksctl10-nodegroup-jenkins-agents-2vcpu-8gb-spot-2-NodeGroup-7GE4LS6B34DK size to 2
```
10\. The end result, which you can see via `kubectl get pods` or Kube-ops-view, is that all pods were eventually scheduled, and in the Jenkins dashboard, you will see that all 5 jobs have completed successfully.

Great result! Let's move to the next step and clean up the Jenkins module.
