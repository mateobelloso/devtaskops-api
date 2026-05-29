terraform {
  required_version = ">= 1.5.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
  }
}

provider "null" {}

resource "null_resource" "docker_compose" {
  triggers = {
    compose_file = filesha256("${path.module}/docker-compose.yml")
  }

  provisioner "local-exec" {
    command = "docker compose -f ${path.module}/docker-compose.yml up -d"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "docker compose -f ${path.module}/docker-compose.yml down"
  }
}

output "docker_compose_status" {
  value = "Docker Compose aplicó la arquitectura local en modo detached. Usa 'docker compose ps' para comprobar los servicios."
}
