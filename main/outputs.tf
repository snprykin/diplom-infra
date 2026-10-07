output "cluster_id" {
  value       = yandex_kubernetes_cluster.diplom-k8s.id
  description = "K8s cluster ID"
}

output "cluster_name" {
  value       = yandex_kubernetes_cluster.diplom-k8s.name
  description = "K8s cluster name"
}

output "cluster_endpoint" {
  value       = yandex_kubernetes_cluster.diplom-k8s.master[0].external_v4_endpoint
  description = "K8s API endpoint"
}

output "vpc_id" {
  value       = yandex_vpc_network.diplom-network.id
  description = "VPC network ID"
}

output "registry_id" {
  value       = yandex_container_registry.diplom-registry.id
  description = "Container Registry ID"
}

output "registry_name" {
  value       = yandex_container_registry.diplom-registry.name
  description = "Container Registry name"
}
