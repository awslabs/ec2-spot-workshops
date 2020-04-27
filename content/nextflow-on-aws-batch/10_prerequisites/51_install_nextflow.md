---
title: "Install Nextflow"
chapter: false
weight: 51
---

## Nextflow

This workshop will use Nextflow as a workflow engine. It provides a simple and fluent DSL and is portable by using containers for workflow execution.
Furthermore it allows the use of a lot of traditional and modern execution engines; one of which is AWS Batch which we will use today.

### Install Nextflow

Installing Nextflow using the online installer.
The snippet creates the nextflow launcher in the current directory. So we just move the command to `/usr/local/bin` to have it ready to be executed anywhere.

```bash
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```
