+++
title = "Launching an EC2 Spot Instance via the RunInstances API"
weight = 80
+++

## Launching an EC2 Spot Instance via the RunInstances API

This API allows you to launch one or more instances, using a Launch Template that you have previously configured. Typically you would use the RunInstances API to launch one or more instances of the same type.

{{%notice note%}}
Even though RunInstances API allows you to launch Spot instances, it doesn't allow you to specify neither a replacement strategy nor an allocation strategy. Remember that by specifying multiple Spot capacity pools we can apply instance diversification and when working with the `capacity optimized` allocation strategy, Amazon EC2 will automatically launch Spot instances from the optimal capacity pools among the ones that have been specified.
{{% /notice %}}

This is why it is recommended to use EC2 Fleet as a drop-in replacement for RunInstances API.

## Launching an EC2 Fleet as a replacement for RunInstances API
