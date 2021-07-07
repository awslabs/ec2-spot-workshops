+++
title = "Launching an EC2 Spot Instance via the RunInstances API"
weight = 60
+++

## Launching an EC2 Spot Instance via the RunInstances API

To launch an EC2 Spot Instance from a launch template using the command
line, use the run-instances AWS CLI command and specify the
*--launch-template* parameter as well as the *--instance-market-options*
parameter.

```bash
$ aws ec2 run-instances --launch-template LaunchTemplateName=TemplateForSpot,Version=1 --instance-market-options MarketType=spot
```

That is all there is to it\! You can see your Spot Instance request in
the Spot console at <https://console.aws.amazon.com/ec2spot>.

![RunInstances API](/images/launching_ec2_spot_instances/runinstances_api_image_1.png)
