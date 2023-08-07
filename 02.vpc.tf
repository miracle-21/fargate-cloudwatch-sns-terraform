resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                    = "${var.name}-vpc"
    "kubernetes.io/cluster/${var.name}-clu" = "shared"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-ig"
  }
}

resource "aws_nat_gateway" "natgw" {
  count         = var.count_pub_subnets
  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.ig]

  tags = {
    Name = "${var.name}-natgw-${format("%03d", count.index + 1)}"
  }
}

resource "aws_eip" "eip" {
  count = var.count_pri_subnets
  vpc   = true

  tags = {
    Name = "${var.name}-eip-${format("%03d", count.index + 1)}"
  }
}

resource "aws_subnet" "public" {
  count             = var.count_pub_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "${var.region}${count.index == 0 ? "a" : "c"}"

  tags = {
    Name                                    = "${var.name}-pub-${format("%03d", count.index + 1)}"
    "kubernetes.io/cluster/${var.name}-clu" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}

resource "aws_subnet" "private" {
  count             = var.count_pri_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = "${var.region}${count.index == 0 ? "a" : "c"}"

  tags = {
    Name                                    = "${var.name}-pri-${format("%03d", count.index + 1)}"
    "kubernetes.io/cluster/${var.name}-clu" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}

resource "aws_subnet" "db" {
  count             = var.count_db_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index + 4}.0/24"
  availability_zone = "${var.region}${count.index == 0 ? "a" : "c"}"

  tags = {
    Name = "${var.name}-db-${format("%03d", count.index + 1)}"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.rocidr
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "${var.name}-pub-rt"
  }
}

resource "aws_route_table" "private" {
  count  = var.count_pri_subnets
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.rocidr
    nat_gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
  }

  tags = {
    Name = "${var.name}-pri-rt-${format("%03d", count.index + 1)}"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.count_pub_subnets
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = var.count_pri_subnets
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
