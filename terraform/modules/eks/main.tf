data "aws_eks_cluster" "cluster" {
  name = module.k8s-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.k8s-cluster.cluster_id
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

module "k8s-cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.30.2"
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.22"
  subnet_ids                      = var.private_subnets
  control_plane_subnet_ids        = concat(var.private_subnets, var.public_subnets)
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = var.vpc_id
  manage_aws_auth_configmap       = true

  fargate_profiles = {
    default = {
      name    = "default"
      subnets = var.private_subnets
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "cert-manager"
        },
        {
          namespace = "self-hosted-runners"
        },
        {
          namespace = "actions-runner-system"
        }

      ]
    }

    KubeSystem = {
      name    = "kube-system"
      subnets = var.private_subnets
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
    }

    CoreDns = {
      name    = "CoreDNS"
      subnets = var.private_subnets
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            "k8s-app" = "kube-dns"
          }
        }
      ]
    }

  }

  aws_auth_roles = [
    {
      rolearn  = "${var.role_arn}"
      username = "gh-runner-user"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Milind-Admin"
      username = "Milind-Admin"
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}
