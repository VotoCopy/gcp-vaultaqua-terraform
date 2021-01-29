data "local_file" "vault_ca" {
  filename = var.vault_ca
}

data "local_file" "vault_crt" {
  filename = var.vault_crt
}

data "local_file" "vault_key" {
  filename = var.vault_key
}

data "local_file" "gcp_creds" {
  filename = var.gcp_creds
}

resource "kubernetes_namespace" "vault" {
  metadata {
    annotations = {
      name = "hc-vault"
    }
    labels = {
      name = "hc-vault"
    }
    name = "vault"
  }
}
resource "kubernetes_namespace" "aqua" {
  metadata {
    annotations = {
      name = "aqua"
    }
    labels = {
      name = "aqua"
    }
    name = "aqua"
  }
}
resource "kubernetes_secret" "vault-tls" {
  metadata {
    name      = "vault-tls"
    namespace = "vault"
  }

  data = {
    "vault_ca"  = data.local_file.vault_ca.content
    "vault_crt" = data.local_file.vault_crt.content
    "vault_key" = data.local_file.vault_key.content
  }

  type = "Opaque"
}

resource "kubernetes_secret" "kms-creds" {
  metadata {
    name      = "kms-creds"
    namespace = "vault"
  }

  data = {
    "credentials.json" = data.local_file.gcp_creds.content
  }

  type = "Opaque"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "vault" {
  name  = "vault"
  chart = "hashicorp/vault"
  namespace = "vault"
  values = [
    "${file("values-raft.yaml")}"
  ]
}

resource "helm_release" "aqua" {
  name  = "aqua-server"
  chart = "aqua-helm/server"
  namespace = "aqua"
  set {
    name = "imageCredentials.username"
    value = data.aquasec_download_user.content
  }
  set {
    name = "imageCredentials.password"
    value = data.aquasec_download_pass.content
  }
}
resource "null_resource" "cleanup_pvc0" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "kubectl delete pvc data-vault-0"
  }
}
resource "null_resource" "cleanup_pvc1" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "kubectl delete pvc data-vault-1"
  }
}
resource "null_resource" "cleanup_pvc2" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "kubectl delete pvc data-vault-2"
  }
}
resource "null_resource" "cleanup_vault_helm" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "helm uninstall vault"
  }
}
resource "null_resource" "cleanup_aqua_helm" {
  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "helm uninstall aqua-server"
  }
}
