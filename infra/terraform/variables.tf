variable "aws_region" {
  type        = string
  description = "Регион AWS (аналог «регион A» в likec4/deployment.c4)."
  default     = "eu-central-1"
}

variable "project_name" {
  type        = string
  description = "Префикс имён ресурсов."
  default     = "sd-homework"
}

variable "environment" {
  type        = string
  description = "Имя среды (prod, staging)."
  default     = "prod"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR VPC."
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "NAT для исходящего трафика из private-подсетей (патчи, образы). В учебной среде можно отключить и сэкономить."
  default     = true
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  description = "Откуда разрешён SSH на bastion (пустой список — ключ не используется, bastion без ingress SSH)."
  default     = []
}

variable "key_name" {
  type        = string
  description = "Имя SSH key pair в EC2 (опционально)."
  default     = ""
}

variable "instance_type_app" {
  type        = string
  description = "Тип ВМ уровня приложений / ingress (аналог k8s workloads + периметр в модели — упрощённо одна группа)."
  default     = "t3.large"
}

variable "instance_type_postgresql" {
  type        = string
  description = "Тип ВМ под PostgreSQL (likec4: vm_postgresql)."
  default     = "r6i.large"
}

variable "instance_type_redis" {
  type        = string
  description = "Тип ВМ под Redis (likec4: vm_redis)."
  default     = "r6i.large"
}

variable "postgresql_data_volume_gb" {
  type        = number
  description = "Размер data-тома PostgreSQL (GiB). В проде согласовать с sizing из deployment.c4 / 2.13."
  default     = 200
}

variable "redis_data_volume_gb" {
  type        = number
  description = "Размер тома под AOF/RDB Redis (GiB)."
  default     = 50
}

variable "s3_force_destroy" {
  type        = bool
  description = "Разрешить terraform destroy удалять непустой bucket (только для песочниц)."
  default     = false
}
