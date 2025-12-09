# ✅ Pre-Deploy Checklist

## Проверка перед деплоем

### 1. Режим экономии ✅
- [x] `min_instance_count = 0` - все сервисы засыпают
- [x] `max_instance_count = 2` - ограничение масштабирования
- [x] Cloud SQL: `db-f1-micro` - минимальный tier
- [x] Без Redis - экономия ~$30/мес
- [x] Без VPC - экономия ~$8/мес

### 2. Платформа сборки ✅
- [x] `--platform linux/amd64` в deploy-first-time.sh
- [x] Все образы собираются локально
- [x] Версия: `v1.0.0`

### 3. Соответствие данных ✅

#### Cloud SQL
- [x] Instance: `zeno-sql-dev` (существует)
- [x] User: `zeno_user` (существует)
- [x] Password: `kfr7nrw9rfg@QTE1zaf` (в terraform.tfvars)
- [x] Databases: zeno_auth, zeno_billing, zeno_roles, zeno_usage (существуют)

#### Secrets
- [x] Все 6 секретов существуют
- [x] Используются `data` источники (не создаются заново)

#### Service Accounts
- [x] Все 5 SA существуют
- [x] Используются `data` источники

#### Pub/Sub
- [x] Topic: `zeno-usage-events` (существует)
- [x] Subscription: `zeno-usage-sub` (существует)
- [x] Используются `data` источники

### 4. Terraform конфигурация ✅
- [x] Убраны kubernetes и random providers
- [x] Все ресурсы используют `data` для существующих
- [x] Только Cloud Run сервисы создаются как `resource`
- [x] IAM для Cloud Run настроен

### 5. Переменные окружения ✅

#### zeno-auth
- [x] DB_USER, DB_NAME, DB_HOST, DB_PASSWORD
- [x] JWT_PRIVATE_KEY, JWT_PUBLIC_KEY
- [x] SENDGRID_API_KEY
- [x] CORS_ALLOWED_ORIGINS, ENV

#### zeno-billing
- [x] DB_USER, DB_NAME, DB_HOST, DB_PASSWORD
- [x] STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET
- [x] PUBSUB_PROJECT_ID, PUBSUB_TOPIC_BILLING_EVENTS
- [x] APP_AUTH_SERVICE_URL, APP_ALLOWED_ORIGINS

#### zeno-roles
- [x] ZENO_ROLES_DATABASE_URL, ZENO_ROLES_DATABASE_PASSWORD
- [x] ZENO_ROLES_GRPC_PORT, ZENO_ROLES_HTTP_PORT
- [x] ZENO_ROLES_CORS_ALLOWED_ORIGINS

#### zeno-usage
- [x] DB_USER, DB_NAME, DB_HOST, DB_PASSWORD
- [x] PUBSUB_PROJECT_ID, PUBSUB_SUBSCRIPTION
- [x] GRPC_PORT, HTTP_PORT

#### zeno-documents
- [x] Без переменных (stateless)

### 6. IAM права ✅
- [x] Cloud SQL Client для auth, billing, roles, usage
- [x] Secret Manager accessor для всех нужных секретов
- [x] Pub/Sub publisher для billing
- [x] Pub/Sub subscriber для usage
- [x] Cloud Run invoker (public для auth, billing, roles)

### 7. Стоимость (прогноз)
- Cloud SQL: ~$7/мес
- Secret Manager: ~$0.50/мес
- Pub/Sub: ~$0.50/мес
- Cloud Run (5 сервисов, min=0): ~$5-10/мес
- **Итого: ~$13-18/мес** 💰

---

## Готово к деплою! 🚀

Запуск:
```bash
./deploy-first-time.sh
```
