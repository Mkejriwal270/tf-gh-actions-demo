
variable "vpc_id" {
    sensitive = true
}

variable "private_subnets" {
    type =  list(string)
    sensitive = true
}
variable "cluster_name" {
  type = string
}

variable "public_subnets" {
  type = list(string)
  sensitive = true
}