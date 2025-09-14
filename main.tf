# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "demo-vpc"
    terraform = "true"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "demo-igw"
    terraform = "true"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, index(var.public_subnets, each.value))
  map_public_ip_on_launch = true

  tags = {
    Name      = "public-${each.value}"
    terraform = "true"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(var.private_subnets, each.value))

  tags = {
    Name      = "private-${each.value}"
    terraform = "true"
  }
}

# Elastic IP pour NAT
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name      = "demo-nat-eip"
    terraform = "true"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(values(aws_subnet.public)[*].id, 0)

  tags = {
    Name      = "demo-nat"
    terraform = "true"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route Table Publique
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name      = "public-rt"
    terraform = "true"
  }
}

# Association subnets publics
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route Table Privée
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name      = "private-rt"
    terraform = "true"
  }
}

# Association subnets privés
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
