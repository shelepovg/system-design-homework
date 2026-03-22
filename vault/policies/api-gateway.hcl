# API Gateway — доступ только к секретам IAM (Keycloak) и при необходимости rate-limit (3.04).
# Применение: policy api-gateway привязать к AppRole api-gateway.

path "secret/data/prod/iam" {
  capabilities = ["read"]
}
path "secret/metadata/prod/iam" {
  capabilities = ["read", "list"]
}

# Опционально: конфигурация rate limit (если хранится в Vault)
path "secret/data/prod/rate-limit" {
  capabilities = ["read"]
}
path "secret/metadata/prod/rate-limit" {
  capabilities = ["read", "list"]
}
