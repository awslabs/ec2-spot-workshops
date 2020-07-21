---
title: "ECS Cluster Monitoring using Container Insights"
chapter: true
weight: 30
---

ECS Cluster Monitoring using Container Insights
---

Use CloudWatch Container Insights to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. Container Insights is available for Amazon Elastic Container
Service, Amazon Elastic Kubernetes Service, and Kubernetes platforms on Amazon EC2. The metrics include utilization for resources such as CPU, memory, disk, and network. Container Insights also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly. You can also set CloudWatch alarms on metrics that Container Insights collects

Run the below command to enable the container insights to the existing cluster. Container Insights collects metrics at the cluster, task, and service levels.

```
aws ecs update-cluster-settings --cluster EcsSpotWorkshop  --settings name=containerInsights,value=enabled
```

To deploy the CloudWatch agent to collect instance-level metrics from Amazon ECS clusters that
are hosted on EC2 instance, use a quick start setup with a default configuration

```
export Region="$AWS_REGION"
aws cloudformation create-stack --stack-name CWAgentECS-EcsSpotWorkshop-${Region}   \
--template-body file://cwagent-ecs-instance-metric-cfn.json \
--parameters ParameterKey=ClusterName,ParameterValue=EcsSpotWorkshop ParameterKey=CreateIAMRoles,ParameterValue=True   \
--capabilities CAPABILITY_NAMED_IAM \
--region ${Region}
```

The container insights metrics for this cluster will be available in cloud watch.

![Container Insights](/images/ecs-spot-capacity-providers/insights1.png)
