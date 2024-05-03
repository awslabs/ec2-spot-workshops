+++
title = "Deploy the AWS Elastic Load Balancer"
weight = 90
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Amazon EC2 Auto Scaling Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/0a0fe16c-8693-4d23-8679-4f1701dbd2b0/en-US)**.

{{% /notice %}}


{{%expand "Now, you are going to deploy a load balancer to distribute incoming traffic to your application across the EC2 Instances. To learn more about AWS Elastic Load Balancer click here" %}}
A load balancer serves as the single point of contact for clients. The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones. This increases the availability of your application. You add one or more listeners to your load balancer.

A listener checks for connection requests from clients, using the protocol and port that you configure, and forwards requests to one or more target groups, based on the rules that you define. Each rule specifies a target group, condition, and priority. When the condition is met, the traffic is forwarded to the target group. You must define a default rule for each listener, and you can add rules that specify different target groups based on the content of the request (also known as content-based routing).

Each target group routes requests to one or more registered targets, such as EC2 instances, using the protocol and port number that you specify. You can register a target with multiple target groups. You can configure health checks on a per target group basis. Health checks are performed on all targets registered to a target group that is specified in a listener rule for your load balancer. 

You can find further information on the [Application Load Balancer documentation(https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html).
{{% /expand %}}

1. Open **application-load-balancer.json** on the AWS Cloud9 editor and review the configuration. You will notice that some configurations have placeholder values: **`%publicSubnet1%`**, **`%publicSubnet2%`**, and **`%loadBalancerSecurityGroup%`**. 

1. Execute the following command to populate the configuration file with the **Outputs** of your CloudFormation stack. 
	```
	sed -i.bak -e "s#%publicSubnet1%#$publicSubnet1#g" -e "s#%publicSubnet2%#$publicSubnet2#g" -e "s#%loadBalancerSecurityGroup%#$loadBalancerSecurityGroup#g" application-load-balancer.json
	```   

1. Create the application load balancer:

	```
	aws elbv2 create-load-balancer --cli-input-json file://application-load-balancer.json
	```    

1. As on upcoming steps we will need the load balancer ARN, execute the following command to load it into an environment variable:
	```
	export LoadBalancerArn=$(aws elbv2 describe-load-balancers --name myEC2Workshop --query LoadBalancers[].LoadBalancerArn --output text)
	```    

1. Browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName) to check out your newly created load balancer.

1. 	Open the **target-group.json** and review the configuration. You will notice a placeholder value for the VPC configuration **%vpc%**. To populate it from the CloudFormation stack outputs, execute the following command:
	```
	sed -i.bak -e "s#%vpc%#$vpc#g" target-group.json
	```    

1. Create the target group:

	```
	aws elbv2 create-target-group --cli-input-json file://target-group.json
	```   

1. As you will need the Target Group ARN of the Target Group you have created on an upcoming step, execute the following command to load it on an environment variable:
	```
	export TargetGroupArn=$(aws elbv2 describe-target-groups --names myEC2Workshop --query TargetGroups[].TargetGroupArn --output text)
	```    
1. Open **modify-target-group.json** on the Cloud9 editor and review its configuration. Then, update the value of **%TargetGroupArn%** with the ARN with the following command:  
	```
	sed -i.bak -e "s#%TargetGroupArn%#$TargetGroupArn#g" modify-target-group.json
	```   

1. Modify the target group to set the deregistration_delay_timeout to 2 minutes to match the Spot interruption notification time (default is 5 minutes). You will learn how this setting is used when Spot instances are going to be interrupted on the *Spot resilience* section.

	```
	aws elbv2 modify-target-group-attributes --cli-input-json file://modify-target-group.json
	```   

1. Browse to the [Target Group console](https://console.aws.amazon.com/ec2/v2/home#TargetGroups:sort=targetGroupName) to check out your newly created target group.

1. Open **listener.json** and review the configuration. You will notice there are placeholder values for **%LoadBalancerArn%** and **%TargetGroupArn%**. To populate them with the Load Balancer and Target group created previously, execute the following command.
	```
	sed -i.bak -e "s#%LoadBalancerArn%#$LoadBalancerArn#g" -e "s#%TargetGroupArn%#$TargetGroupArn#g" listener.json
	```    

1. Create the listener with the following command:

	```
	aws elbv2 create-listener --cli-input-json file://listener.json
	```    

1. Browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName) to check out your newly created listener by selecting your load balancer and clicking on the **Listeners** tab.
