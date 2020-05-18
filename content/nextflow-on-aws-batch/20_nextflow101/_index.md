---
title: "Nextflow 101"
chapter: true
weight: 20
---

To get started with Nextflow we are going to run a little example workflow locally.

## Clone nextflow-tutorial

We will use the example Genomics workflow of the nextflow-tutorial. 

```bash
git clone https://github.com/seqeralabs/nextflow-tutorial.git 
cd nextflow-tutorial
```

## Nextflow Config

As we are using Docker to execute the pipelines we will predefine the execution engine.

```bash
cat << \EOF > $HOME/.nextflow/config
docker.enabled = true
EOF
```
