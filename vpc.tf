resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-${var.availability_zones[count.index]}-public-subnet"
    type = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "${var.prefix}-${var.availability_zones[count.index]}-private-subnet"
    type = "private"
  }
}

resource "aws_security_group" "nat" {
  count  = length(var.private_subnet_cidrs)
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
  count                       = length(var.private_subnet_cidrs)
  ami                         = data.aws_ami.fck_nat.id
  availability_zone           = var.availability_zones[count.index]
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

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat[count.index].primary_network_interface_id
  }
  tags = {
    Name = "${var.prefix}-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count     = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
