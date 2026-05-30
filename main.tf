terraform {
  required_version = ">= 1.5.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.0"
    }
  }
}

provider "docker" {}

variable "environment" {
  type        = string
  description = "Environment to deploy: dev, staging, test, prod."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, test, prod"
  }
}

locals {
  network_name      = "devtaskops-${var.environment}"
  api_image_tag     = var.environment == "dev" ? "latest-dev" : "latest"
  api_image_name    = "devtaskops-api:${local.api_image_tag}"
  api_container_name      = "devtaskops-api-${var.environment}"
  postgres_container_name = "devtaskops-postgres-${var.environment}"
  prometheus_container_name = "devtaskops-prometheus-${var.environment}"
  grafana_container_name = "devtaskops-grafana-${var.environment}"
  api_host_port      = lookup({dev = 3000, staging = 3001, test = 3002, prod = 3003}, var.environment)
  postgres_host_port = lookup({dev = 5432, staging = 5433, test = 5434, prod = 5435}, var.environment)
  prometheus_host_port = lookup({dev = 9090, staging = 9091, test = 9092, prod = 9093}, var.environment)
  grafana_host_port  = lookup({dev = 3001, staging = 3004, test = 3005, prod = 3006}, var.environment)
  db_url = "postgresql://devops:devops@${local.postgres_container_name}:5432/devtaskops?schema=public"
  api_dockerfile = var.environment == "dev" ? "Dockerfile" : "Dockerfile.prod"
}

resource "docker_network" "app_network" {
  name = local.network_name
}

resource "docker_volume" "postgres_data" {
  name = "${local.network_name}-postgres-data"
}

resource "docker_image" "api" {
  name = local.api_image_name

  build {
    context    = path.module
    dockerfile = local.api_dockerfile
  }
}

resource "docker_container" "postgres" {
  name  = local.postgres_container_name
  image = "postgres:16"
  restart = "always"

  env = [
    "POSTGRES_DB=devtaskops",
    "POSTGRES_USER=devops",
    "POSTGRES_PASSWORD=devops",
    "PGDATA=/var/lib/postgresql/data/pgdata",
  ]

  ports {
    internal = 5432
    external = local.postgres_host_port
  }

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.app_network.name
  }
}

resource "docker_container" "api" {
  name  = local.api_container_name
  image = docker_image.api.image_id
  restart = "always"

  env = [
    "DATABASE_URL=${local.db_url}",
    "PORT=3000",
    "NODE_ENV=${var.environment == "dev" ? "development" : var.environment}",
    "APP_ENV=${var.environment}",
  ]

  ports {
    internal = 3000
    external = local.api_host_port
  }

  command = var.environment == "dev" ? ["npm", "run", "dev"] : ["npm", "start"]

  networks_advanced {
    name = docker_network.app_network.name
  }

  depends_on = [docker_container.postgres]
}

resource "docker_container" "prometheus" {
  name  = local.prometheus_container_name
  image = "prom/prometheus:latest"
  restart = "always"

  ports {
    internal = 9090
    external = local.prometheus_host_port
  }

  volumes {
    host_path      = abspath("${path.module}/monitoring/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  depends_on = [docker_container.api]
}

resource "docker_container" "grafana" {
  name  = local.grafana_container_name
  image = "grafana/grafana:latest"
  restart = "always"

  ports {
    internal = 3000
    external = local.grafana_host_port
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  depends_on = [docker_container.prometheus]
}

output "deployment_environment" {
  value = var.environment
}

output "docker_network" {
  value = docker_network.app_network.name
}

output "api_url" {
  value = "http://localhost:${local.api_host_port}"
}

output "prometheus_url" {
  value = "http://localhost:${local.prometheus_host_port}"
}

output "grafana_url" {
  value = "http://localhost:${local.grafana_host_port}"
}
