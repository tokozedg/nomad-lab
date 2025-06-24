# mysql.nomad.hcl

job "mysql-server" {
  datacenters = ["dc1"]
  type = "service"
  
  meta {
    run_uuid = "${uuidv4()}"
  }

  group "mysql-group" {
    count = 1

    network {
      port "db" {
        to = 3306 # The port inside the container
      }
    }

    service {
      name = "mysql-db"
      tags = ["primary", "database"]
      port = "db" # Use the port label defined above
      provider = "nomad"

      # A simple health check to ensure MySQL is ready
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
        ports = ["db"] # Map the "db" port to the container
      }

      env {
        MYSQL_ROOT_PASSWORD = "supersecretpassword"
        MYSQL_DATABASE      = "nomad_lab_db"
        MYSQL_USER          = "nomad_user"
        MYSQL_PASSWORD      = "userpassword"
      }

      resources {
        cpu    = 200 # 200 MHz
        memory = 512 # 512MB
      }
    }
  }
}