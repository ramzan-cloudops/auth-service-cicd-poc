job "auth-service" {
  datacenters = ["dc1"]
  namespace   = "ai-service-dev"
  type        = "service"

  group "auth" {
    count = 1

    network {
      port "http" {
        to = 3000
      }
    }

    task "auth-service" {
      driver = "docker"

      config {
        image = "ramzan11/auth-service-cicd-poc:latest"
        ports = ["http"]
      }

      env {
        PORT = "3000"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}