---
title: "Install Tools"
chapter: false
weight: 50
---

## Install Java and Nextflow

The nextflow command-line tool uses the JVM. Thus, we will install AWS open-source variant [Amazon Corretto](https://docs.aws.amazon.com/corretto).

{{% notice info %}}
Amazon Corretto is a no-cost, multiplatform, production-ready distribution of the Open Java Development Kit (OpenJDK). Corretto comes with long-term support that will include performance enhancements and security fixes. Amazon runs Corretto internally on thousands of production services and Corretto is certified as compatible with the Java SE standard. With Corretto, you can develop and run Java applications on popular operating systems, including Linux, Windows, and macOS.
{{% /notice %}}

### Amazon Corretto

To [install Corretto](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/generic-linux-install.html), we are adding the repository first.

```
sudo rpm --import https://yum.corretto.aws/corretto.key 
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
```

Afterwards install java-11 and check the installation.

```
sudo yum install -y java-11-amazon-corretto-devel
java --version
```


### Graphviz

Nextflow is able to render graphs for which it needs `graphviz` to be installed. `jq` will help us deal with JSON files.

```
sudo yum install -y graphviz jq
```

### AWS Region

Even though we are depending on an IAM Role and not local permissions some tools  depend on having the `AWS_REGION` defined as environment variable - let's add it to our login shell configuration.

```
export AWS_REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
echo "AWS_REGION=${AWS_REGION}" |tee -a ~/.bashrc
```