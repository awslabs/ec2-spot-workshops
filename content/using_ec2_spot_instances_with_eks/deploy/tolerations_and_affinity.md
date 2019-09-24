---
title: "Tolerations and Affinity"
date: 2018-08-07T08:30:11-07:00
weight: 20
---

## Adding Tolerations

Our next task is to add tolerations and affinities to the application.

In the previous section we created two nodegroups that were tainted with 
`spotInstance: "true:PreferNoSchedule"`. **PreferNoSchedule** is used to indicate we prefer pods not be scheduled on Spot Instances. **NoSchedule** can also be used to enforce a hard discrimination as a taint. 

To overcome the `spotInstance: "true:PreferNoSchedule"` taint, we need to create a toleration in the deployment.
Read about how [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) are applied and 
modify the **monte-carlo-pi-service.yml** file accordingly.


{{%expand "Show me a hint for implementing this." %}}
As per the [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) documentation 
the objective is to add the following section to the `monte-carlo-pi-service.yml`. 

The following toleration must be added at the *spec.template.spec* level

```bash
      tolerations: 
      - key: "spotInstance" 
        operator: "Equal" 
        value: "true" 
        effect: "PreferNoSchedule" 
```

If you are still struggling with the implementation, the solution file is available here : **[monte-carlo-pi-service-final.yml](deploy_app.files/monte-carlo-pi-service-final.yml)**
{{% /expand %}}


## Adding Affinities

Our final task before deploying to meet the criteria defined above is to add [affinities](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

In the previous section we created nodegroups with the lables `intent` and values **control-apps** and **apps** and `lifecycle` with values **OnDemand** and **Ec2Spot**. For us to adhere to the criteria above we will need to add two affinity properties:

- a *requiredDuringSchedulingIgnoredDuringExecution* affinity: also known as "hard" affinity that will limit our deployment to nodes label with **intent: apps** 
- a *preferredDuringSchedulingIgnoredDuringExecution* affinity: also known as "soft" affinity that express our preference for nodes of a specific type. In this case Spot instances labeled with **lifecycle: Ec2Spot**.


Read about how affinities can be used to [assign pods to nodes](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) and modify the **monte-carlo-pi-service.yml** file accordingly.


{{%expand "Show me a hint for implementing this." %}}
As per the [Assign Pods to Nodes](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) documentation the objective is to add the following section to the `monte-carlo-pi-service.yml`. 

The following affinities must be added at the *spec.template.spec* level

```bash
      affinity: 
        nodeAffinity: 
          preferredDuringSchedulingIgnoredDuringExecution: 
          - weight: 1 
            preference: 
              matchExpressions: 
              - key: lifecycle 
                operator: In 
                values: 
                - Ec2Spot 
          requiredDuringSchedulingIgnoredDuringExecution: 
            nodeSelectorTerms: 
            - matchExpressions: 
              - key: intent 
                operator: In 
                values: 
                - apps 
```

If you are still struggling with the implementation, the solution file is available here : **[monte-carlo-pi-service-final.yml](deploy_app.files/monte-carlo-pi-service-final.yml)**

{{% /expand %}}

{{%attachments title="Related files" pattern=".yml"/%}}
