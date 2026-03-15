# Request Processing Service — БД (requests_db), Redis, Kafka (3.04).

path "database/creds/requests-db" {
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
