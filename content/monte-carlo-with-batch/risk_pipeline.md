---
title: "Risk pipeline"
date: 2021-09-06T08:51:33Z
weight: 30
---

<!-- ![Rendering pipeline](/images/rendering-with-batch/pipeline.png) -->

## Overview

The risk pipeline that we will implemented has two jobs: to calculate the PV of every entry in the portfolio, and to combine the results into a single output. 

We will be pricing a portfolio of [https://www.risk.net/definition/autocallable](autocallables), using QuantLib.


### Uploading the portfolio file

We will use an example portfolio file that is stored in Github. 
The portfolio file is in CSV format, and has three columns:

```
notional,strike,autoCallBarrier
```


Run the following command to download the file and upload it to S3:

```
wget "https://raw.githubusercontent.com/awslabs/ec2-spot-workshops/master/content/montecarlo-with-batch/montecarlo-with-batch.files/portfolio.csv"
aws s3api put-object --bucket "${BucketName}" --key "${MonteCarloFileName}" --body "${MonteCarloFileName}"
```


