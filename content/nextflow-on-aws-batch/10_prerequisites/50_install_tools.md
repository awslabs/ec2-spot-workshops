---
title: "Install Tools"
chapter: false
weight: 50
---

## Clone nextflow-tutorial

```
git clone https://github.com/seqeralabs/nextflow-tutorial.git 
cd nextflow-tutorial
```

## Install Java and Nextflow

### Amazon Corretto

As a JVM we install [Amazon Corretto](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/generic-linux-install.html).
Adding the repository first.

```
sudo rpm --import https://yum.corretto.aws/corretto.key 
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
```

Afterwards install java-11 and check the installation.

```
sudo yum install -y java-11-amazon-corretto-devel
java --version
```

### Nextflow

Installing Nextflow using the online installer.

```
curl https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```

The above snippet creates the nextflow launcher in the current directory.

### Graphviz

To create svg we need to install graphviz.

```
sudo yum install -y graphviz jq
```

### AWS Region

```
export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
echo "AWS_REGION=${AWS_REGION}" |tee -a ~/.bashrc
```