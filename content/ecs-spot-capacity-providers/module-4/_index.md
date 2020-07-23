---
title: "Module-4  Cluster Monitoring and Spot Interruption Handling"
chapter: true
weight: 40
---

## **Module-4  Cluster Monitoring and Spot Interruption Handling**

### ECS Cluster Monitoring using Container Insights

Use CloudWatch Container Insights to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. Container Insights is available for Amazon Elastic Container Service, Amazon Elastic Kubernetes Service, and Kubernetes platforms on Amazon EC2. The metrics include utilization for resources such as CPU, memory, disk, and network. Container Insights also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly. You can also set CloudWatch alarms on metrics that Container Insights collects 

Run the below command to enable the container insights to the existing cluster. Container Insights collects metrics at the cluster, task, and service levels.

```
aws ecs update-cluster-settings --cluster EcsSpotWorkshopCluster  --settings name=containerInsights,value=enabled
```

To deploy the CloudWatch agent to collect instance-level metrics from Amazon ECS clusters that

are hosted on EC2 instance, use a quick start setup with a default configuration,

```
export ClusterName=EcsSpotWorkshopCluster
export Region="$AWS_REGION"
aws cloudformation create-stack --stack-name CWAgentECS-${ClusterName}-${Region}   \
 --template-body https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/ecs-task-definition-templates/deployment-mode/daemon-service/cwagent-ecs-instance-metric/cloudformation-quickstart/cwagent-ecs-instance-metric-cfn.json  \
 --parameters ParameterKey=ClusterName,ParameterValue=${ClusterName} ParameterKey=CreateIAMRoles,ParameterValue=True   \
 --capabilities CAPABILITY_NAMED_IAM \
 --region ${Region}
```

The container insigts metrics for this cluster will be available in cloud watch.

Amazon EC2 terminates your Spot Instance when it needs the capacity back. Amazon EC2 provides a Spot Instance interruption notice, which gives the instance a two-minute warning before it is interrupted.
