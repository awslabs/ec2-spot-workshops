---
disableToc: true
hidden: true
---

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