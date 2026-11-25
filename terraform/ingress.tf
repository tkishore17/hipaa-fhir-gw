# Application's Ingree Gateway traffic routing and Policy defs

# Traffic Routing rules in Ingress Gateway for HIPAA application pkt
resource "kubectl_manifest" "hipaa_route" {
  yaml_body = yamlencode({
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"      = local.hipaa_route_name
      "namespace" = local.app_namespace
    }
    "spec" = {
      "parentRefs" = [
        {
          "group"       = "gateway.networking.k8s.io"
          "kind"        = "Gateway"
          "name"        = local.gateway_name
          "namespace"   = local.edge_namespace
          "sectionName" = "https-l7-listener"
        }
      ]
      hostnames = [local.api_hostname]
      "rules" = [
        {
          "matches" = [
            { "path" = { "type" = "PathPrefix", "value" = "/api/v1/secure-fhir" } },
            { "path" = { "type" = "PathPrefix", "value" = "/api/v1/phi" } },
          ]
          "backendRefs" = [
            {
              "name" = local.hipaa_svc_name
              "port" = 8443
            }
          ]
        }
      ]
    }
  })
}

resource "kubectl_manifest" "hipaa_backend_policy" {
  yaml_body = yamlencode({
    apiVersion = "gateway.envoyproxy.io/v1alpha1"
    kind       = "BackendTrafficPolicy"

    metadata = {
      name      = "hipaa-backend-policy"
      namespace = local.app_namespace
    }

    spec = {
      targetRefs = [{
        group = "gateway.networking.k8s.io"
        kind  = "HTTPRoute"
        name  = local.hipaa_route_name
      }]
      "loadBalancer" = { type = "RoundRobin" }
    }
  })
  depends_on = [kubectl_manifest.hipaa_route]
}

resource "kubectl_manifest" "hipaa_backend_cert" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = local.hipaa_cert_name
      namespace = local.app_namespace
    }

    spec = {
      secretName = local.hipaa_tls_secret
      usages     = ["digital signature", "key encipherment", "server auth"]

      dnsNames = [
        local.hipaa_svc_name,
        "${local.hipaa_svc_name}.${local.app_namespace}",
        "${local.hipaa_svc_name}.${local.app_namespace}.svc",
        local.hipaa_svc_fqdn
      ]
      issuerRef = {
        name  = local.backend_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  })
}

resource "kubectl_manifest" "hipaa_backend_tls_policy" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1alpha3"
    kind       = "BackendTLSPolicy"

    metadata = {
      name      = "hipaa-backend-tls-policy"
      namespace = local.app_namespace
    }

    spec = {
      targetRefs = [
        {
          group = ""
          kind  = "Service"
          name  = local.hipaa_svc_name
        }
      ]
      validation = {
        hostname = local.hipaa_svc_fqdn
        caCertificateRefs = [
          {
            group = ""
            kind  = "Secret"
            name  = local.hipaa_tls_secret
          }
        ]
      }
    }
  })
  depends_on = [kubectl_manifest.hipaa_backend_cert]
}
