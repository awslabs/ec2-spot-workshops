---
disableToc: true
hidden: true
---

{{% notice info %}}
Please note: this EKS and Karpenter workshop version is now deprecated since the launch of Karpenter v1beta, and has been updated to a new home on AWS Workshop Studio here: **[Karpenter: Amazon EKS Best Practice and Cloud Cost Optimization](https://catalog.us-east-1.prod.workshops.aws/workshops/f6b4587e-b8a5-4a43-be87-26bd85a70aba)**.

This workshop remains here for reference to those who have used this workshop before, or those who want to reference this workshop for running Karpenter on version v1alpha5.
{{% /notice %}}

The output assumed-role name should contain:
```
WSParticipantRole
```

#### VALID

If the _Arn_ contains the role name from above and an Instance ID, you may proceed.

```output
{
    "Account": "123456789012", 
    "UserId": "AROA1SAMPLEAWSIAMROLE:Participant", 
    "Arn": "arn:aws:sts::123456789012:assumed-role/WSParticipantRole/Participant"
}
```