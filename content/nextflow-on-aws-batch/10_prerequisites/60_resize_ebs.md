---
title: "Resize Root Volume"
chapter: false
weight: 60
---

## Resize EBS

The default 10GB is quite small when using a docker file for Genomics.
Thus, let us resize the EBS volume used by the Cloud9 instance.

To change the EBS volume, please do

   1. Select the Cloud9 instance in the EC2 console
   2. Click the root-device link
   3. click on the EBS-ID in the box appearing

![](/images/nextflow-on-aws-batch/prerequisites/resize_ebs_0.png)

Afterward modify the EBS volume.

![](/images/nextflow-on-aws-batch/prerequisites/resize_ebs_1.png)

And chose a new volume size (e.g. 100GB)

![](/images/nextflow-on-aws-batch/prerequisites/resize_ebs_2.png)

## Resize FS

Changing the block device does not increase the size of the file system.

To do so head back to the Cloud9 instance and use the following commands.

```
sudo growpart /dev/xvda 1
sudo resize2fs $(df -h |awk '/^\/dev/{print $1}')
```

The root file-system should now show 99GB.

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        483M   60K  483M   1% /dev
tmpfs           493M     0  493M   0% /dev/shm
/dev/xvda1       99G  8.0G   91G   9% /
```