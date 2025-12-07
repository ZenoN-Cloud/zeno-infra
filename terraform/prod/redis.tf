# ------------------------------------------------------------------------------
# Memorystore for Redis
# ------------------------------------------------------------------------------

resource "google_redis_instance" "main" {
  name           = "zeno-redis-dev" # Переименовано для ясности
  tier           = "BASIC" # BASIC для разработки, самый дешевый вариант
  memory_size_gb = 1

  # Указываем конкретную зону, а не регион
  location_id = "${var.region}-a"

  project        = var.project_id

  # Явно указываем зависимость от создания сетевого подключения
  depends_on = [google_service_networking_connection.private_vpc_connection]

  # Подключаем Redis к нашей VPC
  connect_mode              = "PRIVATE_SERVICE_ACCESS"
  authorized_network        = google_compute_network.vpc.id
  reserved_ip_range         = google_compute_global_address.redis_peering_range.name
}

# Выделяем диапазон IP для пиринга с Redis
resource "google_compute_global_address" "redis_peering_range" {
  name          = "redis-peering-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 24
  network       = google_compute_network.vpc.id
}
