#!/usr/bin/env bash
# Импорт realm system-design в Keycloak через kcadm.sh.
# Требования: Keycloak запущен, kcadm.sh доступен (каталог bin Keycloak).
# Переменные: KEYCLOAK_URL (по умолчанию http://localhost:8080), KEYCLOAK_ADMIN, KEYCLOAK_ADMIN_PASSWORD.

set -e
KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REALM_FILE="${SCRIPT_DIR}/realm-system-design.json"

if [ ! -f "$REALM_FILE" ]; then
  echo "Файл realm не найден: $REALM_FILE"
  exit 1
fi

# Поиск kcadm.sh (Keycloak 18+ — kcadm.sh в bin)
KCADM="${KEYCLOAK_HOME}/bin/kcadm.sh"
if [ -z "$KEYCLOAK_HOME" ]; then
  for d in /opt/keycloak /usr/share/keycloak "$HOME/keycloak"; do
    if [ -x "$d/bin/kcadm.sh" ]; then
      KCADM="$d/bin/kcadm.sh"
      break
    fi
  done
fi
if [ ! -x "$KCADM" ]; then
  echo "kcadm.sh не найден. Задайте KEYCLOAK_HOME или установите Keycloak."
  echo "Пример: KEYCLOAK_HOME=/opt/keycloak $0"
  exit 1
fi

echo "Keycloak: $KEYCLOAK_URL"
echo "Realm file: $REALM_FILE"
echo "Импорт realm system-design..."

"$KCADM" config credentials \
  --server "$KEYCLOAK_URL" \
  --realm master \
  --user "${KEYCLOAK_ADMIN:-admin}" \
  --password "${KEYCLOAK_ADMIN_PASSWORD:-admin}"

"$KCADM" create realms -f "$REALM_FILE"

echo "Realm system-design создан. Не забудьте: redirect URIs, секреты клиентов (Vault), назначение ролей пользователям."
