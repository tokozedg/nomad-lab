job "mysql-server" {
  datacenters = ["dc1"]
  type = "service"

  group "mysql-group" {
    count = 1

    network {
      port "db" {
        to = 3306
      }
    }

    # Register this task in Nomad's service discovery
    service {
      name = "mysql-db"
      tags = ["primary", "database"]
      port = "db"
      provider = "nomad"

      check {
          name = "mysql-db"
          type     = "tcp"
          interval = "2s"
          timeout  = "2s"
      }
    }

    task "mysql-task" {
      driver = "docker"

      config {
        image = "mysql:8.0"
        ports = ["db"]
      }
      env {
        MYSQL_ROOT_PASSWORD = "supersecretpassword"
      }

      resources {
        cpu    = 200 # 200 MHz
        memory = 512 # 512MB
      }
    }
  }
}