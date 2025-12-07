# ------------------------------------------------------------------------------
# Secret Manager
# ------------------------------------------------------------------------------

# --- Общие Секреты ---
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db_password"
  project   = var.project_id
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

# --- Секреты для zeno-auth ---
resource "google_secret_manager_secret" "zeno_auth_jwt_private_key" {
  secret_id = "zeno-auth-jwt-private-key"
  project   = var.project_id
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "zeno_auth_jwt_private_key" {
  secret      = google_secret_manager_secret.zeno_auth_jwt_private_key.id
  secret_data = var.zeno_auth_jwt_private_key
}

resource "google_secret_manager_secret" "zeno_auth_jwt_public_key" {
  secret_id = "zeno-auth-jwt-public-key"
  project   = var.project_id
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "zeno_auth_jwt_public_key" {
  secret      = google_secret_manager_secret.zeno_auth_jwt_public_key.id
  secret_data = var.zeno_auth_jwt_public_key
}

resource "google_secret_manager_secret" "zeno_auth_sendgrid_api_key" {
  secret_id = "zeno-auth-sendgrid-api-key"
  project   = var.project_id
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "zeno_auth_sendgrid_api_key" {
  secret      = google_secret_manager_secret.zeno_auth_sendgrid_api_key.id
  secret_data = var.zeno_auth_sendgrid_api_key
}

# --- Секреты для zeno-billing ---
resource "google_secret_manager_secret" "stripe_secret_key" {
  secret_id = "stripe-secret-key"
  project   = var.project_id
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "stripe_secret_key" {
  secret      = google_secret_manager_secret.stripe_secret_key.id
  secret_data = var.stripe_secret_key
}

resource "google_secret_manager_secret" "stripe_webhook_secret" {
  secret_id = "stripe-webhook-secret"
  project   = var.project_id
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "stripe_webhook_secret" {
  secret      = google_secret_manager_secret.stripe_webhook_secret.id
  secret_data = var.stripe_webhook_secret
}
