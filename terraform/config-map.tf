resource "kubernetes_config_map" "fhir_gateway_whitelist" {
  metadata {
    name      = "fhir-app-dst-whitelist"
    namespace = local.app_namespace
    labels    = { app = local.hipaa_app_name }
  }

  data = {
    "allowed-destinations.txt" = join("\n", var.allowed_destinations)
  }
}
