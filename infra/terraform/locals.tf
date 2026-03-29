locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = {
    DeploymentRef = "likec4/deployment.c4:region_primary"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
