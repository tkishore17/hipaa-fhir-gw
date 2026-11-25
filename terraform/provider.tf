terraform {
  required_version = ">=1.2"
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31.0" # Stable v2 release branch
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.45.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.target_cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.target_cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.client_config.access_token
}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.target_cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.target_cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.client_config.access_token
}
