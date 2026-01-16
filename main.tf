terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# provider "aws" {
#   region = var.aws_region
# }

provider "aws" {
  region     = "ap-southeast-1"
  access_key = "<ACCESS_KEY>"
  secret_key = "<SECRET_KEY"
}

provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, "https://kubernetes.default.svc")
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), null)
  token                  = try(data.aws_eks_cluster_auth.cluster[0].token, null)
}

provider "helm" {
  kubernetes {
    host                   = try(module.eks.cluster_endpoint, "https://kubernetes.default.svc")
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), null)
    token                  = try(data.aws_eks_cluster_auth.cluster[0].token, null)
  }
}

data "aws_eks_cluster_auth" "cluster" {
  count = try(length(module.eks.cluster_name) > 0, false) ? 1 : 0
  name  = try(module.eks.cluster_name, "")
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr                = var.vpc_cidr
  vpc_region              = var.aws_region
  pub_1_subnet_cidr_block = var.pub_1_subnet_cidr_block
  pub_1_subnet_az         = var.pub_1_subnet_az
  pub_2_subnet_cidr_block = var.pub_2_subnet_cidr_block
  pub_2_subnet_az         = var.pub_2_subnet_az
  pri_1_subnet_cidr_block = var.pri_1_subnet_cidr_block
  pri_1_subnet_az         = var.pri_1_subnet_az
  pri_2_subnet_cidr_block = var.pri_2_subnet_cidr_block
  pri_2_subnet_az         = var.pri_2_subnet_az
}

module "eks" {
  source = "./modules/eks"
  
  vpc_id           = module.vpc.vpc_id
  vpc_cidr         = var.vpc_cidr
  private_subnet_1 = module.vpc.aws_subnet_private_1
  private_subnet_2 = module.vpc.aws_subnet_private_2
  public_subnets   = module.vpc.aws_public_subnets
  admin_users      = var.admin_users
  aws_region       = var.aws_region
  is_dr_cluster    = var.is_dr_cluster
  
  depends_on = [module.vpc]
}

module "k8s" {
  source = "./modules/k8s"
  
  cluster_name         = module.eks.cluster_name
  is_dr_cluster        = var.is_dr_cluster
  oidc_provider_arn    = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  vpc_id               = module.vpc.vpc_id
  aws_region           = var.aws_region
  
  depends_on = [module.eks]
}