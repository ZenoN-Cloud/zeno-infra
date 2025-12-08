# ------------------------------------------------------------------------------
# Service Accounts & IAM
# ------------------------------------------------------------------------------

# Service Account для zeno-auth
resource "google_service_account" "zeno_auth" {
  account_id   = "zeno-auth-sa"
  display_name = "Zeno Auth Service Account"
  project      = var.project_id
}

# Service Account для zeno-billing
resource "google_service_account" "zeno_billing" {
  account_id   = "zeno-billing-sa"
  display_name = "Zeno Billing Service Account"
  project      = var.project_id
}

# Service Account для zeno-roles
resource "google_service_account" "zeno_roles" {
  account_id   = "zeno-roles-sa"
  display_name = "Zeno Roles Service Account"
  project      = var.project_id
}

# Service Account для zeno-usage
resource "google_service_account" "zeno_usage" {
  account_id   = "zeno-usage-sa"
  display_name = "Zeno Usage Service Account"
  project      = var.project_id
}

# Service Account для zeno-documents
resource "google_service_account" "zeno_documents" {
  account_id   = "zeno-documents-sa"
  display_name = "Zeno Documents Service Account"
  project      = var.project_id
}

# ------------------------------------------------------------------------------
# IAM Bindings для Secret Manager
# ------------------------------------------------------------------------------

# zeno-auth доступ к секретам
resource "google_secret_manager_secret_iam_member" "auth_db_password" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_auth.email}"
}

resource "google_secret_manager_secret_iam_member" "auth_jwt_private" {
  secret_id = google_secret_manager_secret.zeno_auth_jwt_private_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_auth.email}"
}

resource "google_secret_manager_secret_iam_member" "auth_jwt_public" {
  secret_id = google_secret_manager_secret.zeno_auth_jwt_public_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_auth.email}"
}

resource "google_secret_manager_secret_iam_member" "auth_sendgrid" {
  secret_id = google_secret_manager_secret.zeno_auth_sendgrid_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_auth.email}"
}

# zeno-billing доступ к секретам
resource "google_secret_manager_secret_iam_member" "billing_db_password" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_billing.email}"
}

resource "google_secret_manager_secret_iam_member" "billing_stripe_secret" {
  secret_id = google_secret_manager_secret.stripe_secret_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_billing.email}"
}

resource "google_secret_manager_secret_iam_member" "billing_stripe_webhook" {
  secret_id = google_secret_manager_secret.stripe_webhook_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_billing.email}"
}

# zeno-roles доступ к секретам
resource "google_secret_manager_secret_iam_member" "roles_db_password" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_roles.email}"
}

# zeno-usage доступ к секретам
resource "google_secret_manager_secret_iam_member" "usage_db_password" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.zeno_usage.email}"
}

# ------------------------------------------------------------------------------
# IAM Bindings для Cloud SQL
# ------------------------------------------------------------------------------

resource "google_project_iam_member" "auth_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.zeno_auth.email}"
}

resource "google_project_iam_member" "billing_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.zeno_billing.email}"
}

resource "google_project_iam_member" "roles_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.zeno_roles.email}"
}

resource "google_project_iam_member" "usage_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.zeno_usage.email}"
}
