# Notification Service — БД (notifications_db), Kafka, провайдер уведомлений (3.04).

path "database/creds/notifications-db" {
  capabilities = ["read"]
}

path "secret/data/prod/kafka" {
  capabilities = ["read"]
}
path "secret/metadata/prod/kafka" {
  capabilities = ["read", "list"]
}

path "secret/data/prod/notification" {
  capabilities = ["read"]
}
path "secret/metadata/prod/notification" {
  capabilities = ["read", "list"]
}
