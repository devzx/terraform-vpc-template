provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.aws_credentials_file}"
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.vpc_name} Security Group"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet_cidr}"

  tags {
    Name = "${var.vpc_name} Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet_cidr}"

  tags {
    Name = "${var.vpc_name} Private Subnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_name} IG"
  }
}

resource "aws_eip" "nat" {
  tags {
    Name = "${var.vpc_name} NAT Gateway"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  tags {
    Name = "${var.vpc_name} NAT Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }

  tags {
    Name = "${var.vpc_name} Public Route Table"
  }
}

resource "aws_default_route_table" "private" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  tags {
    Name = "${var.vpc_name} Private Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_vpc.main.default_route_table_id}"
}
