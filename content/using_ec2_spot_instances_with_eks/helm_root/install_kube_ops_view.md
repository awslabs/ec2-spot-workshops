---
title: "Install Kube-ops-view"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

Now that we have helm installed we are ready to use the stable helm catalog and install great tools 
that will help with understanding our cluster setup in a visual way.The first of those tools that we are going to
install is [Kube-ops-view](https://github.com/hjacobs/kube-ops-view) from Henning Jacobs.

The following line updates the stable helm repository and then installs kube-ops-view using a LoadBalancer Service type and creating a 
RBAC (Resource Base Access Control) entry for the read-only service account to read nodes and pods information from the cluster.

{{% notice warning %}}
Monitoring and visualization shouldn't be typically be exposed  as a LoadBalancer Service unless they are properly 
secured and provide methods for authentication and authorization. 
{{% /notice %}}


```bash
helm repo update
helm install stable/kube-ops-view --name kube-ops-view --set service.type=LoadBalancer --set rbac.create=True
```

A successful execution of the command will display the set of resources created and will suggest using kubectl proxy and
a local URL for the service. Instead, by passing LoadBalancer as a service type, we have created a Service with an external IP address.


To check that the chart was installed successfully:

```bash
helm list
```

should display : 
```bash
NAME            REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
kube-ops-view   1               Sun Sep 22 11:47:31 2019        DEPLOYED        kube-ops-view-1.1.0     0.11            default  
```

With this we can explore kube-ops-view output by checking the details about the newly service created. 

```bash
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```

This will display a line similar to `Kube-ops-view URL = http://<URL_PREFIX_ELB>.amazonaws.com`
Opening the URL in your browser will provide the current state of our cluster.

![kube-ops-view](/images/using_ec2_spot_instances_with_eks/helm/kube-ops-view.png)



As this workshop moves along and you create Spot workers, scale up and down, you can check the effects and changes 
in the cluster using  kube-ops-view. Check out the different components and see how they map to the concepts that 
we have already covered during this workshop.

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; 
usually in two minutes you should see kub-ops-view. 
{{% /notice %}}