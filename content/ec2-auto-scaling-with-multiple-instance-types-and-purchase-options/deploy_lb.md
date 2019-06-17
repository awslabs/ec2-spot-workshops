+++
title = "Deploy the AWS Elastic Load Balancer"
weight = 90
+++

A load balancer serves as the single point of contact for clients. The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones. This increases the availability of your application. You add one or more listeners to your load balancer.

A listener checks for connection requests from clients, using the protocol and port that you configure, and forwards requests to one or more target groups, based on the rules that you define. Each rule specifies a target group, condition, and priority. When the condition is met, the traffic is forwarded to the target group. You must define a default rule for each listener, and you can add rules that specify different target groups based on the content of the request (also known as content-based routing).

Each target group routes requests to one or more registered targets, such as EC2 instances, using the protocol and port number that you specify. You can register a target with multiple target groups. You can configure health checks on a per target group basis. Health checks are performed on all targets registered to a target group that is specified in a listener rule for your load balancer.

1. Edit **application-load-balancer.json** and update the values of **%publicSubnet1%**, **%publicSubnet2%**, and **%loadBalancerSecurityGroup%** from the CloudFormation stack outputs. Save the file. Create the application load balancer:

	```
	aws elbv2 create-load-balancer --cli-input-json file://application-load-balancer.json
	```
{{% notice note %}}
Please note the ARN of the application load balancer for use in an upcoming step.
{{% /notice %}}


1. Browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName) to check out your newly created load balancer.

1. 	Edit **target-group.json** and update the value of **%vpc%** from the CloudFormation stack outputs. Save the file. Create the target group:

	```
	aws elbv2 create-target-group --cli-input-json file://target-group.json
	```
{{% notice note %}}
Please note the ARN of the application target-group for use in an upcoming step.
{{% /notice %}}

1. Browse to the [Target Group console](https://console.aws.amazon.com/ec2/v2/home#TargetGroups:sort=targetGroupName) to check out your newly created target group.

1. Edit **listener.json** and update the values of **%LoadBalancerArn%** and **%TargetGroupArn%** from the previous steps. Save the file. Create the listener:

	```
	aws elbv2 create-listener --cli-input-json file://listener.json
	```

1. Browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName) to check out your newly created listener by selecting your load balancer and clicking on the **Listeners** tab.
