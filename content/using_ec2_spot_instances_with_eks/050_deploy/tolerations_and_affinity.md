---
title: "Tolerations and Affinity"
date: 2018-08-07T08:30:11-07:00
weight: 20
---

{{% notice warning %}}
![STOP](../../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Using Spot Instances with EKS and Cluster Autoscaler](https://catalog.us-east-1.prod.workshops.aws/workshops/f2826b1b-f057-4782-bc49-91004eafd48f/en-US)**.

{{% /notice %}}

## Add Tolerations

In the previous chapter [Create EKS managed node groups with Spot capacity]({{< ref "/using_ec2_spot_instances_with_eks/040_eksmanagednodegroupswithspot/workers_terraform.md" >}}) we added a taint `spotInstance: "true:PreferNoSchedule"` to both node groups. **PreferNoSchedule** is used to indicate we prefer pods not to be scheduled on Spot Instances. **NoSchedule** can also be used to enforce a hard discrimination as a taint. To overcome this taint, we need to add a toleration in the deployment. Read about how [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) are applied and modify the **monte-carlo-pi-service.yml** file accordingly.

{{%expand "Show me a hint for implementing this." %}}
As per the [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) documentation 
the objective is to add the following section to the `monte-carlo-pi-service.yml`. 

The following toleration must be added at the *spec.template.spec* level

```
      tolerations: 
      - key: "spotInstance" 
        operator: "Equal" 
        value: "true" 
        effect: "PreferNoSchedule" 
```

{{% /expand %}}

## Add Affinities

Our next task before deployment is to add [affinities](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) to the configuration. 

In the previous chapters we labeled managed node groups with On-Demand capacity with **intent: control-apps** and managed node groups with Spot capacity with **intent: apps**. Additionally EKS adds a label **eks.amazonaws.com/capacityType** and sets its value to **ON_DEMAND** for node groups with On-Demand capacity and **SPOT** for node group with Spot capacity. 

To meet the requirements we defined in previous chapter: *application to be deployed only on nodes that have been labeled with `intent: apps`* and *application to prefer Spot Instances over on-demand Instances*, we need to add two affinity properties:

- a *requiredDuringSchedulingIgnoredDuringExecution* affinity: also known as "hard" affinity that will limit our deployment to nodes label with **intent: apps** 
- a *preferredDuringSchedulingIgnoredDuringExecution* affinity: also known as "soft" affinity that express our preference for nodes of a specific type. In this case Spot Instances labeled with **eks.amazonaws.com/capacityType: SPOT**.

Read about how affinities can be used to [assign pods to nodes](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) and modify the **monte-carlo-pi-service.yml** file accordingly.

{{%expand "Show me a hint for implementing this." %}}
As per the [Assign Pods to Nodes](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) documentation the objective is to add the following section to the `monte-carlo-pi-service.yml`. 

The following affinities must be added at the *spec.template.spec* level

```
      affinity: 
        nodeAffinity: 
          preferredDuringSchedulingIgnoredDuringExecution: 
          - weight: 1 
            preference: 
              matchExpressions: 
              - key: eks.amazonaws.com/capacityType 
                operator: In 
                values: 
                - SPOT 
          requiredDuringSchedulingIgnoredDuringExecution: 
            nodeSelectorTerms: 
            - matchExpressions: 
              - key: intent 
                operator: In 
                values: 
                - apps 
```

{{% /expand %}}


If you are still struggling with the implementation, then run below command to overwrite `monte-carlo-pi-service.yml` template with the final solution. 

{{%expand "Show me how to apply all the changes and deploy the final solution" %}}
```
cat <<EoF > ~/environment/monte-carlo-pi-service.yml
---
apiVersion: v1 
kind: Service 
metadata: 
  name: monte-carlo-pi-service 
spec: 
  type: LoadBalancer 
  ports: 
    - port: 80 
      targetPort: 8080 
  selector: 
    app: monte-carlo-pi-service 
--- 
apiVersion: apps/v1 
kind: Deployment 
metadata: 
  name: monte-carlo-pi-service 
  labels: 
    app: monte-carlo-pi-service 
spec: 
  replicas: 2 
  selector: 
    matchLabels: 
      app: monte-carlo-pi-service 
  template: 
    metadata: 
      labels: 
        app: monte-carlo-pi-service 
    spec:
      tolerations: 
      - key: "spotInstance" 
        operator: "Equal" 
        value: "true" 
        effect: "PreferNoSchedule" 
      affinity: 
        nodeAffinity: 
          preferredDuringSchedulingIgnoredDuringExecution: 
          - weight: 1 
            preference: 
              matchExpressions: 
              - key: eks.amazonaws.com/capacityType 
                operator: In 
                values: 
                - SPOT 
          requiredDuringSchedulingIgnoredDuringExecution: 
            nodeSelectorTerms: 
            - matchExpressions: 
              - key: intent 
                operator: In 
                values: 
                - apps 
      containers: 
        - name: monte-carlo-pi-service 
          image: ruecarlo/monte-carlo-pi-service
          resources: 
            requests: 
              memory: "512Mi" 
              cpu: "1024m" 
            limits: 
              memory: "512Mi" 
              cpu: "1024m" 
          securityContext: 
            privileged: false 
            readOnlyRootFilesystem: true 
            allowPrivilegeEscalation: false 
          ports: 
            - containerPort: 8080 

EoF

```
{{% /expand %}}