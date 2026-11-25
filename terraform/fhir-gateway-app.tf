resource "kubernetes_service_account" "hipaa_app" {
  metadata {
    name      = local.hipaa_app_name
    namespace = local.app_namespace
  }
  automount_service_account_token = false
}

resource "kubernetes_deployment" "hipaa_app" {
  metadata {
    name      = local.hipaa_app_name
    namespace = local.app_namespace
    labels    = { app = local.hipaa_app_name }
  }

  spec {
    replicas = 2
    selector {
      match_labels = { app = local.hipaa_app_name }
    }
    template {
      metadata {
        labels = { app = local.hipaa_app_name }
      }
      spec {
        service_account_name            = kubernetes_service_account.hipaa_app.metadata[0].name
        automount_service_account_token = false

        container {
          name  = "hipaa-app"
          image = "us-central1-docker.pkg.dev/project-faa78ead-9e60-4a41-8f5/image-registry/fhir-gateway:latest"

          port {
            name           = "https"
            container_port = 8443
          }
          port {
            name           = "health"
            container_port = 8081
          }

          resources {
            limits   = { cpu = "200m", memory = "256Mi" }
            requests = { cpu = "100m", memory = "128Mi" }
          }
          security_context {
            run_as_non_root            = true
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = "health"
            }
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "health"
            }
            initial_delay_seconds = 8
            period_seconds        = 5
          }
          volume_mount {
            name       = "tls"
            mount_path = "/etc/ssl/certs/app"
            read_only  = true
          }
          volume_mount {
            name       = "whitelist"
            mount_path = "/etc/fhir-gateway"
            read_only  = true
          }
        }
        volume {
          name = "tls"
          secret { secret_name = local.hipaa_tls_secret }
        }
        volume {
          name = "whitelist"
          config_map {
            name         = kubernetes_config_map.fhir_gateway_whitelist.metadata[0].name
            default_mode = "0444"
          }
        }
      }
    }
  }
  depends_on = [kubectl_manifest.hipaa_backend_cert]
}

resource "kubernetes_service" "hippa_service" {
  metadata {
    name      = local.hipaa_svc_name
    namespace = local.app_namespace
    labels    = { app = local.hipaa_app_name }
  }

  spec {
    type     = "ClusterIP"
    selector = { app = local.hipaa_app_name }

    port {
      name        = "https"
      port        = 8443
      target_port = "https"
      protocol    = "TCP"
    }
  }
}
