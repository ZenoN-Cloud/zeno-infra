# ------------------------------------------------------------------------------
# Cloud SQL for PostgreSQL
# ------------------------------------------------------------------------------

resource "google_sql_database_instance" "main" {
  name             = "zeno-db-instance-dev" # Переименовано для ясности
  database_version = "POSTGRES_14"
  region           = var.region
  project          = var.project_id

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-g1-small" # Самый дешевый вариант

    # ZONAL - дешевле, чем REGIONAL. Идеально для разработки.
    availability_type = "ZONAL"

    backup_configuration {
      enabled = false # Отключаем бэкапы для максимальной экономии в dev
    }

    ip_configuration {
      ipv4_enabled    = false # Отключаем публичный IP для безопасности
      private_network = google_compute_network.vpc.id
    }

    # Важно для Cloud Run
    connector_enforcement = "NOT_REQUIRED"
  }

  # Отключаем защиту от удаления для dev окружения
  deletion_protection = false
}

# База данных для сервиса zeno-billing
resource "google_sql_database" "zeno_billing_db" {
  name     = "zeno_billing"
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# База данных для сервиса zeno-auth
resource "google_sql_database" "zeno_auth_db" {
  name     = "zeno_auth"
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# ... добавь сюда другие базы данных по аналогии

# Пользователь для доступа к базам данных
resource "google_sql_user" "main_user" {
  name     = "zeno_user"
  instance = google_sql_database_instance.main.name
  password = var.db_password
  project  = var.project_id
}

# ------------------------------------------------------------------------------
# Сеть для базы данных
# ------------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  name                    = "zeno-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "main_subnet" {
  name          = "zeno-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-for-sql"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}
