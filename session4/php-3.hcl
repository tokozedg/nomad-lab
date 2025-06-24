# php.nomad.hcl

job "php-app" {
  datacenters = ["dc1"]
  type = "service"

  group "php-group" {
    count = 1

    network {
      # Allocate a dynamic port for the PHP web server
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
      
      env {
        DB_NAME      = "nomad_lab_db"
        DB_USER      = "nomad_user"
        DB_PASS      = "userpassword"
      }

      template {
        data = <<EOF
DB_HOST="{{ range nomadService "mysql-db" }}{{ .Address }}{{ end }}"
DB_PORT="{{ range nomadService "mysql-db" }}{{ .Port }}{{ end }}"
EOF
        destination = "local/db.env"
        env = true
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