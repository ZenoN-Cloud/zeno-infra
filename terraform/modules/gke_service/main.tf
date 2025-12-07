# Kubernetes Service Account
resource "kubernetes_service_account" "main" {
  metadata {
    name      = var.name
    namespace = var.kubernetes_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = var.gcp_service_account_email
    }
  }
}

# Kubernetes Deployment
resource "kubernetes_deployment" "main" {
  metadata {
    name      = var.name
    namespace = var.kubernetes_namespace
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        service_account_name = kubernetes_service_account.main.metadata.0.name

        container {
          name  = var.name
          image = var.image

          ports {
            container_port = var.container_port
          }

          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = var.secrets
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = env.value
                  key  = env.key
                }
              }
            }
          }

          # Readiness and Liveness probes should be configured here
          # For now, leaving them simple
          readiness_probe {
            http_get {
              path = "/healthz" # Assuming a standard health check endpoint
              port = var.container_port
            }
            initial_delay_seconds = 5
            period_seconds      = 10
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = var.container_port
            }
            initial_delay_seconds = 15
            period_seconds      = 20
          }
        }
      }
    }
  }
}

# Kubernetes Service
resource "kubernetes_service" "main" {
  metadata {
    name      = var.name
    namespace = var.kubernetes_namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.main.spec.0.template.0.metadata.0.labels.app
    }

    ports {
      port        = 80
      target_port = var.container_port
    }

    type = "ClusterIP" # Expose the service only inside the cluster
  }
}
