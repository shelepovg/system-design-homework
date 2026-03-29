output "vpc_id" {
  description = "ID VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Публичные подсети (ALB, NAT)."
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "Private подсети для приложений."
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  description = "Private подсети для БД и Redis."
  value       = aws_subnet.private_data[*].id
}

output "alb_dns_name" {
  description = "DNS-имя ALB — точка входа HTTP (аналог периметра за WAF)."
  value       = aws_lb.public.dns_name
}

output "s3_bucket_artifacts" {
  description = "Bucket для логов, бэкапов, артефактов (S3 API)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "ec2_app_instance_id" {
  value = aws_instance.app.id
}

output "ec2_postgresql_instance_id" {
  value = aws_instance.postgresql.id
}

output "ec2_redis_instance_id" {
  value = aws_instance.redis.id
}
