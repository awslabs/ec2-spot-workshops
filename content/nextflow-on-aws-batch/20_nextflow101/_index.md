---
title: "Nextflow 101"
chapter: true
weight: 20
---

To get started with Nextflow we are going to run a little example workflow locally.

We will use the example Genomics workflow of the nextflow-tutorial. You should already be in the directory after we setup the workshop in the previous session.

```
$ pwd
/home/ec2-user/environment/nextflow-tutorial
```

## Nextflow Config

As we are using Docker to execute the pipelines we will predefine the execution engine.

```
cat << \EOF > $HOME/.nextflow/config
docker.enabled = true
EOF
```
