resource "aws_security_group" "bastion" {
  count  = var.launch_bastion ? 1 : 0
  name   = "${var.prefix}-bastion"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.public_access_allow_list
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-bastion"
  }
}

resource "aws_launch_configuration" "bastion" {
  count           = var.launch_bastion ? 1 : 0
  name_prefix     = "${var.prefix}-bastion"
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = "t4g.nano"
  key_name        = var.ssh_key_name
  security_groups = ["${aws_security_group.bastion[0].id}"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  count                = var.launch_bastion ? 1 : 0
  name_prefix          = "${var.prefix}-bastion"
  launch_configuration = aws_launch_configuration.bastion[0].id
  vpc_zone_identifier  = aws_subnet.public.*.id
  min_size             = 1
  max_size             = 1
  tag {
    key                 = "Name"
    value               = "${var.prefix}-bastion"
    propagate_at_launch = true
  }
}
