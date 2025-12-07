variable "name" {
  description = "The name of the service."
  type        = string
}

variable "kubernetes_namespace" {
  description = "The Kubernetes namespace to deploy the service into."
  type        = string
  default     = "default"
}

variable "image" {
  description = "The Docker image to deploy."
  type        = string
}

variable "container_port" {
  description = "The port the container listens on."
  type        = number
}

variable "replicas" {
  description = "The number of replicas (pods) to run."
  type        = number
  default     = 2
}

variable "env_vars" {
  description = "A map of environment variables to set in the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "A map of secret names to environment variable names."
  type        = map(string)
  default     = {}
}

variable "gcp_service_account_email" {
  description = "The email of the GCP Service Account to associate with the Kubernetes service account."
  type        = string
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}
