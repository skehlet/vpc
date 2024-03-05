resource "aws_security_group" "nat" {
  count  = var.launch_nat_instances ? var.num_azs : 0
  name   = "${var.prefix}-nat${count.index}-sg"
  vpc_id = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.private[count.index].cidr_block]
  }
  tags = {
    Name = "${var.prefix}-nat${count.index}-sg"
  }
}

resource "aws_instance" "nat" {
  count                       = var.launch_nat_instances ? var.num_azs : 0
  ami                         = data.aws_ami.fck_nat.id
  availability_zone           = data.aws_availability_zones.available.names[count.index]
  instance_type               = "t4g.nano"
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.nat[count.index].id]
  subnet_id                   = aws_subnet.public[count.index].id
  associate_public_ip_address = true
  source_dest_check           = false
  tags = {
    Name = "${var.prefix}-nat${count.index}"
  }
}

resource "aws_route" "private_ipv4_nat" {
  count                  = var.launch_nat_instances ? var.num_azs : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat[count.index].primary_network_interface_id
}
