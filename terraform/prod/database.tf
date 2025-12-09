# ------------------------------------------------------------------------------
# Cloud SQL for PostgreSQL (импорт существующего инстанса)
# ------------------------------------------------------------------------------

# Импортируем существующий инстанс
# terraform import google_sql_database_instance.main zeno-cy-dev-001/zeno-sql-dev
data "google_sql_database_instance" "main" {
  name    = "zeno-sql-dev"
  project = var.project_id
}

# Импортируем существующие базы данных
data "google_sql_database" "zeno_auth_db" {
  name     = "zeno_auth"
  instance = data.google_sql_database_instance.main.name
  project  = var.project_id
}

data "google_sql_database" "zeno_billing_db" {
  name     = "zeno_billing"
  instance = data.google_sql_database_instance.main.name
  project  = var.project_id
}

data "google_sql_database" "zeno_roles_db" {
  name     = "zeno_roles"
  instance = data.google_sql_database_instance.main.name
  project  = var.project_id
}

data "google_sql_database" "zeno_usage_db" {
  name     = "zeno_usage"
  instance = data.google_sql_database_instance.main.name
  project  = var.project_id
}

# Используем локальную переменную для имени пользователя
locals {
  db_user = "zeno_user"
}
