ec2spotworkshops
================

**ec2spotworkshops** is a collection of workshops that illustrate some of the best practices in using [Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/purchasing-options/spot-instances/).

The content of the workshops is built using [hugo](https://gohugo.io/). 

To build the content
 * clone this repository
 * [install hugo](https://gohugo.io/getting-started/installing/)
 * The project uses [hugo learn](https://github.com/matcornic/hugo-theme-learn/) template as a git submodule. To update the content, execute the following code
```
pushd themes/learn
git submodule init
git submodule update --checkout --recursive
popd
```
 * Run hugo to generate the site, and point your browser to http://localhost:1313
```
hugo serve -D
```

Issues
======

Please address any issues or feedback via [issues](https://github.com/awslabs/ec2-spot-labs/issues).
