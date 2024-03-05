resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
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
  count                           = var.num_azs
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch         = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, count.index)
  assign_ipv6_address_on_creation = true
  availability_zone               = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.prefix}-${data.aws_availability_zones.available.names[count.index]}-public-subnet"
    type = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.num_azs
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count             = var.num_azs
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index + 8)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, count.index + 128)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.prefix}-${data.aws_availability_zones.available.names[count.index]}-private-subnet"
    type = "private"
  }
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-egress-only-igw"
  }
}

resource "aws_route_table" "private" {
  count  = var.num_azs
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-private-route-table"
  }
}

resource "aws_route" "private_ipv6_default" {
  count                       = var.num_azs
  route_table_id              = aws_route_table.private[count.index].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.eigw.id
}

resource "aws_route_table_association" "private" {
  count          = var.num_azs
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
