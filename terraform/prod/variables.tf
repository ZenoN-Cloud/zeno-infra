variable "project_id" {
  description = "The GCP project ID to deploy to."
  type        = string
  default     = "zeno-cy-dev-001"
}

variable "region" {
  description = "The GCP region to deploy to."
  type        = string
  default     = "europe-west3"
}

variable "db_password" {
  description = "The password for the Cloud SQL database user."
  type        = string
  sensitive   = true
}

variable "zeno_auth_jwt_private_key" {
  description = "The private key for signing JWTs in zeno-auth (RSA format)."
  type        = string
  sensitive   = true
}

variable "zeno_auth_jwt_public_key" {
  description = "The public key for verifying JWTs in zeno-auth (RSA format)."
  type        = string
  sensitive   = true
}

variable "zeno_auth_sendgrid_api_key" {
  description = "The SendGrid API key for zeno-auth."
  type        = string
  sensitive   = true
}

variable "stripe_secret_key" {
  description = "The Stripe secret key for zeno-billing."
  type        = string
  sensitive   = true
}

variable "stripe_webhook_secret" {
  description = "The Stripe webhook secret for zeno-billing."
  type        = string
  sensitive   = true
}
