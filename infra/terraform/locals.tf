locals {
  # До 3 зон доступности в регионе (doc/2.08: мульти-АЗ 2–3; doc/4.01: Multi-AZ в регионе).
  # Если в регионе меньше трёх AZ — берётся фактическое число (slice не выходит за список).
  az_count = min(3, length(data.aws_availability_zones.available.names))
  azs      = slice(data.aws_availability_zones.available.names, 0, local.az_count)

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
