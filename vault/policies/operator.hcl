# Оператор / CI/CD — запись статических секретов для ротации (3.04).
# Назначение: создание и обновление секретов в secret/prod/* (не чтение произвольных секретов вне prod).
# Обычно привязан к отдельному AppRole или токену с ограниченным TTL.

path "secret/data/prod/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/metadata/prod/*" {
  capabilities = ["read", "list", "delete"]
}

# Конфигурация Database engine — только для админов Vault; оператору приложений не выдавать.
# path "database/config/*" { capabilities = ["create", "read", "update", "delete", "list"] }
