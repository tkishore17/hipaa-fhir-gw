variable "environment" {
  type = string
}
variable "project_id" {
  type = string
}
variable "gke_cluster_name" {
  type = string
}
variable "gke_cluster_region" {
  type = string
}
variable "gke_cluster_location" {
  type = string
}

variable "client_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9a-z]([-a-z0-9]*[a-z0-9])?$", var.client_id))
    error_message = "client_id must be lowercase letters, digits, and hyphens"
  }
  description = "Id used to distinguish external Hipaa Clients"
}

variable "allowed_destinations" {
  type        = list(string)
  description = "List of allowed destinations for FHIR packet"
}
