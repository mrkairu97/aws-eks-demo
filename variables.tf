variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "pub_1_subnet_cidr_block" {
  description = "Public subnet 1 CIDR block"
  type        = string
  default     = "172.16.63.0/24"
}

variable "pub_1_subnet_az" {
  description = "Public subnet 1 availability zone"
  type        = string
  default     = "ap-southeast-1a"
}

variable "pub_2_subnet_cidr_block" {
  description = "Public subnet 2 CIDR block"
  type        = string
  default     = "172.16.191.0/24"
}

variable "pub_2_subnet_az" {
  description = "Public subnet 2 availability zone"
  type        = string
  default     = "ap-southeast-1b"
}

variable "pri_1_subnet_cidr_block" {
  description = "Private subnet 1 CIDR block"
  type        = string
  default     = "172.16.127.0/24"
}

variable "pri_1_subnet_az" {
  description = "Private subnet 1 availability zone"
  type        = string
  default     = "ap-southeast-1a"
}

variable "pri_2_subnet_cidr_block" {
  description = "Private subnet 2 CIDR block"
  type        = string
  default     = "172.16.255.0/24"
}

variable "pri_2_subnet_az" {
  description = "Private subnet 2 availability zone"
  type        = string
  default     = "ap-southeast-1b"
}

variable "admin_users" {
  description = "List of IAM user ARNs to grant cluster admin access"
  type        = list(string)
  default = [
    "arn:aws:iam::430515646008:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_d7b4bf0ecd9de6dc",
    "arn:aws:iam::430515646008:role/GitHubRunner"
  ]
}

variable "is_dr_cluster" {
  description = "Whether this is a DR cluster (sets resource quotas to 0)"
  type        = bool
  default     = false
}

