terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.130.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
  }
  required_version = ">= 1.0"
}

variable "service_account_key_file" {
  description = "Path to Yandex Cloud service account key JSON file"
  type        = string
  default     = "/home/user/.authorized_key.json"
}

provider "yandex" {
  zone                     = "ru-central1-a"
  folder_id                = "b1g9p43hspfbf3eqck03"
  service_account_key_file = var.service_account_key_file
}

