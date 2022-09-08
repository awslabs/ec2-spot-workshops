+++
title = "Jenkins on ECS"
weight = 200
+++
You’ve now got a scalable solution using nothing but Spot instances for your CICD systems, your build agents and your test environments – however, you still have some inefficiencies with this setup:

* Your Jenkins master utilizes a relatively low percentage of the CPU resources on the instance types that Jenkins is running on; and
* You still have at least one Jenkins build agent running at all times;

These inefficiencies can be addressed by moving your solution to a container environment that continues to utilize Spot instances. This lab will see you configure the ECS cluster resources that were created by the initial CloudFormation template and migrate your Jenkins master and agents to this cluster.