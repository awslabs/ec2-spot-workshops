---
title: "CLI Setup"
chapter: true
weight: 10
---

### Setup AWS CLI and other tools

Make sure the latest version of the AWS CLI is installed by running:

```
sudo pip install -U awscli  
```
Install dependencies for use in the workshop by running:

```
sudo yum -y install jq gettext
```

### Clone the GitHub repo

In order to execute the steps in the workshop, you'll need to clone the workshop GitHub repo.

In the Cloud9 IDE terminal, run the following command:

(remove before prod0
```
git clone https://github.com/jalawala/ec2-spot-workshops.git 
```
```
git clone https://github.com/awslabs/ec2-spot-workshops.git
```
Change into the workshop directory:

```
cd ec2-spot-workshops/workshops/ecs-spot-capacity-providers
```

Feel free to browse around. You can also browse the directory structure in the **Environment** tab on the left, and even edit files directly there by double clicking on them.

