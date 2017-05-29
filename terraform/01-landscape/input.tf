# =============================================================================

variable "project_name" {}
variable "project_region" {}

variable "vpc_cidr" {}

variable "public_subnet_cidr_a" {}
variable "private_subnet_cidr_a" {}

variable "public_subnet_cidr_b" {}
variable "private_subnet_cidr_b" {}

variable "public_subnet_cidr_c" {}
variable "private_subnet_cidr_c" {}

variable "bastion_default_public_key" {}

# =============================================================================

provider "aws" {
  region = "${var.project_region}"
}

# =============================================================================

data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-jessie-amd64-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["379101102735"] # Debian Project
}


