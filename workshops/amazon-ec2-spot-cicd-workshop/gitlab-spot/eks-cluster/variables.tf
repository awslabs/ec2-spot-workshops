variable "alb_policy" {
  type        = string
  description = "IAM policy for AWS Load Balancer Controller"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the cluster"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the cluster"
}