job "php-app" {
  datacenters = ["dc1"]
  type = "service"

  group "php-group" {
    count = 1

    network {
      port "http" {
        to = "80"
      }
    }

    service {
      name = "php-web-app"
      port = "http"
      provider = "nomad"
    }

    task "php-task" {
      driver = "docker"
      
      config {
        image = "php:apache"
        ports = ["http"]
      }
    }
  }
}