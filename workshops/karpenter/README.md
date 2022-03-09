# Monte Carlo PI Simulation Service


A sample go micro service service used in the [ec2spotworkshop](https://ec2spotworkshop.com/). The Service runs a simple Monte Carlo simulation that is CPU intensive. This can be used to showcase how Auto Scaling of containerized CPU applications work.

The Dockerfile is a [multi-stage](https://docs.docker.com/develop/develop-images/multistage-build/) build that
compiles the Go application and then packages it in a minimal image that pulls from [scratch](https://hub.docker.com/_/scratch/).
The size of this Docker image is ~ 3.2 MiB.

To build the container use:

```
docker build --tag $REPOSITORY_URI:$TAG .
```
