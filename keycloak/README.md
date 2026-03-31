# Конфигурация Keycloak для System Design

Конфигурация соответствует документу **3.01 Схема защиты и управления доступом**: OAuth 2.0, OIDC, JWT, RBAC, сроки жизни токенов и сессий (FR-002), роли из 3.01.

## Содержимое

| Файл | Назначение |
|------|------------|
| `realm-system-design.json` | Realm: настройки токенов и сессий, клиенты, роли. Импорт через Admin UI или API. |

## Параметры из проекта

- **Realm:** `system-design`
- **Access token (JWT):** 15 мин (900 с), подпись RS256 (3.01).
- **Refresh token:** rotation (одноразовое использование), отзыв при использовании (3.01); действует в пределах SSO-сессии (см. ниже).
- **SSO Session Idle:** 30 мин (1800 с) — таймаут неактивности (`ssoSessionIdleTimeout`, FR-002).
- **SSO Session Max:** **24 ч** (86400 с) — максимальная длительность сессии с момента входа (`ssoSessionMaxLifespan`); после истечения требуется повторный логин, даже при наличии refresh token (3.01).
- **Offline session (опционально):** `offlineSessionIdleTimeout` 30 суток — только для клиентов с `offline_access`, не продлевает интерактивную SSO сверх 24 ч без отдельной политики.
- **Защита от brute-force:** включена (1.01, 2.08): `failureFactor`, `maxFailureWaitSeconds`, блокировка после N неудачных попыток.
- **Клиенты:**
  - **system-design-web** — публичный, SPA; Authorization Code + PKCE; `redirectUris` и `webOrigins` задать под окружение.
  - **system-design-mobile** — публичный, Android/iOS; PKCE.
  - **api-gateway** — конфиденциальный; server-side обмен code на токены, service account; `client_secret` брать из Vault (3.04).
  - **payment-webhook** — конфиденциальный; Client Credentials для приёма webhook; роль SERVICE.
- **Роли realm:** ADMIN, OPERATOR, USER, VIEWER, SERVICE, SUPPORT, AUDITOR, BILLING (3.01).

Роли попадают в JWT в claim `realm_access.roles` (стандартный client scope `roles`). API Gateway и User Service проверяют права по этим ролям.

## Импорт realm

### Через Admin Console

1. Войти в Keycloak Admin (master realm).
2. Создать realm → **Import**.
3. Выбрать файл `realm-system-design.json`.
4. Включить при необходимости **If a resource with the same name exists** (перезапись).

### Через CLI (kcadm.sh)

```bash
# Логин в master (подставьте URL и учётные данные admin)
KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"
/opt/keycloak/bin/kcadm.sh config credentials \
  --server "$KEYCLOAK_URL" \
  --realm master \
  --user admin \
  --password admin

# Импорт realm
/opt/keycloak/bin/kcadm.sh create realms -f realm-system-design.json
```

Если realm уже существует, можно обновлять клиентов и роли отдельно (см. Keycloak Admin API).

## После импорта

1. **Redirect URIs и Web Origins** для `system-design-web` и `system-design-mobile` заменить на реальные (production, staging, localhost для разработки).
2. **Секреты конфиденциальных клиентов** (`api-gateway`, `payment-webhook`): после импорта Keycloak создаёт секрет автоматически. Скопировать из Keycloak (Clients → client → Credentials) и записать в Vault по путям из 3.04 (например `secret/prod/iam`).
3. **Пользователи и назначение ролей:** создавать пользователей в Keycloak и назначать realm roles (ADMIN, USER и т.д.); при использовании User Service — синхронизация с users_db и аудит назначений (3.01).
4. **MFA для администраторов (NFR-005):** включить в Keycloak для роли ADMIN (Required Actions, OTP Policy) при необходимости.

## Ссылки на документы

- 3.01 — схема защиты, RBAC, токены, роли.
- 3.04 — хранение client_secret в Vault.
- 2.08 — rate limiting на логин (на стороне API Gateway).
- FR-002, FR-003 — аутентификация и авторизация.
