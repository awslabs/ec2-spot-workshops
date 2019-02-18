+++
title = "EC2 Spot Fleet web app"
weight = 30
+++

### Overview

[Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/) are spare compute 
capacity in the AWS cloud available to you at steep discounts compared to 
On-Demand prices. EC2 Spot enables you to optimize your costs on the AWS cloud 
and scale your application's throughput up to 10X for the same budget. By simply
selecting Spot when launching EC2 instances, you can save up-to 90% on On-Demand
prices.

This workshop is designed to get you familiar with EC2 Spot Instances by 
learning how to deploy a simple web app on an EC2 Spot Fleet behind an Elastic 
Load Balanacing Application Load Balancer and enable automatic scaling to allow 
it to handle peak demand, as well as handle Spot Instance interruptions.
