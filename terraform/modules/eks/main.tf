data "aws_eks_cluster" "cluster" {
  name = module.k8s-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.k8s-cluster.cluster_id
}

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
    map_users                       = [
        {
            userarn  = "arn:aws:iam::051126537531:user/Milind-Admin"
            username = "Milind-Admin"
            groups   = ["system:masters"]
        }
    ]
    tags = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
    }
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = module.k8s-cluster.cluster_id
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate-pod-executionrole-actionsdemo.arn
  subnet_ids             = var.private_subnets

  selector {
    namespace = "default"
  }
}

resource "aws_eks_fargate_profile" "KubeSystem" {
  cluster_name           = module.k8s-cluster.cluster_id
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.fargate-pod-executionrole-actionsdemo.arn
  subnet_ids             = var.private_subnets

  selector {
    namespace = "kube-system"
  }

  depends_on = [
    aws_eks_fargate_profile.default
  ]
}

resource "aws_eks_fargate_profile" "CoreDns" {
  cluster_name           = module.k8s-cluster.cluster_id
  fargate_profile_name   = "CoreDNS"
  pod_execution_role_arn = aws_iam_role.fargate-pod-executionrole-actionsdemo.arn
  subnet_ids             = var.private_subnets

  selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" = "kube-dns"
    }
  }

  depends_on = [
      aws_eks_fargate_profile.KubeSystem
  ]
}