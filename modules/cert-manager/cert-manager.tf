terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.15.1"

  values = [
    file("${path.module}/values-cert-manager.yaml")
  ]

  depends_on = [
    kubernetes_namespace_v1.cert_manager
  ]
}

resource "null_resource" "cluster_issuer" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/cluster-issuer-production.yaml"
  }

  depends_on = [
    helm_release.cert_manager
  ]
}