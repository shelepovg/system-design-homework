# Terraform — базовая инфраструктура (связь с `likec4/deployment.c4`)

## Краткая справка

Логическая архитектура в LikeC4 (`likec4/model.c4`), физическое развёртывание в `likec4/deployment.c4` (регион A: edge, VM-слой с PostgreSQL, Redis, Kafka, Vault, MinIO, observability, Kubernetes для микросервисов), документация в AsciiDoc (NFR 1.02, схема развёртывания 4.01).

Этот каталог **не** воспроизводит всю multi-region схему и не поднимает Kafka, Vault, K8s-кластер — это был бы отдельный стек (EKS, MSK, RDS и т.д.). Здесь зафиксирован **минимальный mvp каркас** в AWS, который соответствует **идее** слоёв из deployment:

| Слой в `deployment.c4` | Что в Terraform |
| --- | --- |
| `vm_edge_waf_cdn` | Не создаётся как EC2 (managed WAF/CDN у провайдера). Вход — публичный ALB как упрощённая точка входа после edge. |
| `vm_perimeter` | `aws_lb` (ALB) + security group публичного периметра. |
| `k8s_workloads` | Упрощённо: одна EC2 в `private_app` с nginx на `:8080` за ALB. |
| `vm_postgresql` | EC2 в `private_data` + отдельный data-том EBS (установка PostgreSQL — вне Terraform). |
| `vm_redis` | EC2 в `private_data` (вторая AZ) + data-том (установка Redis — вне Terraform). |
| `vm_object_storage` / бэкапы / логи | `aws_s3_bucket` + IAM instance profile для приложений + gateway VPC endpoint на S3. |

Сеть: VPC, публичные и private подсети **до трёх AZ** в регионе (`locals.tf`: `min(3, …)` от списка AZ провайдера; если в регионе только 2 AZ — будет две), IGW, опциональный NAT, route tables, security groups с принципом least privilege между ALB → app → БД. Это согласуется с doc/2.08 (мульти-АЗ 2–3) и doc/4.01 (Multi-AZ в регионе); **не** дублирует полный сайзинг «≥3 инстанса на сервис в разных AZ» — для MVP по-прежнему одна ВМ приложения, см. `compute.tf`.

## Требования

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.5`
- Учётная запись AWS и настроенные credentials (например, `aws configure` или переменные окружения `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`)
- Права на создание VPC, EC2, ELB, S3, IAM role/instance profile, VPC endpoints

## Подготовка

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# скорректировать terraform.tfvars при необходимости
```

## Инициализация и план

```bash
terraform init
terraform plan -out=tfplan
```

## Применение

```bash
terraform apply tfplan
```

Либо интерактивно:

```bash
terraform apply
```

После успешного apply:

- в выводе будет `alb_dns_name` — проверка HTTP: `curl http://<alb_dns_name>/`
- `s3_bucket_artifacts` — имя bucket для загрузки логов/артефактов с ВМ приложения (роль уже ограничена этим bucket в IAM policy).

## Удаление

```bash
terraform destroy
```

Для пустого bucket при destroy в песочнице можно выставить в `terraform.tfvars`:

```hcl
s3_force_destroy = true
```

## Переменные окружения (AWS)

Стандартно для AWS CLI/SDK, например:

- `AWS_REGION` или регион в `terraform.tfvars` (`aws_region`)
- `AWS_PROFILE` — если используете профиль

## Ограничения и следующие шаги

- Нет отдельных ВМ под Kafka, Vault, observability, MinIO — их можно добавить по тем же паттернам (EC2 + SG + тома) или заменить управляемыми сервисами.
- PostgreSQL и Redis на EC2 **не установлены** user-data — только разметка ОС; в проде чаще RDS + ElastiCache или кластеры с ansible/k8s.
- HTTPS на ALB потребует ACM-сертификат и listener `443` — в шаблоне оставлен HTTP `80` для простоты.
- Для соответствия полному sizing из `deployment.c4` / 4.01 увеличьте `instance_type_*` и размеры EBS через переменные.
