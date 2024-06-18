---
title: "Install Kube-ops-view"
chapter: false
weight: 30
---

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

In this step we will install [Kube-ops-view](https://github.com/hjacobs/kube-ops-view) from **[Henning Jacobs](https://github.com/hjacobs)**. Kube-ops-view will help with understanding our cluster setup in a visual way.

The following lines download the spec required to deploy kube-ops-view using a LoadBalancer Service type and creating a RBAC (Resource Base Access Control) entry for the read-only service account to read nodes and pods information from the cluster.

```
mkdir $HOME/environment/kube-ops-view
for file in kustomization.yaml rbac.yaml deployment.yaml service.yaml; do mkdir -p $HOME/environment/kube-ops-view/; curl "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/using_ec2_spot_instances_with_eks/030_k8s_tools/k8_tools.files/kube_ops_view/${file}" > $HOME/environment/kube-ops-view/${file}; done
kubectl apply -k $HOME/environment/kube-ops-view
```

Open the kube-ops-view site by checking the details about the newly service created.

```
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```

This will display a line similar to `Kube-ops-view URL = http://<URL_PREFIX_ELB>.amazonaws.com`
Opening the URL in your browser will provide the current state of our cluster.

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see kub-ops-view. 
{{% /notice %}}

![kube-ops-view](/images/using_ec2_spot_instances_with_eks/helm/kube-ops-view.png)

As this workshop moves along and you create Spot workers, and perform scale up and down actions, you can check the effects and changes in the cluster using kube-ops-view. Check out the different components and see how they map to the concepts that we have already covered during this workshop.

{{% notice tip %}}
Spend some time checking the state and properties of your EKS cluster. 
{{% /notice %}}

![kube-ops-view](/images/using_ec2_spot_instances_with_eks/helm/kube-ops-view-legend.png)

<!--  

# I'm commenting this section temporarily The ClusterRole associated with
# the chart does not provide all the permissions for kube-report-ops
# to work well and instead we are getting an error at the moment on EKS 1.16
# this will require either a change in the kube-report-ops or changes to modify
# The clusterrole once the helm chart is installed; I'll contribute this to the
# upstream project and then get this section enabled back again.

### Exercise
 
{{% notice info %}}
In this exercise we will install and explore another great tool, **[kube-resource-report](https://github.com/hjacobs/kube-resource-report)** by [Henning Jacob](https://github.com/hjacobs). Kube-resource-report generates a utilization report and associates a cost to namespaces, applications and pods. Kube-resource-report does also take into consideration the Spot savings. It uses the [describe-spot-price-history](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSpotPriceHistory.html) average value of the reported in the last three days to provide an estimate for the cost of EC2 Spot nodes.  
{{% /notice %}}

 * Now that we have a way to visualize our cluster with kube-ops-view, how about visualizing the estimated cost used by our cluster  namespaces, applications and pods? Follow the instructions described at **[kube-resource-report](https://github.com/hjacobs/kube-resource-report)** github repository and figure out how to deploy the helm chart with the right required parameters. (links to hints: [1](https://helm.sh/docs/chart_template_guide/values_files/), [2](https://github.com/hjacobs/kube-resource-report/blob/master/chart/kube-resource-report/values.yaml), [3](https://github.com/hjacobs/kube-resource-report/blob/master/chart/kube-resource-report/templates/deployment.yaml), [4](https://github.com/hjacobs/kube-resource-report/blob/master/chart/kube-resource-report/templates/service.yaml))


{{%expand "Show me the solution" %}}
Execute the following command in your Cloud9 terminal
```
git clone https://github.com/hjacobs/kube-resource-report
helm install kube-resource-report \
--set service.type=LoadBalancer \
--set service.port=80 \
--set container.port=8080 \
--set rbac.create=true \
--set nodeSelector.intent=control-apps \
kube-resource-report/unsupported/chart/kube-resource-report
```

This will install the chart with the right setup, ports and the identification of the label *aws.amazon.com/spot*, that when is defined on a resource, will be used to extract EC2 Spot historic prices associated with the resource. Note that during the rest of the workshop we will still use the `lifecycle` label to identify Spot instances, and only use `aws.amazon.com/spot` to showcase the integration with kube-resource-report. 

Once installed, you should be able to get the Service/Loadbalancer URL using:
```
kubectl get svc kube-resource-report | tail -n 1 | awk '{ print "Kube-resource-report URL = http://"$4 }'
```
{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in four minutes or so you should see kube-resource-report. 
{{% /notice %}}

Kube-resource-reports will keep track in time of the cluster. Further more, it identifies EC2 Spot nodes and uses [AWS Historic Spot price API](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSpotPriceHistory.html) to calculates the current price of the EC2 Spot instances and attribute the correct cost.

![kube-resource-reports](/images/using_ec2_spot_instances_with_eks/helm/kube-resource-reports.png)

{{% /expand %}}

The result of this exercise should show kube-resource-report estimated cost of your cluster as well as the utilization of different components.

-->