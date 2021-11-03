---
title: "...At An AWS EVENT - Set Stack Name"
chapter: false
disableToc: true
hidden: true
---

### Get the stack name that was deployed already

```
export STACK_NAME=$(aws cloudformation list-stacks | jq -r '.StackSummaries[] | select(.StackName|test("mod.")) | .StackName')
echo "STACK_NAME=$STACK_NAME"
```

The output should look something like below.

```
STACK_NAME=mod-9feefdd1672c4eac
```