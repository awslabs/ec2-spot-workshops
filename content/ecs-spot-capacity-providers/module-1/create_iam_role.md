---
title: "Create IAM roles for your Workspace"
chapter: true
weight: 15
---

### Create IAM roles for your Workspace


In order to work with ECS from our workstation, we will need the appropriate permissions for our developer workstation instance.

1. Go to the [IAM Console](https://console.aws.amazon.com/iam/home), **Roles** &gt; **Create New Role &gt; AWS Service &gt; EC2.** We will later assign this role to our workstation instance.
1. Click **Next: Permissions.** Confirm that **AdministratorAccess** is checked (TBD: to restrict needed permissions only)
1. Click **Next:Tags** Take the defaults, and click **Next: Review** to review.
1. Enter **ecsspotworkshop-admin** for the Name, and click **Create role**.

<div align="left">
Use the same process to create another new role so that EC2 instances in the ECS cluster have appropriate permissions to access the container registry, auto-scale, etc. We will later assign this role to the EC2 instances in our ECS cluster.
</div>

In the Create Role screen, enter below two roles in the text field and select the two policies.

```
AmazonEC2ContainerServiceforEC2Role AmazonEC2ContainerServiceAutoscaleRole
``` 

In the Review screen, enter **ecslabinstanceprofile** for the Role name and click **Create Role**.

**Note** : By default, ECS wizard creates ecsInstanceRole for you to use. However, it's a best practice to create a specific role for your use so that we can add more policies in the future when we need to.  

Use the same process to create another new role so that EC2 Auto scaling will have necessary permissions to launch/terminate resources on your behalf.  


Under the section  **Or select a service to view its use cases**, select 'EC2 Auto scaling' for the service which will use this role.  

Under the section  **Select your use case**, select 'EC2 Auto scaling' and click on Next: Permissions  
We will later use this role when we create auto scaling groups. 


In the Create Role screen, enter[**AutoScalingServiceRolePolicy**](https://console.aws.amazon.com/iam/home?region=us-east-1#/policies/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2Faws-service-role%2FAutoScalingServiceRolePolicy)

In the optional suffix, enter ec2 as shown below so that role become [**AWSServiceRoleForAutoScaling_ec2**](https://console.aws.amazon.com/iam/home?region=us-east-1#/roles/AWSServiceRoleForAutoScaling_ec2)

