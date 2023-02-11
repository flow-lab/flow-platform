# ----------------------------------------------------------------------------------------------------------------------
#  Ingress
# ----------------------------------------------------------------------------------------------------------------------

resource "kubernetes_ingress" "ingress" {
  count = var.domain == "" ? 0 : 1
  metadata {
    name = "${var.prefix}-ingress"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = var.ip_name
      "ingress.gcp.kubernetes.io/pre-shared-cert"   = var.cert_name
      "kubernetes.io/ingress.allow-http"            = false
    }
  }

  spec {
    rule {
      host = "api.${var.domain}"
      http {
        path {
          backend {
            service_name = "auxospore"
            service_port = 80
          }
          path = "/ml/*"
        }
      }
    }
  }

}