---
title: "Install Kube-ops-view"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

Now that we have helm installed, we are ready to use the stable helm catalog and install tools 
In this step we will install [Kube-ops-view](https://github.com/hjacobs/kube-ops-view) from **[Henning Jacobs](https://github.com/hjacobs)**. Kube-ops-view will help with understanding our cluster setup in a visual way

The following lines download the spec required to deploy kube-ops-view using a LoadBalancer Service type and creating a RBAC (Resource Base Access Control) entry for the read-only service account to read nodes and pods information from the cluster.

```
mkdir $HOME/environment/kube-ops-view
for file in kustomization.yaml rbac.yaml deployment.yaml service.yaml; do mkdir -p $HOME/environment/kube-ops-view/; curl "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/karpenter/040_k8s_tools/k8_tools.files/kube_ops_view/${file}" > $HOME/environment/kube-ops-view/${file}; done
kubectl apply -k $HOME/environment/kube-ops-view
```

{{% notice warning %}}
Monitoring and visualization shouldn't be typically be exposed publicly unless the service is properly secured and provide methods for authentication and authorization. You can still deploy kube-ops-view as Service of type **ClusterIP** by removing the  `--set service.type=LoadBalancer` section and using `kubectl proxy`. Kube-ops-view does also [support Oauth 2](https://github.com/hjacobs/kube-ops-view#configuration) 
{{% /notice %}}

To check the chart was installed successfully:

```
kubectl get svc
```

should display : 
```
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
kube-ops-view   LoadBalancer   10.100.162.132   addb6e7f91aae4b0dbd6f5833f9750c3-1014347204.eu-west-1.elb.amazonaws.com   80:31628/TCP   3m58s
```

With this we can explore kube-ops-view output by checking the details about the newly service created. 

```
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```

This will display a line similar to `Kube-ops-view URL = http://<URL_PREFIX_ELB>.amazonaws.com`
Opening the URL in your browser will provide the current state of our cluster.

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see kub-ops-view. 
{{% /notice %}}

![kube-ops-view](/images/karpenter/helm/kube-ops-view.png)

As this workshop moves along and you create Spot workers, and perform scale up and down actions, you can check the effects and changes in the cluster using kube-ops-view. Check out the different components and see how they map to the concepts that we have already covered during this workshop.

{{% notice tip %}}
Spend some time checking the state and properties of your EKS cluster. 
{{% /notice %}}

![kube-ops-view](/images/karpenter/helm/kube-ops-view-legend.png)

