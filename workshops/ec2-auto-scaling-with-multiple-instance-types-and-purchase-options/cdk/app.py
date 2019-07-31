#!/usr/bin/env python3

from aws_cdk import (
  aws_ec2 as ec2,
  aws_cloud9 as cloud9,
  core
)

class runningAmazonEC2WorkloadsAtScaleStack(core.Stack):
  def __init__(self, app: core.App, id: str) -> None:
    super().__init__(app, id)

    vpc = ec2.Vpc(
      self,
      "VPC",
      max_azs = 2
    )

    cloud9Environment = cloud9.CfnEnvironmentEC2(
      self,
      "CLOUD9ENVIRONMENT",
      instance_type = "t2.micro",
      automatic_stop_time_minutes = 60,
      subnet_id = vpc.public_subnets[0].subnet_id
      )

    instanceSecurityGroup = ec2.SecurityGroup(
      self,
      "INSTANCESECURITYGROUP",
      vpc = vpc
      )

    loadBalancerSecurityGroup = ec2.SecurityGroup(
      self,
      "LOADBALANCERSECURITYGROUP",
      vpc = vpc
      )

    connection = ec2.Connections(
      default_port = ec2.Port.tcp(80),
      security_groups = [
        instanceSecurityGroup,
        loadBalancerSecurityGroup
        ]
      )

    connection.allow_default_port_internally()
    connection.allow_default_port_from_any_ipv4()
    
    core.CfnOutput(
      self,
      "vpc",
      value = vpc.vpc_id
      )

    core.CfnOutput(
      self,
      "publicSubnet1",
      value = vpc.public_subnets[0].subnet_id
      )

    core.CfnOutput(
      self,
      "publicSubnet2",
      value = vpc.public_subnets[1].subnet_id
      )

    core.CfnOutput(
      self,
      "cloud9Environment",
      value = cloud9Environment.attr_name
      )

    core.CfnOutput(
      self,
      "instanceSecurityGroup",
      value = instanceSecurityGroup.security_group_name
      )

    core.CfnOutput(
      self,
      "loadBalancerSecurityGroup",
      value = loadBalancerSecurityGroup.security_group_name
      )






#class LoadBalancerStack(core.Stack):
#  def __init__(self, app: core.App, id: str) -> None:
#    super().__init__(app, id)

#    vpc = ec2.Vpc(self, "VPC")

#    asg = autoscaling.AutoScalingGroup(
#      self,
#      "ASG",
#      vpc=vpc,
#      instance_type=ec2.InstanceType.of(
#        ec2.InstanceClass.BURSTABLE2, ec2.InstanceSize.MICRO
#        ),
#      machine_image=ec2.AmazonLinuxImage(),
#      )

#    lb = elbv2.ApplicationLoadBalancer(
#      self, "LB",
#      vpc=vpc,
#      internet_facing=True)

#    listener = lb.add_listener("Listener", port=80)
#    listener.add_targets("Target", port=80, targets=[asg])
#    listener.connections.allow_default_port_from_any_ipv4("Open to the world")

#    asg.scale_on_request_count("AModestLoad", target_requests_per_second=1)


app = core.App()
runningAmazonEC2WorkloadsAtScaleStack(app, "runningAmazonEC2WorkloadsAtScale")
app.synth()