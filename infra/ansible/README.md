# Ansible — подготовка ВМ под homework

Автоматизация поверх инфраструктуры из `../terraform` и контекста развёртывания в `../../likec4/deployment.c4`:

- **Docker** (пакет `docker`, плагин `docker-compose-plugin`, `git`, `ca-certificates`) и включение сервиса на хостах группы `app` (Amazon Linux 2023, как в AMI Terraform).
- **PostgreSQL 15** на хостах `postgresql`: `postgresql-setup --initdb`, `listen_addresses`, запись в `pg_hba.conf` для `postgresql_allowed_cidr`, затем создание пользователя БД, базы и схемы через коллекцию `community.postgresql`.

## Требования

- Ansible 2.14+ на управляющей машине.
- SSH-доступ к EC2 (часто private IP + VPN или bastion; ключ и `ProxyJump` — в инвентаре или `~/.ssh/config`).

## Быстрый старт

```bash
cd infra/ansible
ansible-galaxy collection install -r requirements.yml -p collections
cp inventory/hosts.example.yml inventory/hosts.yml
# Подставьте ansible_host из вывода Terraform (private IP).
ansible-playbook playbooks/site.yml
```

Отдельные плейбуки: `playbooks/docker.yml`, `playbooks/postgresql.yml`. Теги: `--tags docker` или `--tags postgresql`.

## Переменные и секреты

| Где | Назначение |
|-----|------------|
| `group_vars/all.yml` | `postgresql_allowed_cidr` — подсеть, с которой разрешён TCP к Postgres (согласуйте с VPC и security groups в Terraform). |
| `group_vars/postgresql.yml` | `app_db_*`, каталог данных, имя unit systemd. |
| `roles/*/defaults/main.yml` | Значения по умолчанию ролей. |

Пароль приложения к БД не храните в открытом виде: `ansible-vault encrypt_string` и подключение `vault.yml`, либо внешний secret store.

## Риски и нюансы

- После добавления в группу `docker` пользователю `ec2-user` может понадобиться новая SSH-сессия, чтобы `docker` без `sudo` заработал.
- Если на образе другой путь `PGDATA` или имя unit не `postgresql`, поправьте `postgresql_data_dir` и `postgresql_service` в `group_vars/postgresql.yml`.
- Строка в `pg_hba.conf` добавляется без удаления дефолтных правил; для продакшена ужесточайте политику отдельно.
