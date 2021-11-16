---
title: "Building the APP"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

In this section we will be building the application that used to scale our cluster. First, let's download all the assets that we will need to build the application and image. Run the following command. We will use git to download the project and bring all the files needed to build our Monte Carlo microservice application:



```
# TODO: Change the URL and point to the final repo
cd ~environment
git clone https://github.com/ruecarlo/ec2-spot-workshops.git; git checkout CMP307-update
cd ec2-spot-workshops/workshops
```


```
$(aws ecr get-login --no-include-email)
export MONTE_CARLO_REGISTRY=$(aws ecr create-repository --repository-name monte-carlo-sim | jq --raw-output '.["repository"].repositoryUri')
export MONTE_CARLO_IMAGE=${MONTE_CARLO_REGISTRY}:latest
echo "export MONTE_CARLO_IMAGE=${MONTE_CARLO_REGISTRY}:latest" >> ~/.bash_profile
docker build -f Dockerfile --tag ${MONTE_CARLO_IMAGE} .
docker push ${MONTE_CARLO_IMAGE}
echo "${MONTE_CARLO_IMAGE} image ready for use"
```


