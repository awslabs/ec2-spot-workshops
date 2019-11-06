+++
title = "Deploy the AWS Elastic Load Balancer"
weight = 90
+++

A load balancer serves as the single point of contact for clients. The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones. This increases the availability of your application. You add one or more listeners to your load balancer.

A listener checks for connection requests from clients, using the protocol and port that you configure, and forwards requests to one or more target groups, based on the rules that you define. Each rule specifies a target group, condition, and priority. When the condition is met, the traffic is forwarded to the target group. You must define a default rule for each listener, and you can add rules that specify different target groups based on the content of the request (also known as content-based routing).

Each target group routes requests to one or more registered targets, such as EC2 instances, using the protocol and port number that you specify. You can register a target with multiple target groups. You can configure health checks on a per target group basis. Health checks are performed on all targets registered to a target group that is specified in a listener rule for your load balancer.

1. Execute the following command to edit **application-load-balancer.json** and update the values with the resources created by Cloudformation.

	```
	sed -i.bak -e "s#%publicSubnet1%#$public_subnet1#g" -e "s#%publicSubnet2%#$public_subnet2#g" -e "s#%loadBalancerSecurityGroup%#$lb_sg#g" application-load-balancer.json
	```

1. Take a look at the configuration file and then create the application load balancer:

	```
	aws elbv2 create-load-balancer --cli-input-json file://application-load-balancer.json
	```

1. Add the Load Balancer ARN to an environment variable as it will be used in an upcoming step:

	```
	alb_arn=$(aws elbv2 describe-load-balancers --names runningAmazonEC2WorkloadsAtScale --query LoadBalancers[].LoadBalancerArn --output text)
	```

1. Browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName) to check out your newly created load balancer.

1. 	Execute the following command to edit the **target-group.json** file and update it with the values of the resources created by the CloudFormation stack.

	```
	sed -i.bak -e "s#%vpc%#$vpc#g" target-group.json
	```

1.  Create the target group:

	```
	aws elbv2 create-target-group --cli-input-json file://target-group.json
	```

1. Add the Target Group ARN to an environment variable as it will be used in an upcoming step. 

	```
	tg_arn=$(aws elbv2 describe-target-groups --names runningAmazonEC2WorkloadsAtScale --query TargetGroups[].TargetGroupArn --output text)
	```

1. Edit **modify-target-group.json** and update the value of **%TargetGroupArn%** with the ARN. Save the file. 
	```
	sed -i.bak -e "s#%TargetGroupArn%#$tg_arn#g" modify-target-group.json
	```

1. Modify the target group to set the deregistration_delay_timeout to 2 minutes to match the interruption notification time (default is 5 minutes):

	```
	aws elbv2 modify-target-group-attributes --cli-input-json file://modify-target-group.json
	```

1. Browse to the [Target Group console](https://console.aws.amazon.com/ec2/v2/home#TargetGroups:sort=targetGroupName) to check out your newly created target group.

1. Edit **listener.json** and update the values of **%LoadBalancerArn%** and **%TargetGroupArn%** from the previous steps. 
	```
	sed -i.bak -e "s#%LoadBalancerArn%#$alb_arn#g" -e "s#%TargetGroupArn%#$tg_arn#g" listener.json
	```

1. Create the listener:

	```
	aws elbv2 create-listener --cli-input-json file://listener.json
	```

1. Browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName) to check out your newly created listener by selecting your load balancer and clicking on the **Listeners** tab.
