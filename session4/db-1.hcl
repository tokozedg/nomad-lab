job "mysql-server" {
  datacenters = ["dc1"]
  type = "service"
  
  group "mysql-group" {
    count = 1
    task "mysql-task" {
      driver = "docker"

      config {
        image = "mysql:8.0"
      }
      env {
        MYSQL_ROOT_PASSWORD = "supersecretpassword"
      }

      resources {
        cpu    = 200
        memory = 512
      }
    }
  }
}