locals {
  # Infra specific
  edge_namespace      = "edge-gateway"
  gateway_name        = "edge"
  backend_issuer_name = "backend-ca-issuer"
  base_domain         = "ekistan.duckdns.org"

  # App specific
  external_trust_domain = "external.mesh.internal"
  name_prefix           = "${var.environment}-${var.gke_cluster_region}"
  app_namespace         = "hipaa" # dedicated namespace, not "default"
  hipaa_app_name        = "hipaa-app"
  hipaa_svc_name        = "hipaa-svc"                # must match the real Service name
  api_hostname          = "api.${local.base_domain}" # covered by the wildcard cert
  hipaa_route_name      = "hipaa-route"
  hipaa_cert_name       = "hipaa-svc-cert"
  hipaa_tls_secret      = "hipaa-svc-tls"
  hipaa_svc_fqdn        = "${local.hipaa_svc_name}.${local.app_namespace}.svc.cluster.local"
}
