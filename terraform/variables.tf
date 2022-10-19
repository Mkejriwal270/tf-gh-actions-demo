variable "aws_region" {
    type = string
    default = "us-east-1"
}


variable "vpc_id" {
    type = string
}

variable "private_subnets" {
    type =  list(string)
    sensitive = true
}

variable "public_subnets" {
  type = list(string)
  sensitive = true
}

variable "cluster_name" {
  type = string
  default = "actions-runner-demo"
}