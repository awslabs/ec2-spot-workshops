+++
title = "Service Discovery"
chapter = true
weight = 40
+++


Service Discovery
---

Because containers are immutable by nature, they can churn regularly and be replaced with newer versions of the service. This means that there is a need to register the new and deregister the old/unhealthy services. To do this on your own is challenging, hence the need for service discovery.

AWS Cloud Map is a cloud resource discovery service. With Cloud Map, you can define custom names for your application resources, and it maintains the updated location of these dynamically changing resources. This increases your application availability because your web service always discovers the most up-to-date locations of its resources.

Cloud Map natively integrates with ECS, and as we build services in the workshop, will see this firsthand. For more information on service discovery with ECS, please see [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html).

![Service Discovery](/images/ecs-spot-capacity-providers/cloudmapproduct.png)  