variable "prefix" {
  type = string
  description = "Prefix to assign to all VPC resources, example: dev"
  nullable = false  
}

variable "ssh_key_name" {
  type = string
  # Change this as needed to an existing ssh key.
  # FYI this is used by the bastion box as well as the NAT instances
  nullable = false
}

variable "public_access_allow_list" {
  # This controls public access to the Load Balancer and to the SSH Bastion box.
  # Be sure to keep this tightened down as much as possible.
  type = list(string)
  nullable = false
}

variable "vpc_cidr" {
  default = "10.64.0.0/16"
}

variable "availability_zones" {
  type = list(string)
  default = [
    "us-west-2a",
    "us-west-2b",
    # "us-west-2c",
    # "us-west-2d",
  ]
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.64.0.0/20",
    "10.64.16.0/20",
    # "10.64.32.0/20",
    # "10.64.48.0/20",
  ]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "10.64.128.0/20",
    "10.64.144.0/20",
    # "10.64.160.0/20",
    # "10.64.176.0/20",
  ]
}
