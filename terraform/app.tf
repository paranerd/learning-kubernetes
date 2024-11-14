data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

variable "namespace" {
  type = string
  description = "Namespace"
  default = "default"
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "hello_1" {
  metadata {
    name = "hello-1"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = "hello-1"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-1"
        }
      }

      spec {
        container {
          image = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0"
          name  = "hello-app-container-1"

          port {
            container_port = 8080
            name           = "hello-app-svc"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "hello_2" {
  metadata {
    name = "hello-2"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = "hello-2"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-2"
        }
      }

      spec {
        container {
          image = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:2.0"
          name  = "hello-app-container-2"

          port {
            container_port = 8080
            name           = "hello-app-svc"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "hello_1" {
  metadata {
    name = "hello-1"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.hello_1.spec[0].selector[0].match_labels.app
    }

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.hello_1.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "NodePort"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

resource "kubernetes_service_v1" "hello_2" {
  metadata {
    name = "hello-2"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.hello_2.spec[0].selector[0].match_labels.app
    }

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.hello_2.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "NodePort"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "hello-ingress"
    namespace = var.namespace
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service_v1.hello_1.metadata[0].name
        port {
          number = kubernetes_service_v1.hello_1.spec[0].port[0].port
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.hello_1.metadata[0].name
              port {
                number = kubernetes_service_v1.hello_1.spec[0].port[0].port
              }
            }
          }

          path = "/v1"
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.hello_2.metadata[0].name
              port {
                number = kubernetes_service_v1.hello_2.spec[0].port[0].port
              }
            }
          }

          path = "/v2"
        }
      }
    }
  }
}

# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.primary]

  destroy_duration = "180s"
}