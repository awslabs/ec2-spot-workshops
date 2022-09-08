---
title: "Install Helm CLI"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

## Kubernetes Helm

[Helm](https://helm.sh/) is a package manager for Kubernetes that packages multiple Kubernetes resources into a single logical deployment unit called **Chart**. 

Helm is a tool that streamlines installing and managing Kubernetes applications. Think of it like apt/yum/homebrew for Kubernetes. We will use Helm during the workshop to install other components out from the list of available charts.

Helm helps you to:

- Achieve a simple (one command) and repeatable deployment
- Manage application dependency, using specific versions of other application and services
- Manage multiple deployment configurations: test, staging, production and others
- Execute post/pre deployment jobs during application deployment
- Update/rollback and test application deployments


## Install the Helm CLI

Before we can get started configuring Helm, we'll need to first install the
command line tools that you will interact with. To do this, run the following:

```
export DESIRED_VERSION=v3.9.4
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

{{% notice note %}}
Note we are using a version relatively old of Helm and the same will apply to the load of the stable repo
This is temporary required to load kube-ops-view.
{{% /notice %}}


We can verify the version

```
helm version --short
```

Finally, let's configure Bash completion for the `helm` command:

```
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)
```
