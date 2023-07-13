---
title: "Set up the environment"
date: 2021-11-07T11:05:19-07:00
weight: 10
draft: false
---

Before we install Karpenter, there are a few things that we will need to prepare in our environment for it to work as expected.

## Create the EC2 Spot Linked Role

Finally, we will create the spot [EC2 Spot Linked role](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html#service-linked-roles-spot-instance-requests).

{{% notice warning %}}
This step is only necessary if this is the first time you’re using EC2 Spot in this account. If the role has already been successfully created, you will see: *An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix.* . Just ignore the error and proceed with the rest of the workshop.
{{% /notice %}}

```
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```
