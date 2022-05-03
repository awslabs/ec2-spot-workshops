terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  cluster_name = "gitlab-spot-workshop"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.20.5"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = data.aws_subnets.eks_subnets.ids

  tags = {
    Project = "GitLabSpotWorkshop"
  }

  vpc_id = var.vpc_id

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 40
  }

  node_security_group_additional_rules = {
    webhook_ingress = {
      description                   = "Allow cluster to call webhooks"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    all_ingress_self = {
      description                   = "Allow nodes in the cluster to communicate with each other"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      self                          = true
    }
    all_egress_self = {
      description                   = "Allow nodes in the cluster to communicate with each other"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "egress"
      self                          = true
    }
  }

  eks_managed_node_groups = {
    spot_group = {
      desired_size = 3
      max_size     = 5
      min_size     = 1

      instance_types = ["m4.large", "m5.large", "m5a.large", "m6i.large"]
      capacity_type  = "SPOT"

      iam_role_additional_policies = [var.alb_policy]
    }
  }
}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
