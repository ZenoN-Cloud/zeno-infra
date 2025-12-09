# ------------------------------------------------------------------------------
# Cloud Run Services
# ------------------------------------------------------------------------------

# --- zeno-auth ---
resource "google_cloud_run_v2_service" "zeno_auth" {
  name     = "zeno-auth"
  location = var.region
  project  = var.project_id

  template {
    service_account = data.google_service_account.zeno_auth.email
    timeout         = "300s"

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/zeno-services/zeno-auth:latest"
      ports { container_port = 8080 }

      env {
        name  = "DB_USER"
        value = local.db_user
      }
      env {
        name  = "DB_NAME"
        value = data.google_sql_database.zeno_auth_db.name
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${data.google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "JWT_PRIVATE_KEY"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.zeno_auth_jwt_private_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "JWT_PUBLIC_KEY"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.zeno_auth_jwt_public_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "SENDGRID_API_KEY"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.zeno_auth_sendgrid_api_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = "https://zeno-console-899549698924.europe-west3.run.app"
      }
      env {
        name  = "FRONTEND_BASE_URL"
        value = "https://zeno-console-899549698924.europe-west3.run.app"
      }
      env {
        name  = "ENV"
        value = "prod"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [data.google_sql_database_instance.main.connection_name] }
    }
  }
}

# --- zeno-billing ---
resource "google_cloud_run_v2_service" "zeno_billing" {
  name     = "zeno-billing"
  location = var.region
  project  = var.project_id

  template {
    service_account = data.google_service_account.zeno_billing.email
    timeout         = "300s"

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/zeno-services/zeno-billing:latest"
      ports { container_port = 8080 }
      env {
        name  = "DB_USER"
        value = local.db_user
      }
      env {
        name  = "DB_NAME"
        value = data.google_sql_database.zeno_billing_db.name
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${data.google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "STRIPE_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.stripe_secret_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "STRIPE_WEBHOOK_SECRET"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.stripe_webhook_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "PUBSUB_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "PUBSUB_TOPIC_BILLING_EVENTS"
        value = data.google_pubsub_topic.zeno_usage_topic.name
      }
      env {
        name  = "APP_AUTH_SERVICE_URL"
        value = google_cloud_run_v2_service.zeno_auth.uri
      }
      env {
        name  = "APP_ALLOWED_ORIGINS"
        value = "https://zeno-console-899549698924.europe-west3.run.app"
      }
      env {
        name  = "APP_PORT"
        value = "8080"
      }
      env {
        name  = "APP_ENV"
        value = "prod"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [data.google_sql_database_instance.main.connection_name] }
    }
  }
}

# --- zeno-roles ---
resource "google_cloud_run_v2_service" "zeno_roles" {
  name     = "zeno-roles"
  location = var.region
  project  = var.project_id

  template {
    service_account = data.google_service_account.zeno_roles.email
    timeout         = "300s"

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/zeno-services/zeno-roles:latest"
      ports { container_port = 8080 }
      env {
        name  = "ZENO_ROLES_DATABASE_URL"
        value = "postgres://${local.db_user}@/${data.google_sql_database.zeno_roles_db.name}?host=/cloudsql/${data.google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "ZENO_ROLES_DATABASE_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "ZENO_ROLES_GRPC_PORT"
        value = "8083"
      }
      env {
        name  = "ZENO_ROLES_HTTP_PORT"
        value = "8080"
      }
      env {
        name  = "ZENO_ROLES_CORS_ALLOWED_ORIGINS"
        value = "https://zeno-console-899549698924.europe-west3.run.app"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [data.google_sql_database_instance.main.connection_name] }
    }
  }
}

# --- zeno-usage ---
resource "google_cloud_run_v2_service" "zeno_usage" {
  name     = "zeno-usage"
  location = var.region
  project  = var.project_id

  template {
    service_account = data.google_service_account.zeno_usage.email
    timeout         = "300s"

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/zeno-services/zeno-usage:latest"
      ports { container_port = 8080 }
      env {
        name  = "DB_USER"
        value = local.db_user
      }
      env {
        name  = "DB_NAME"
        value = data.google_sql_database.zeno_usage_db.name
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${data.google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "PUBSUB_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "PUBSUB_SUBSCRIPTION"
        value = data.google_pubsub_subscription.zeno_usage_sub.name
      }
      env {
        name  = "GRPC_PORT"
        value = "8085"
      }
      env {
        name  = "HTTP_PORT"
        value = "8080"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [data.google_sql_database_instance.main.connection_name] }
    }
  }
}

# --- zeno-documents ---
resource "google_cloud_run_v2_service" "zeno_documents" {
  name     = "zeno-documents"
  location = var.region
  project  = var.project_id

  template {
    service_account = data.google_service_account.zeno_documents.email
    timeout         = "300s"

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/zeno-services/zeno-documents:latest"
      ports { container_port = 8089 }
    }
  }
}

# ------------------------------------------------------------------------------
# Зависимости сервисов (Pub/Sub, IAM)
# ------------------------------------------------------------------------------

# Импортируем существующие Pub/Sub ресурсы
data "google_pubsub_topic" "zeno_usage_topic" {
  name    = "zeno-usage-events"
  project = var.project_id
}

data "google_pubsub_subscription" "zeno_usage_sub" {
  name    = "zeno-usage-sub"
  project = var.project_id
}

# Allow zeno-billing to invoke zeno-auth
resource "google_cloud_run_service_iam_member" "zeno_billing_invoke_auth" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.zeno_auth.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${data.google_service_account.zeno_billing.email}"
}

# Allow public access to zeno-auth (for registration/login)
resource "google_cloud_run_service_iam_member" "zeno_auth_public" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.zeno_auth.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Allow public access to zeno-billing (for webhooks)
resource "google_cloud_run_service_iam_member" "zeno_billing_public" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.zeno_billing.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Allow public access to zeno-roles
resource "google_cloud_run_service_iam_member" "zeno_roles_public" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.zeno_roles.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
