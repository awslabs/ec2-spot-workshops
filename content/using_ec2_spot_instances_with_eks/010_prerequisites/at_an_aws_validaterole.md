---
disableToc: true
hidden: true
---

The output assumed-role name should contain:
```
TeamRole
```

#### VALID

If the _Arn_ contains the role name from above and an Instance ID, you may proceed.

```output
{
    "Account": "123456789012", 
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef", 
    "Arn": "arn:aws:sts::216876048363:assumed-role/TeamRole/i-0dd09eac19be01448"
}
```