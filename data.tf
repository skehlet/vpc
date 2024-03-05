data "aws_ami" "amazon_linux" {
  most_recent = true
  name_regex  = "^al2023-ami-2023"
  owners      = ["amazon"]
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

data "aws_ami" "fck_nat" {
  filter {
    name   = "name"
    values = ["fck-nat-al2023-*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  owners      = ["568608671756"]
  most_recent = true
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
