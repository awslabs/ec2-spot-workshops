+++
title = "Using the Cloud9 Environment"
weight = 40
+++
AWS Cloud9 comes with a terminal that includes sudo privileges to the managed Amazon EC2 instance that is hosting your development environment and a preauthenticated AWS Command Line Interface. This makes it easy for you to quickly run commands and directly access AWS services.

An AWS Cloud9 environment was launched as a part of the CloudFormation stack (you may have noticed a second CloudFormation stack created by Cloud9).

{{% notice note %}}
You'll be using this Cloud9 environment to execute the steps in the workshop, and not the local command line on your computer.
{{% /notice %}}

1. Find the name of the AWS Cloud9 environment by checking the value of **cloud9Environment** in the CloudFormation stack outputs.

1. Sign in to the [AWS Cloud9 console](https://console.aws.amazon.com/cloud9/).

1. Find the Cloud9 environment in **Your environments**, and click **Open IDE**.
{{% notice note %}}
Please make sure you are using the Cloud9 environment created by the workshop CloudFormation stack!
{{% /notice %}}

1. Take a moment to get familiar with the Cloud9 environment. You can even take a quick tour of Cloud9 [here](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html#tutorial-tour-ide) if you'd like.