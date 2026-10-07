# ============================================
# VPC и подсети в 3 зонах доступности
# ============================================

resource "yandex_vpc_network" "diplom-network" {
  name        = "diplom-network"
  description = "VPC for diploma project"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "diplom-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom-network.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "diplom-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom-network.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}

resource "yandex_vpc_subnet" "subnet-d" {
  name           = "diplom-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.diplom-network.id
  v4_cidr_blocks = ["10.10.3.0/24"]
}

# ============================================
# Security Group для K8s
# ============================================

resource "yandex_vpc_security_group" "k8s-sg" {
  name       = "diplom-k8s-sg"
  network_id = yandex_vpc_network.diplom-network.id

  # Исходящий трафик — всё разрешено
  egress {
    protocol       = "ANY"
    description    = "Allow all egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Внутренний трафик между нодами K8s
    # Трафик между нодами
  ingress {
    protocol       = "ANY"
    description    = "Node-to-node communication"
    v4_cidr_blocks = ["10.10.0.0/16"]
  }

  # Трафик между подами (Pod CIDR)
  ingress {
    protocol       = "ANY"
    description    = "Pod-to-pod communication"
    v4_cidr_blocks = ["10.112.0.0/16"]
  }

  # Трафик к сервисам (Service CIDR)
  ingress {
    protocol       = "ANY"
    description    = "Service traffic"
    v4_cidr_blocks = ["10.96.0.0/16"]
  }

  #ingress {
  #  protocol       = "ANY"
  #  description    = "Intra-cluster communication"
  #  v4_cidr_blocks = ["10.10.0.0/16"]
  #}

  # SSH
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP для Grafana и приложения
  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # K8s API
  ingress {
    protocol       = "TCP"
    description    = "K8s API"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # ПРАВИЛО 1: Healthchecks от балансировщика (заменяет старый блок с CIDR)
  ingress {
    protocol          = "TCP"
    description       = "Allow health checks from load balancer"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  # ПРАВИЛО 2: Служебный трафик между мастером и узлами (ДОБАВЛЕНО)
  ingress {
    protocol          = "ANY"
    description       = "Allow traffic between master and nodes"
    predefined_target = "self_security_group"
  }

  # ПРАВИЛО 3: ICMP для проверки узлов (ДОБАВЛЕНО)
  ingress {
    protocol       = "ICMP"
    description    = "Allow ICMP checks from internal subnets"
    v4_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  }

  # NodePort для доступа к сервисам через NLB (Ingress)
  ingress {
    protocol       = "TCP"
    description    = "NodePort for NLB and Ingress"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
