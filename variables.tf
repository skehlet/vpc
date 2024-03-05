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

variable "num_azs" {
  type = number
  default = 2
}

variable "launch_bastion" {
  type = bool
  default = false
}

variable "launch_nat_instances" {
  type = bool
  default = true
}
