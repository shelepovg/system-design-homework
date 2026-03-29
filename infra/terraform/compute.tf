locals {
  app_user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    dnf install -y nginx
    cat >/etc/nginx/conf.d/app.conf <<'NGX'
    server {
      listen 8080 default_server;
      location / {
        default_type text/plain;
        return 200 "app tier ok\n";
      }
    }
    NGX
    systemctl enable --now nginx
  EOT

  db_user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    # Разметка томов и установка СУБД — вне scope Terraform; здесь только заготовка ОС.
    echo "data tier ready — install PostgreSQL/Redis per runbook" >/var/lib/instance-bootstrap.txt
  EOT
}

resource "aws_lb" "public" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_lb.id]
  subnets            = aws_subnet.public[*].id

  tags = merge(local.common_tags, {
    Name      = "${var.project_name}-alb"
    LikeC4Ref = "vm_perimeter (L7 entry)"
  })
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 15
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-tg-app" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type_app
  subnet_id              = aws_subnet.private_app[0].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.app.name
  user_data              = base64encode(local.app_user_data)

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-app-01"
    LikeC4Ref   = "k8s_workloads (упрощённо одна ВМ)"
    Description = "Плейсхолдер под микросервисы / ingress backend"
  })
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
  port             = 8080
}

resource "aws_instance" "postgresql" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type_postgresql
  subnet_id              = aws_subnet.private_data[0].id
  vpc_security_group_ids = [aws_security_group.postgresql.id]
  user_data              = base64encode(local.db_user_data)

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp3"
    volume_size           = var.postgresql_data_volume_gb
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-postgresql-01"
    LikeC4Ref   = "vm_postgresql (primary tier — один узел в учебном шаблоне)"
    Description = "Для HA master+replica см. отдельные инстансы или RDS"
  })
}

resource "aws_instance" "redis" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type_redis
  subnet_id              = aws_subnet.private_data[1].id
  vpc_security_group_ids = [aws_security_group.redis.id]
  user_data              = base64encode(local.db_user_data)

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp3"
    volume_size           = var.redis_data_volume_gb
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-redis-01"
    LikeC4Ref   = "vm_redis"
    Description = "Кластер Redis в проде — несколько узлов в разных AZ"
  })
}
