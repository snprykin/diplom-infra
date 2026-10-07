terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.130.0"
    }
  }
  required_version = ">= 1.0"
}

provider "yandex" {
  zone                     = "ru-central1-a"
  folder_id                = "b1g9p43hspfbf3eqck03"
  service_account_key_file = "/home/user/.authorized_key.json"
}

# ============================================
# 1. Сервисный аккаунт для инфраструктуры
# ============================================

resource "yandex_iam_service_account" "diplom-sa" {
  name        = "diplom-sa"
  description = "Service account for diploma infrastructure"
}

# Роли, необходимые для управления инфраструктурой
locals {
  sa_roles = [
    "vpc.admin",
    "compute.admin",
    "storage.admin",
    "k8s.admin",
    "iam.serviceAccounts.user",
    "container-registry.admin",
    "logging.writer",
    "monitoring.editor",
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "sa-roles" {
  for_each = toset(local.sa_roles)

  folder_id = "b1g9p43hspfbf3eqck03"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.diplom-sa.id}"
}

# ============================================
# 2. Статический ключ для S3 backend
# ============================================

resource "yandex_iam_service_account_static_access_key" "sa-key" {
  service_account_id = yandex_iam_service_account.diplom-sa.id
  description        = "Static key for S3 backend"
}

# ============================================
# 3. Бакет для Terraform backend
# ============================================

resource "yandex_storage_bucket" "tfstate" {
  bucket    = "snprykin-diplom-tfstate"
  folder_id = "b1g9p43hspfbf3eqck03"
 # acl       = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
