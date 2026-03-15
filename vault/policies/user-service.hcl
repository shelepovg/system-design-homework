# User Service — БД (users_db), Redis, Kafka, IAM client (3.04).

path "database/creds/users-db" {
  capabilities = ["read"]
}

path "secret/data/prod/redis" {
  capabilities = ["read"]
}
path "secret/metadata/prod/redis" {
  capabilities = ["read", "list"]
}

path "secret/data/prod/kafka" {
  capabilities = ["read"]
}
path "secret/metadata/prod/kafka" {
  capabilities = ["read", "list"]
}

path "secret/data/prod/iam" {
  capabilities = ["read"]
}
path "secret/metadata/prod/iam" {
  capabilities = ["read", "list"]
}
