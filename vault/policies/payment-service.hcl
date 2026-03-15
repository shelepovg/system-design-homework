# Payment Service — БД (payments_db), Kafka, платёжный API key и webhook secret (3.04).

path "database/creds/payments-db" {
  capabilities = ["read"]
}

path "secret/data/prod/kafka" {
  capabilities = ["read"]
}
path "secret/metadata/prod/kafka" {
  capabilities = ["read", "list"]
}

path "secret/data/prod/payment" {
  capabilities = ["read"]
}
path "secret/metadata/prod/payment" {
  capabilities = ["read", "list"]
}
