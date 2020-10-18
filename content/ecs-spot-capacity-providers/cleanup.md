---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

{{% notice note %}}
If you're running in an account that was created for you as part of an AWS event, there's no need to go through the cleanup stage - the account will be closed automatically.\
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}

{{% notice tip %}}
Before you clean up the resources and complete the workshop, you may want to review the complete some of the optional exercises in previous section of this workshop!
{{% /notice %}}


1. Running this workshop as self-paced or using your own/organization AWS account, follow instructions as below.

	Please ensure you delete all the resources created in the workshop to avoid costs.

    * Delete all the Services in the ECS Cluster
    * Select all the Capacity Providers and click on *Deactivate*   
    * Delete both Auto scaling groups for OD and EC2 Instances.
    * Delete the ECS Cluster
    * Delete any IAM roles and Cloud 9 environment at the end of the workshop.

