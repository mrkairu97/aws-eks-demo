# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "eks-cluster-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
    "elbv2.k8s.aws/cluster" = "demo-eks-cluster"
  }
}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role-${var.aws_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# KMS Key for EKS secrets encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EKS Service"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow Identity Center Admin"
        Effect = "Allow"
        Principal = {
          AWS = var.admin_users
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_kms_alias" "eks" {
  name          = "alias/eks-demo-cluster"
  target_key_id = aws_kms_key.eks.key_id
}

# EKS Cluster
resource "aws_eks_cluster" "demo_cluster" {
  name     = "demo-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.34"

  vpc_config {
    subnet_ids              = concat(var.public_subnets, [var.private_subnet_1, var.private_subnet_2])
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Grant cluster admin access to additional users
resource "aws_eks_access_entry" "admin_users" {
  count         = length(var.admin_users)
  cluster_name  = aws_eks_cluster.demo_cluster.name
  principal_arn = var.admin_users[count.index]
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_users" {
  count         = length(var.admin_users)
  cluster_name  = aws_eks_cluster.demo_cluster.name
  principal_arn = var.admin_users[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
  depends_on = [aws_eks_access_entry.admin_users]
}

# EKS Node Group IAM Role
resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-role-${var.aws_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_group_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node_group_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

# Security Group for Worker Nodes
resource "aws_security_group" "node_group_sg" {
  name_prefix = "eks-node-group-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
    "elbv2.k8s.aws/cluster" = "demo-eks-cluster"
  }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.demo_cluster.name
  node_group_name = "main-node-group"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = [var.private_subnet_1, var.private_subnet_2]
  instance_types  = ["t3.medium"]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = var.is_dr_cluster ? 0 : 2
    max_size     = 4
    min_size     = var.is_dr_cluster ? 0 : 1
  }

  update_config {
    max_unavailable = var.is_dr_cluster ? 2 : 1
  }



  depends_on = [
    aws_iam_role_policy_attachment.node_group_worker_node_policy,
    aws_iam_role_policy_attachment.node_group_cni_policy,
    aws_iam_role_policy_attachment.node_group_registry_policy,
  ]
}

# OIDC Provider for EKS
data "tls_certificate" "eks" {
  url = aws_eks_cluster.demo_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.demo_cluster.identity[0].oidc[0].issuer
}



# Tag the EKS-managed cluster security group for Load Balancer Controller
resource "aws_ec2_tag" "cluster_sg_lbc_tag" {
  resource_id = aws_eks_cluster.demo_cluster.vpc_config[0].cluster_security_group_id
  key         = "elbv2.k8s.aws/cluster"
  value       = aws_eks_cluster.demo_cluster.name
}

# EKS Add-ons
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.demo_cluster.name
  addon_name   = "kube-proxy"
  
  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.demo_cluster.name
  addon_name   = "vpc-cni"
  
  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.demo_cluster.name
  addon_name   = "coredns"
  
  depends_on = [aws_eks_node_group.main]
}