variable "vpc_id" {
  description = "VPC ID where EKS cluster will be created"
  type        = string
}

variable "private_subnet_1" {
  description = "Private subnet ID for Fargate profiles"
  type        = string
}

variable "private_subnet_2" {
  description = "Second private subnet ID for Fargate profiles"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "admin_users" {
  description = "List of IAM user ARNs to grant cluster admin access"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group access"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resource naming"
  type        = string
}

variable "is_dr_cluster" {
  description = "Whether this is a DR cluster (sets node group desired size to 0)"
  type        = bool
  default     = false
}

