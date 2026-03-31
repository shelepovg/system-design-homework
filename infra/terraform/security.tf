# Публичный периметр: HTTPS с интернета (аналог vm_perimeter за WAF/CDN в модели).
resource "aws_security_group" "public_lb" {
  name        = "${var.project_name}-sg-public-lb"
  description = "Ingress 80/443 с интернета (ALB / NLB)."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP redirect"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-sg-public-lb"
    LikeC4Ref   = "vm_perimeter"
    Description = "Периметр L7 до приложений"
  })
}

# ВМ приложений: трафик только от балансировщика (или внутри VPC для отладки).
resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg-app"
  description = "ВМ приложений / worker tier."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App from LB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.public_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-sg-app"
    LikeC4Ref   = "k8s_workloads"
    Description = "Слой приложений (упрощённо без отдельного SG на каждый namespace)"
  })
}

# PostgreSQL: только от приложений.
resource "aws_security_group" "postgresql" {
  name        = "${var.project_name}-sg-postgresql"
  description = "PostgreSQL (likec4 vm_postgresql)."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name      = "${var.project_name}-sg-postgresql"
    LikeC4Ref = "vm_postgresql"
  })
}

# Redis: только от приложений.
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-sg-redis"
  description = "Redis (likec4 vm_redis)."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Redis"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name      = "${var.project_name}-sg-redis"
    LikeC4Ref = "vm_redis"
  })
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(local.common_tags, {
    Name      = "${var.project_name}-vpce-s3-gateway"
    LikeC4Ref = "vm_object_storage / backup-storage S3 API"
  })
}
