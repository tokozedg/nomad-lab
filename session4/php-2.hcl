# php.nomad.hcl

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

    # Register the PHP app as a web service
    service {
      name = "php-web-app"
      tags = ["php", "web"]
      port = "http"
      provider = "nomad"
    }

    task "php-task" {
      driver = "docker"

      template {
        data = file("./src/index.php")
        destination = "local/index.php"
      }

      config {
        image = "php:apache"
        ports = ["http"]
        mounts = [
          {
            type   = "bind"
            source = "local/index.php"
            target = "/var/www/html/index.php"
          }
        ]
      }
    }
  }
}