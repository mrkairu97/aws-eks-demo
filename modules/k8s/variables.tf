variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "is_dr_cluster" {
  description = "Whether this is a DR cluster (sets resource quotas to 0)"
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for AWS Load Balancer Controller"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resource naming"
  type        = string
}

