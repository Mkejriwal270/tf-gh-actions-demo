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
    }
} 

provider aws {
    region = var.aws_region
}