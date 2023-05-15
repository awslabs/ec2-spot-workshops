---
title: "Risk pipeline"
date: 2021-09-06T08:51:33Z
weight: 30
---

## Overview

The risk pipeline that we will implemented has two jobs: to calculate the PV of every entry in the portfolio, and to combine the results into a single output. 

We will be pricing a portfolio of [autocallables](https://www.risk.net/definition/autocallable), using QuantLib.


### Uploading the portfolio file

We will use an example portfolio file, formatted in JSON, that is stored in Github. 

Run the following command to download the file and upload it to S3:

```
wget "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/monte-carlo-with-batch/monte-carlo-with-batch.files/portfolio.json"
aws s3api put-object --bucket "${BucketName}" --key "${MonteCarloFileName}" --body "${MonteCarloFileName}"
```


