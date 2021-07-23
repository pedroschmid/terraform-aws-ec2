resource "aws_vpc" "this" {
  cidr_block           = var.VPC_CIDR_BLOCK
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "terraform-vpc"
  }
}

resource "aws_subnet" "public" {
  count = length(var.PUBLIC_SUBNETS_CIDR)

  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.PUBLIC_SUBNETS_CIDR, count.index)
  availability_zone = element(var.AVAILABILITY_ZONES, count.index)

  tags = {
    "Name" = "terraform-public-subnet-${element(var.AVAILABILITY_ZONES, count.index)}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.PRIVATE_SUBNETS_CIDR)

  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.PRIVATE_SUBNETS_CIDR, count.index)
  availability_zone = element(var.AVAILABILITY_ZONES, count.index)

  tags = {
    "Name" = "terraform-private-subnet-${element(var.AVAILABILITY_ZONES, count.index)}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "terraform-igw"
  }
}

resource "aws_eip" "this" {
  vpc = true
  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    "Name" = "terraform-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on = [
    aws_eip.this
  ]

  tags = {
    "Name" = "terraform-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "terraform-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "terraform-private-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.PUBLIC_SUBNETS_CIDR)

  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count = length(var.PRIVATE_SUBNETS_CIDR)

  route_table_id = aws_route_table.private.id
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}