## Ec2 Spot Workshops

Collection of workshops to demonstrate best practices in using Amazon EC2 Spot Instances. https://aws.amazon.com/ec2/spot/

Website for this workshops is available at https://ec2spotworkshops.com

## Building the Workshop site

The content of the workshops is built using [hugo](https://gohugo.io/). 

### Local Build
To build the content
 * clone this repository
 * [install hugo](https://gohugo.io/getting-started/installing/)
 * The project uses [hugo learn](https://github.com/matcornic/hugo-theme-learn/) template as a git submodule. To update the content, execute the following code
```bash
pushd themes/learn
git submodule init
git submodule update --checkout --recursive
popd
```
 * Run hugo to generate the site, and point your browser to http://localhost:1313
```bash
hugo serve -D
```

### Docker
For local development a docker image can be build and use.

#### Build

In order to build the image, just run a normal docker build command.

```
$ docker build -t myuser/ec2-spot-workshops:dev .
Sending build context to Docker daemon   84.4MB
Step 1/16 : FROM golang:alpine AS build
*snip*
Successfully tagged myuser/ec2-spot-workshops:dev
```

The image exposes the static website via port 1313.

```
$ docker service create --name ec2-spot --publish=1313:1313 myuser/ec2-spot-workshops:dev
```

#### Development

The image can also serve as a development enviornment using [docker-compose](https://docs.docker.com/compose/).
The following command will spin up a container exposing the website at [localhost:1313](http://localhost:1313) and mount `config.toml` and the directories `./content`, `./layouts` and `./static`, so that local changes will automatically be picked up by the development container.

```
$ docker-compose up -d  ## To see the logs just drop '-d'
Starting ec2-spot-workshops_hugo_1 ... done
```

## License

This library is licensed under the Amazon Software License.
