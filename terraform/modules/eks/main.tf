data "aws_eks_cluster" "cluster" {
  name = module.k8s-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.k8s-cluster.cluster_id
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

module "k8s-cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "17.24.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.22"
  subnets                         = concat(var.private_subnets, var.public_subnets)
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  vpc_id                          = var.vpc_id
  manage_cluster_iam_resources    = true
  manage_aws_auth                 = true
  map_roles = [
    {
      rolearn  = "${var.role_arn}"
      username = "gh-runner-user"
      groups   = ["system:masters"]
    }
  ]
  map_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Milind-Admin"
      username = "Milind-Admin"
      groups   = ["system:masters"]

    }
  ]

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
  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }
}
