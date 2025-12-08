# ------------------------------------------------------------------------------
# Cloud Run Services
# ------------------------------------------------------------------------------

# --- zeno-auth ---
resource "google_cloud_run_v2_service" "zeno_auth" {
  name     = "zeno-auth"
  location = var.region
  project  = var.project_id

  template {
    service_account = google_service_account.zeno_auth.email
    timeout         = "300s"

    scaling {
      min_instance_count = 0 # Экономия: масштабирование до нуля
      max_instance_count = 2 # Ограничение для dev
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/zeno-services/zeno-auth:latest"
      ports { container_port = 8080 }

      env {
        name  = "DB_USER"
        value = google_sql_user.main_user.name
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.zeno_auth_db.name
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "JWT_PRIVATE_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.zeno_auth_jwt_private_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "JWT_PUBLIC_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.zeno_auth_jwt_public_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "SENDGRID_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.zeno_auth_sendgrid_api_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = "https://zeno-console-899549698924.europe-west3.run.app"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [google_sql_database_instance.main.connection_name] }
    }
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# --- zeno-billing ---
resource "google_cloud_run_v2_service" "zeno_billing" {
  name     = "zeno-billing"
  location = var.region
  project  = var.project_id

  template {
    service_account = google_service_account.zeno_billing.email
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
        value = google_sql_user.main_user.name
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.zeno_billing_db.name
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "STRIPE_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.stripe_secret_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "STRIPE_WEBHOOK_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.stripe_webhook_secret.secret_id
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
        value = google_pubsub_topic.zeno_usage_topic.name
      }
      env {
        name  = "APP_AUTH_SERVICE_URL"
        value = google_cloud_run_v2_service.zeno_auth.uri
      }
      env {
        name  = "APP_ALLOWED_ORIGINS"
        value = "https://zeno-console-899549698924.europe-west3.run.app"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [google_sql_database_instance.main.connection_name] }
    }
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# --- zeno-roles ---
resource "google_cloud_run_v2_service" "zeno_roles" {
  name     = "zeno-roles"
  location = var.region
  project  = var.project_id

  template {
    service_account = google_service_account.zeno_roles.email
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
        value = "postgres://${google_sql_user.main_user.name}@/${google_sql_database.zeno_roles_db.name}?host=/cloudsql/${google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "ZENO_ROLES_DATABASE_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "ZENO_ROLES_REDIS_URL"
        value = "redis://${google_redis_instance.main.host}:${google_redis_instance.main.port}"
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
      cloud_sql_instance { instances = [google_sql_database_instance.main.connection_name] }
    }
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# --- zeno-usage ---
resource "google_cloud_run_v2_service" "zeno_usage" {
  name     = "zeno-usage"
  location = var.region
  project  = var.project_id

  template {
    service_account = google_service_account.zeno_usage.email
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
        value = google_sql_user.main_user.name
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.zeno_usage_db.name
      }
      env {
        name  = "DB_HOST"
        value = "/cloudsql/${google_sql_database_instance.main.connection_name}"
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
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
        value = google_pubsub_subscription.zeno_usage_sub.name
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
      cloud_sql_instance { instances = [google_sql_database_instance.main.connection_name] }
    }
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# --- zeno-documents ---
resource "google_cloud_run_v2_service" "zeno_documents" {
  name     = "zeno-documents"
  location = var.region
  project  = var.project_id

  template {
    service_account = google_service_account.zeno_documents.email
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
# Зависимости сервисов (VPC Connector, Pub/Sub, IAM)
# ------------------------------------------------------------------------------
resource "google_vpc_access_connector" "main" {
  name          = "cloud-run-connector"
  region        = var.region
  project       = var.project_id
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
}

resource "google_pubsub_topic" "zeno_usage_topic" {
  name    = "zeno-usage-events"
  project = var.project_id
}

resource "google_pubsub_subscription" "zeno_usage_sub" {
  name    = "zeno-usage-sub"
  topic   = google_pubsub_topic.zeno_usage_topic.name
  project = var.project_id

  push_config {
    push_endpoint = "" # Используем pull-подписку
  }
  ack_deadline_seconds = 20
}

resource "google_pubsub_subscription_iam_member" "zeno_usage_subscriber" {
  project      = var.project_id
  subscription = google_pubsub_subscription.zeno_usage_sub.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:zeno-usage-sa@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_pubsub_topic_iam_member" "zeno_billing_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.zeno_usage_topic.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:zeno-billing-sa@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_pubsub_topic_iam_member" "zeno_billing_viewer" {
  project = var.project_id
  topic   = google_pubsub_topic.zeno_usage_topic.name
  role    = "roles/pubsub.viewer"
  member  = "serviceAccount:zeno-billing-sa@${var.project_id}.iam.gserviceaccount.com"
}

# Allow zeno-billing to invoke zeno-auth
resource "google_cloud_run_service_iam_member" "zeno_billing_invoke_auth" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.zeno_auth.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.zeno_billing.email}"
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
