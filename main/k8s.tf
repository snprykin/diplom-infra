# ============================================
# Managed Kubernetes — региональный мастер
# ============================================

resource "yandex_kubernetes_cluster" "diplom-k8s" {
  name        = "diplom-k8s"
  description = "Managed K8s cluster for diploma"
  network_id  = yandex_vpc_network.diplom-network.id

  master {
    regional {
      region = "ru-central1"
      location {
        zone      = "ru-central1-a"
        subnet_id = yandex_vpc_subnet.subnet-a.id
      }
      location {
        zone      = "ru-central1-b"
        subnet_id = yandex_vpc_subnet.subnet-b.id
      }
      location {
        zone      = "ru-central1-d"
        subnet_id = yandex_vpc_subnet.subnet-d.id
      }
    }

    version   = "1.32"
    public_ip = true

    security_group_ids = [yandex_vpc_security_group.k8s-sg.id]

    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = "ajee9kgs11q78t7sm6ai"
  node_service_account_id = "ajee9kgs11q78t7sm6ai"

  release_channel         = "REGULAR"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = yandex_kms_symmetric_key.k8s-key.id
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "30m"
  }
}

# ============================================
# KMS-ключ для шифрования секретов K8s
# ============================================

resource "yandex_kms_symmetric_key" "k8s-key" {
  name              = "diplom-k8s-key"
  description       = "KMS key for K8s secrets encryption"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

# ============================================
# Node Group с прерываемыми ВМ
# ============================================

resource "yandex_kubernetes_node_group" "diplom-workers" {
  cluster_id  = yandex_kubernetes_cluster.diplom-k8s.id
  name        = "diplom-workers"
  description = "Worker nodes for diploma"

  version = "1.32"

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      subnet_ids         = [yandex_vpc_subnet.subnet-a.id]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.k8s-sg.id]
    }

    metadata = {
      ssh-keys =  "user:${file(var.ssh_public_key_file)}"
    }
  }

  scale_policy {
    auto_scale {
      min     = 2
      max     = 4
      initial = 2
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }

  timeouts {
    create = "1h30m"
    update = "1h30m"
    delete = "30m"
  }
}
