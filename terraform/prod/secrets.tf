# ------------------------------------------------------------------------------
# Secret Manager (импорт существующих секретов)
# ------------------------------------------------------------------------------

# Импортируем существующие секреты
data "google_secret_manager_secret" "db_password" {
  secret_id = "db_password"
  project   = var.project_id
}

data "google_secret_manager_secret" "zeno_auth_jwt_private_key" {
  secret_id = "zeno-auth-jwt-private-key"
  project   = var.project_id
}

data "google_secret_manager_secret" "zeno_auth_jwt_public_key" {
  secret_id = "zeno-auth-jwt-public-key"
  project   = var.project_id
}

data "google_secret_manager_secret" "zeno_auth_sendgrid_api_key" {
  secret_id = "zeno-auth-sendgrid-api-key"
  project   = var.project_id
}

data "google_secret_manager_secret" "stripe_secret_key" {
  secret_id = "stripe-secret-key"
  project   = var.project_id
}

data "google_secret_manager_secret" "stripe_webhook_secret" {
  secret_id = "stripe-webhook-secret"
  project   = var.project_id
}
