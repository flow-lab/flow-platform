# ----------------------------------------------------------------------------------------------------------------------
#  Redis
# ----------------------------------------------------------------------------------------------------------------------
resource "google_redis_instance" "cache" {
  name           = "cache-0"
  memory_size_gb = 1

  region = var.region

  authorized_network = var.authorized_network
}

# ----------------------------------------------------------------------------------------------------------------------
#  Redis Kubernetes Config
# ----------------------------------------------------------------------------------------------------------------------
# TODO [grokrz]: fix this, kubernetes provider is not working
#resource "kubernetes_config_map" "redis_config" {
#  metadata {
#    name = "${google_redis_instance.cache.name}-config"
#  }
#
#  data = {
#    name = "projects/${google_redis_instance.cache.project}/locations/${google_redis_instance.cache.region}/instances/${google_redis_instance.cache.name}"
#  }
#}