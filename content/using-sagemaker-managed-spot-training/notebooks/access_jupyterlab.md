---
title: "Accessing JupyterLab"
chapter: false
weight: 20
---

Now that you've deployed the CloudFormation template, you will be able to access an Amazon SageMaker Notebook Instance. An Amazon SageMaker Notebook Instance is a managed EC2 instance that comes pre-installed common tools used by data scientists to develop and execute data science experiments from Python Notebooks. 

1. Browse to the Amazon SageMaker Console and locate the Amazon SageMaker Notebook Instance that was created by the CloudFormation template: https://console.aws.amazon.com/sagemaker/home?/notebook-instances/notebook-instances ![SageMaker Notebook Instance](/images/using-sagemaker-managed-spot-training/jupyter-1.png)

{{% notice note %}}
Make sure you are in AWS Region designated by the facilitators of the workshop or wherever you deployed the CloudFormation stack you created in the previous step.
{{% /notice %}} 

2. Click the link labeled "***Open JupyterLab***" located to the right of your Notebook Instance.

3. JupyterLab will now be opened in a separate window, and you should see a list of directories cloned cloned from the public GitHub Repo located at: [EC2 Spot Labs](https://github.com/awslabs/ec2-spot-labs) ![Jupyter Lab](/images/using-sagemaker-managed-spot-training/jupyter-2.png)