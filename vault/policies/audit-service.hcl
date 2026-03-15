# Audit Service — БД (audit_db), Kafka (3.04).

path "database/creds/audit-db" {
  capabilities = ["read"]
}

path "secret/data/prod/kafka" {
  capabilities = ["read"]
}
path "secret/metadata/prod/kafka" {
  capabilities = ["read", "list"]
}
