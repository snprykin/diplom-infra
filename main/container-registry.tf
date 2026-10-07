# ============================================
# Container Registry для Docker-образов
# ============================================

resource "yandex_container_registry" "diplom-registry" {
  name      = "diplom-registry"
  folder_id = "b1g9p43hspfbf3eqck03"
}

resource "yandex_container_registry_iam_binding" "pullers" {
  registry_id = yandex_container_registry.diplom-registry.id
  role        = "container-registry.images.puller"

  members = [
    "serviceAccount:ajee9kgs11q78t7sm6ai",
  ]
}
