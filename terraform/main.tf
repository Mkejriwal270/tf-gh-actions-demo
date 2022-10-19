terraform {
    backend "s3" {
        region = "us-east-1"
        key = "tf-actions-backend/demo.tfstate"
    }


    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.3"
        }

        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.0"
        }
    }
}

provider aws {
    region = var.aws_region
}


provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "eks_cluster" {
    source = "./modules/eks"

    vpc_id = var.vpc_id
    private_subnets = var.private_subnets
    public_subnets = var.public_subnets
    cluster_name = var.cluster_name
    role_arn = var.role_arn
}