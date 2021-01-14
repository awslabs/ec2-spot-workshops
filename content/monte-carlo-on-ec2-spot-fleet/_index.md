---
title: "Run Monte Carlo Simulations on EC2 Spot Fleet"
date: 2019-01-24T09:05:54Z
weight: 90
pre: "<b>⁃ </b>"
---

The contents of this labs were originally created by [oak2272](https://github.com/oak2278), [James Siri](https://github.com/jamesiri) and [Anuj Sharma](https://github.com/anshrma), all credits go to them for this high quality workshop! This workshop was hosted in the following github repo: https://github.com/aws-samples/ec2-spot-montecarlo-workshop.


## Overview 
The goal of this workshop is not to become financial gurus. I doubt we'll be rich at the end, but hopefully we'll have learned different ways to build batch processing pipelines using AWS services and save up to 90% using [EC2 Spot Fleets](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet.html).

These labs are designed to be completed in sequence.  If you are reading this at a live AWS event, the workshop attendants will give you a high level run down of the labs.  Then it's up to you to follow the instructions below to complete the labs.  Don't worry if you're embarking on this journey in the comfort of your office or home, this site contains all the materials for you'll need to complete this workshop.
{{% children showhidden="false" %}}

{{% notice info %}}
The estimated cost for running this **2.5 hour** workshop will be less than **$5**.
{{% /notice %}}

## Introduction
Algorithmic trading, or algo-trading is the process of using algorithms for placing a stock trade based on a set of perceived market conditions. These algorithms are based on price, quantity or other mathematical model without the risk of human emotion influencing the buy or sell action. This workshop will walk your through some of the basic tools and concepts that algorithmic traders employ to build fully automated trading systems.

Monte Carlo Simulations involve repeated random sampling to model the probability of a complex problem that is difficult to predict using other methods due to the nature of the variables involved. We will use Monte Carlo Simulations to simulate and predict future stock movement by repeatedly sampling random stock values based on past results.

If you'd like to learn more: [Basics of Algorithmic Trading: Concepts and Examples](https://www.investopedia.com/articles/active-trading/101014/basics-algorithmic-trading-concepts-and-examples.asp)

### Conventions:  
Throughout this labs, we provide commands for you to run in the terminal.  These commands will look like this: 

<pre>
$ ssh -i PRIVATE_KEY.PEM ec2-user@EC2_PUBLIC_DNS_NAME
</pre>

The command starts after `$`.  Words that are ***UPPER_ITALIC_BOLD*** indicate a value that is unique to your environment.  For example, the ***PRIVATE\_KEY.PEM*** refers to the private key of an SSH key pair that you've created, and the ***EC2\_PUBLIC\_DNS\_NAME*** is a value that is specific to an EC2 instance launched in your account.  

