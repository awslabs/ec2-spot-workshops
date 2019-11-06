---
title: "Prerequisites"
chapter: true
weight: 10
---

We will be leveraging Amazon SageMaker Hosted Jupyter Notebook Instances to run through example notebooks that demonstrate using Amazon SageMaker Managed Spot Training with various frameworks and models. When we create our Notebook Instance, we will apply permissions to our instance via an Execution Role which will allow the instance to perform actions within our account (primarily, creating and deleting S3 buckets). We will also clone a public example repository that contains our sample notebooks to our Notebook Instance.

All of these steps have been automated for you using the CloudFormation template you will deploy in the following steps. It's important to understand that this template is for demonstration purposes only, and may not apply all of the best practices for least priveldge you would normally apply in a real-world environment