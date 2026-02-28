---
disableToc: true
hidden: true
---

## Gathering the CloudFormation outputs
You will create other AWS resources using the AWS CLI in your Visual Studio Code Server Terminal. 

Navigate to the Terminal and execute the following commands to retrieve the outputs of the CloudFormation stack:

```
for output in $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[].OutputKey' --output text)
do
    export $output=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query 'Stacks[].Outputs[?OutputKey==`'$output'`].OutputValue' --output text)
    eval "echo $output : \"\$$output\""
done
```

You can now start the workshop by heading to [**Risk pipeline**](/monte-carlo-with-batch/risk_pipeline.html).
