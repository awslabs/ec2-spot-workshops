---
title: "⁃ ECS Deep Learning Workshop using EC2 Spot"
date: 2019-02-06T07:14:54Z
weight: 40 
---
<!-- FIXME: 
This workshop is still refering to the original github repo at
https://github.com/aws-samples/ecs-deep-learning-workshop

All the references should be pointing to the new repository where
we are storing the EC2 Spot workshops at 
https://github.com/awslabs/ec2-spot-workshops
 -->

## Overview

[Deep Learning (DL)](https://en.wikipedia.org/wiki/Deep_learning) is an implementation of [Machine Learning (ML)](https://en.wikipedia.org/wiki/Machine_learning) that uses neural networks to solve difficult problems such as image recognition, sentiment analysis and recommendations. Neural networks simulate the functions of the brain where artificial neurons work in concert to detect patterns in data. This allows deep learning algorithms to classify, predict and recommend with an increasing degree of accuracy as more data is trained in the network. DL algorithms generally operate with a high degree of parallelism and are computationally intense. As a result, emerging deep learning libraries, frameworks, and platforms allow for data and model parallelization and can leverage advancements in GPU technology for improved performance.
This workshop will walk you through the deployment of a deep learning library called MXNet on AWS using Docker containers. Containers provide isolation, portability and repeatability, so your developers can easily spin up an environment and start building without the heavy lifting.

The goal is not to go deep on the learning (no pun intended) aspects, but to illustrate how easy it is to deploy your deep learning environment on AWS and use the same tools to scale your resources as needed.

The original source for this workshop is https://github.com/aws-samples/ecs-deep-learning-workshop 

