---
disableToc: true
hidden: true
---

{{% insert-md-from-file file="using_ec2_spot_instances_with_eks/010_prerequisites/update_workspace_settings.md" %}}

We should configure our aws cli with our current region as default:
```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

echo "export ACCOUNT_ID=${ACCOUNT_ID}" >> ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
```

### Validate the IAM role {#validate_iam}

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```
aws sts get-caller-identity

```

{{% notice note %}}
**Select the tab** and validate the assumed role…
{{% /notice %}}


{{< tabs name="Region" >}}
    {{< tab name="...ON YOUR OWN" include="on_your_own_validaterole.md" />}}
    {{< tab name="...AT AN AWS EVENT" include="at_an_aws_validaterole.md" />}}
{{< /tabs >}}
