+++
title = "Browse to the web app"
weight = 120
+++

{{% notice warning %}}
![STOP](../images/stop_small.png)
Please note: This workshop version is now deprecated, and an updated version has been moved to AWS Workshop Studio. This workshop remains here for reference to those who have used this workshop before for reference only. Link to updated workshop is here: **[Amazon EC2 Auto Scaling Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/0a0fe16c-8693-4d23-8679-4f1701dbd2b0/en-US)**.

{{% /notice %}}




1. Once one or more instances are marked with a status of healthy, browse to the [Load Balancer console](https://console.aws.amazon.com/ec2/v2/home#LoadBalancers:sort=loadBalancerName), select your load balancer, and copy the **DNS name** (URL) of your load balancer (e.g. http://myEC2Workshop-115077449.us-east-1.elb.amazonaws.com).

1. Open your web browser and browse to the **DNS name** (URL).

1. Click refresh a few times to see your requests being routed to the different instances deployed behind your load balancer.
