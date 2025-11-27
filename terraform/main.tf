terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-app-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# -----------------------------------------------------------------------------
# Providers
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# -----------------------------------------------------------------------------
# Networking (VPC)
# -----------------------------------------------------------------------------

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(var.vpc_cidr, 4, k + 4)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 5
      desired_size = 4

      # UPDATED: Changed to t3.small to satisfy Free Tier requirement
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_users = [
    # 1. The Pipeline User (Keep this so CI/CD keeps working)
    {
      userarn  = "arn:aws:iam::544584096688:user/github-actions-user"
      username = "github-actions-user"
      groups   = ["system:masters"]
    },
    # 2. Your Root User
    {
      userarn  = "arn:aws:iam::544584096688:root"
      username = "root-admin"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# AWS Load Balancer Controller - IAM & Roles
# -----------------------------------------------------------------------------

data "http" "lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lb_controller" {
  name        = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM Policy for AWS Load Balancer Controller"
  policy      = data.http.lb_controller_policy.response_body
}

module "lb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.cluster_name}-lb-controller"
  attach_load_balancer_controller_policy = false

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role       = module.lb_role.iam_role_name
  policy_arn = aws_iam_policy.lb_controller.arn
}

# -----------------------------------------------------------------------------
# AWS Load Balancer Controller - Helm Installation
# -----------------------------------------------------------------------------

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.2"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_role.iam_role_arn
  }

  depends_on = [
    module.eks,
    module.lb_role
  ]
}

# -----------------------------------------------------------------------------
# Flux CD - GitOps Continuous Delivery
# -----------------------------------------------------------------------------

resource "helm_release" "flux" {
  name       = "flux2"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  namespace  = "flux-system"
  version    = "2.12.0"

  create_namespace = true

  # Enable image automation components for automatic image updates
  set {
    name  = "imageAutomationController.create"
    value = "true"
  }

  set {
    name  = "imageReflectorController.create"
    value = "true"
  }

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller
  ]
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "load_balancer_controller_role_arn" {
  description = "The ARN of the IAM role created for the Load Balancer Controller"
  value       = module.lb_role.iam_role_arn
}

output "flux_namespace" {
  description = "Namespace where Flux CD is installed"
  value       = helm_release.flux.namespace
}

output "verify_flux" {
  description = "Command to verify Flux CD installation"
  value       = "kubectl get pods -n flux-system"
}

# -----------------------------------------------------------------------------
# Flux CD - Bootstrap Automation
# -----------------------------------------------------------------------------

variable "github_token" {
  description = "GitHub Personal Access Token (PAT) for Flux CD authentication"
  type        = string
  sensitive   = true
}

resource "kubernetes_secret" "flux_git_auth" {
  metadata {
    name      = "flux-git-auth"
    namespace = "flux-system"
  }

  data = {
    username = "git"
    password = var.github_token
  }

  type = "Opaque"

  depends_on = [
    helm_release.flux
  ]
}

resource "null_resource" "flux_bootstrap" {
  depends_on = [
    helm_release.flux,
    kubernetes_secret.flux_git_auth
  ]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
      kubectl apply -f ${path.module}/../flux/sources/git-repository.yaml
      kubectl apply -f ${path.module}/../flux/sync.yaml
    EOT
  }
}
