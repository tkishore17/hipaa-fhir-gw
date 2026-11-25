###########################################################################
# KMS Keyring Workload Identity setup
###########################################################################

resource "kubernetes_service_account" "k8s_hsm_sa" {
  metadata {
    name      = "${local.name_prefix}-hsm-sa"
    namespace = "default"

    annotations = {
      "iam.gke.io/gcp-service-account" = data.google_service_account.hsm_access_sa.email
    }
  }
}

resource "google_service_account_iam_member" "k8s_kek_sa" {
  service_account_id = data.google_service_account.hsm_access_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${data.google_project.current.project_id}.svc.id.goog/subject/ns/default/sa/${local.name_prefix}-hsm-sa"
}

# Kubernetes Service Account for accessing GCS bucket
resource "kubernetes_service_account" "k8s_gcs_sa" {
  metadata {
    name      = "${local.name_prefix}-gcs-sa"
    namespace = "default"

    annotations = {
      "iam.gke.io/gcp-service-account" = data.google_service_account.gcs_sa.email
    }
  }
}
###################################################################################
# 1.) Workload App Identity service account for GCS bucket access
###################################################################################
resource "google_service_account_iam_member" "app_gcs_access_binding" {
  service_account_id = data.google_service_account.gcs_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${data.google_project.current.project_id}.svc.id.goog/subject/ns/default/sa/${local.name_prefix}-gcs-sa"
}

