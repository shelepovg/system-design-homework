# Конфигурация Vault для System Design

Конфигурация соответствует документу **3.04 Хранение и управление секретами**: HashiCorp Vault, KV v2, Database engine (PostgreSQL), Transit (опционально), AppRole/Kubernetes Auth, принцип наименьших привилегий (NFR-005).

## Структура

| Каталог / файл | Назначение |
|----------------|------------|
| `policies/*.hcl` | ACL-политики по сервисам: только нужные пути (3.04). |
| `config/database-postgres.hcl.example` | Пример настройки Database engine для PostgreSQL. |
| `scripts/setup-policies.sh` | Применение всех политик: `VAULT_ADDR=... VAULT_TOKEN=... ./vault/scripts/setup-policies.sh`. |
| `README.md` | Включение движков, auth, применение политик, пути секретов. |

## Пути секретов (3.04)

| Путь | Движок | Содержимое | Кто читает |
|------|--------|------------|------------|
| `secret/data/prod/iam` | KV v2 | client_id, client_secret Keycloak | API Gateway, User Service |
| `secret/data/prod/redis` | KV v2 | Пароль Redis | Все микросервисы |
| `secret/data/prod/kafka` | KV v2 | SASL/SSL для Kafka | Все микросервисы, мониторинг |
| `secret/data/prod/payment` | KV v2 | API key, webhook signing secret | Payment Service |
| `secret/data/prod/notification` | KV v2 | API key, SMTP и т.д. | Notification Service |
| `secret/data/prod/rate-limit` | KV v2 | Опционально: лимиты | API Gateway |
| `database/creds/users-db` | Database | Краткосрочные creds PostgreSQL (users_db) | User Service |
| `database/creds/requests-db` | Database | То же для requests_db | Request Processing Service |
| `database/creds/payments-db` | Database | То же для payments_db | Payment Service |
| `database/creds/notifications-db` | Database | То же для notifications_db | Notification Service |
| `database/creds/audit-db` | Database | То же для audit_db | Audit Service |
| `transit/keys/config-key` | Transit | Ключ для encrypt/decrypt (опционально) | Сервисы по политике (2.13, 3.03) |

В KV v2 чтение — через `secret/data/<path>`, метаданные — `secret/metadata/<path>`.

## Включение движков и применение политик

Требуется токен с правами администратора Vault (или root). Команды приведены для Vault CLI.

### 1. Включить KV v2 и Database

```bash
vault secrets enable -path=secret kv-v2
vault secrets enable database
```

### 2. Настроить Database engine для PostgreSQL

Для каждой БД (users-db, requests-db, payments-db, notifications-db, audit-db):

- Создать в PostgreSQL роль с правами на создание/удаление временных ролей (или использовать существующую мастер-учётку с ограниченными правами).
- Записать конфиг: `vault write database/config/users-db plugin_name=postgresql-database-plugin allowed_roles=users-db connection_url="..." username="..." password="..."`.
- Создать роль для выдачи creds: `vault write database/roles/users-db db_name=users-db role_name=vault_users creation_statements="CREATE ROLE ..." default_ttl=1h max_ttl=24h`.

См. `config/database-postgres.hcl.example` и [документацию Vault Database](https://developer.hashicorp.com/vault/docs/secrets/databases/postgresql).

### 3. (Опционально) Transit

```bash
vault secrets enable transit
vault write -f transit/keys/config-key type=aes256-gcm
```

Политики для сервисов, которым нужен encrypt/decrypt: `path "transit/encrypt/config-key" { capabilities = ["create", "update"] }` и `transit/decrypt/config-key`.

### 4. Включить AppRole и зарегистрировать политики

```bash
vault auth enable approle

for policy in api-gateway user-service request-processing-service payment-service notification-service audit-service operator; do
  vault policy write "$policy" "policies/${policy}.hcl"
done
```

### 5. Создать AppRole для каждого сервиса

Пример для API Gateway:

```bash
vault write auth/approle/role/api-gateway token_policies="api-gateway" token_ttl=1h token_max_ttl=4h
vault read auth/approle/role/api-gateway/role-id
vault write -f auth/approle/role/api-gateway/secret-id
```

`role-id` и `secret-id` передаются приложению (или Vault Agent) при старте; хранить в безопасном месте (Kubernetes Secret, CI/CD secrets), не в коде. Рекомендация: secret_id в Vault или в облачном хранилище секретов, инъекция при деплое.

Аналогично создать роли: `user-service`, `request-processing-service`, `payment-service`, `notification-service`, `audit-service`. Для CI/CD/оператора — роль с политикой `operator` и коротким TTL.

### 6. Kubernetes Auth (альтернатива AppRole в K8s)

При развёртывании в Kubernetes можно включить `vault auth enable kubernetes` и привязать JWT подов к политикам по `service_account_name` и `namespace`. Тогда роль и JWT подставляются автоматически; секреты получает Vault Agent (sidecar/init).

### 7. Аудит

Включить аудит в файл или socket для пересылки в централизованное хранилище (2.09, 3.02):

```bash
vault audit enable file file_path=/vault/logs/audit.log
# или socket для внешнего коллектора
```

## Заполнение секретов

После включения движков записать статические секреты в KV v2 (вручную или из CI/CD с политикой `operator`):

```bash
vault kv put secret/prod/iam client_id=api-gateway client_secret="..."
vault kv put secret/prod/redis password="..."
vault kv put secret/prod/kafka username=... password=...
vault kv put secret/prod/payment api_key="..." webhook_secret="..."
vault kv put secret/prod/notification api_key="..." smtp_password="..."
```

Значения брать из реальных систем (Keycloak, Redis, Kafka, платёжный провайдер и т.д.); в production не подставлять секреты в командную строку из неизвестных источников.

## Интеграция с приложениями

- **Spring Boot:** Spring Cloud Vault (bootstrap: `spring.cloud.vault.uri`, `spring.cloud.vault.authentication=approle`, `spring.cloud.vault.app-role.role-id`, `role-secret-id` из env). Пути по умолчанию: `secret/${spring.application.name}` или задать `spring.config.import=vault://secret/prod/...`.
- **Vault Agent:** конфиг с AppRole и template, выводящий секреты в файлы или env; запуск как sidecar/init в Kubernetes.

Конфигурационные файлы приложений не должны содержать сами секреты — только адрес Vault и идентификаторы роли (3.04).

## Ротация (3.04)

- **Динамические (Database):** TTL задаётся в роли (например 1 ч); ротация автоматическая.
- **Статические (KV v2):** не реже 90 дней; новый секрет → `vault kv put secret/prod/...` (новая версия) → перезапуск сервисов или Vault Agent.
- **Transit:** новая версия ключа в Vault; перешифрование данных по политике (2.13).

## Ссылки

- 3.04 — хранение и управление секретами, схема, ротация.
- 2.09, 3.02 — аудит Vault в централизованное хранилище.
- 2.13, 3.03 — ключи шифрования (Transit, field-level).
