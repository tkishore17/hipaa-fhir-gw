data "google_project" "current" {
  project_id = var.project_id
}
data "google_client_config" "client_config" {}
data "google_container_cluster" "target_cluster" {
  name     = var.gke_cluster_name
  location = var.gke_cluster_location
  project  = data.google_project.current.project_id
}
data "google_service_account" "hsm_access_sa" {
  project    = data.google_project.current.project_id
  account_id = "${var.environment}-${var.gke_cluster_region}-hsm-access-id"
}
data "google_service_account" "gcs_sa" {
  project    = data.google_project.current.project_id
  account_id = "${local.name_prefix}-sa-storage"
}
data "google_kms_crypto_key" "kms_key" {
  name     = "${local.name_prefix}-kms-key"
  key_ring = "projects/${data.google_project.current.project_id}/locations/${var.gke_cluster_region}/keyRings/${local.name_prefix}-kms-keyring"
}


data "kubernetes_resource" "backend_cluster_issuer" {
  api_version = "cert-manager.io/v1"
  kind        = "ClusterIssuer"
  metadata {
    name = local.backend_issuer_name
  }
}
