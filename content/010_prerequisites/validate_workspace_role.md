---
disableToc: true
hidden: true
---

### Validate the IAM role {#validate_iam}

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

{{% notice note %}}
**Select the tab** and validate the assumed role…
{{% /notice %}}

{{< tabs name="Region" >}}
    {{< tab name="...AT AN AWS EVENT" include="at_an_aws_validaterole.md" />}}
    {{< tab name="...ON YOUR OWN" include="on_your_own_validaterole.md" />}}

{{< /tabs >}}


