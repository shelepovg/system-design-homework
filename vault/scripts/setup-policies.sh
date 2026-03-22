#!/usr/bin/env bash
# Применение политик Vault из каталога policies/.
# Требования: vault в PATH, переменные VAULT_ADDR и VAULT_TOKEN (токен с правами на запись политик).
# Запуск из корня репозитория: ./vault/scripts/setup-policies.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POLICIES_DIR="$(cd "$SCRIPT_DIR/../policies" && pwd)"

if [ -z "$VAULT_ADDR" ] || [ -z "$VAULT_TOKEN" ]; then
  echo "Задайте VAULT_ADDR и VAULT_TOKEN"
  exit 1
fi

for hcl in "$POLICIES_DIR"/*.hcl; do
  name=$(basename "$hcl" .hcl)
  echo "Applying policy: $name"
  vault policy write "$name" "$hcl"
done

echo "Политики применены. Дальше: включить auth approle, создать AppRole для каждого сервиса, записать секреты в secret/prod/* и настроить Database engine (см. README)."
