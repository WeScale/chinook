
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  enable_dns_hostnames = true

  tags {
    Name = "${var.project_name}"
  }
}

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "${var.project_name}-bastion"
  public_key = "${var.bastion_default_public_key}"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }
  tags {
    Name = "Main route table for ${var.project_name} VPC"
  }
}

resource "aws_main_route_table_association" "main" {
  route_table_id = "${aws_route_table.main.id}"
  vpc_id = "${aws_vpc.vpc.id}"
}

module "zone_a" {
  source = "github.com/aurelienmaury/tf-mod-az-plus-nat"
  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${var.project_name}"
  availability_zone = "eu-west-1a"
  public_subnet_cidr = "${var.public_subnet_cidr_a}"
  private_subnet_cidr = "${var.private_subnet_cidr_a}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
  bastion_default_public_key = "${var.bastion_default_public_key}"
}

module "zone_b" {
  source = "github.com/aurelienmaury/tf-mod-az-plus-nat"
  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${var.project_name}"
  availability_zone = "eu-west-1b"
  public_subnet_cidr = "${var.public_subnet_cidr_b}"
  private_subnet_cidr = "${var.private_subnet_cidr_b}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
  bastion_default_public_key = "${var.bastion_default_public_key}"
}

module "zone_c" {
  source = "github.com/aurelienmaury/tf-mod-az-plus-nat"
  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${var.project_name}"
  availability_zone = "eu-west-1c"
  public_subnet_cidr = "${var.public_subnet_cidr_c}"
  private_subnet_cidr = "${var.private_subnet_cidr_c}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
  bastion_default_public_key = "${var.bastion_default_public_key}"
}

resource "aws_security_group" "bastion_realm" {

  name_prefix = "${var.project_name}-bastion-realm"

  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    security_groups = [
      "${module.zone_a.bastion_sg}",
      "${module.zone_b.bastion_sg}",
      "${module.zone_c.bastion_sg}"
    ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}