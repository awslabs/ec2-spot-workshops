---
title: "Resize Cloud9 Instance Root Volume"
chapter: false
weight: 30
---

## Resize Cloud9 EBS

The default 10GB is may not be enough to build the application docker images.
Thus, let us resize the EBS volume used by the Cloud9 instance.

To change the EBS volume, please do

   1. Select the Cloud9 instance in the EC2 console [deep link to get there](https://console.aws.amazon.com/ec2/v2/home?#Instances:search=aws-cloud9-EcsSpotWorkshop)
   2. Click the **Storage :** Section 
   3. Click on the Volume ID. That will take you to the EBS Volume page details.

![resize_ebs_0](/images/ecs-spot-capacity-providers/cloud9_instance.png)

Modify the EBS volume.

![resize_ebs_1](/images/ecs-spot-capacity-providers/resize_ebs_1.png)

Choose a new volume size (e.g. 100GB).

![resize_ebs_2](/images/ecs-spot-capacity-providers/resize_ebs_2.png)

{{% notice info %}}
Please make sure changes went through, and the EBS volume now reflects the new size of the volume.
{{% /notice %}}

## Resize FS

Changing the block device does not increase the size of the file system.

To do so head back to the Cloud9 instance and use the following commands.

```bash
sudo growpart /dev/xvda 1
sudo resize2fs $(df -h |awk '/^\/dev/{print $1}')

```

The root file-system should now show 99GB.

```bash
df --human-readable

```

```bash
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        483M   60K  483M   1% /dev
tmpfs           493M     0  493M   0% /dev/shm
/dev/xvda1       99G  8.0G   91G   9% /
```
