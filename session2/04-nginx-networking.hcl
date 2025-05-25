job "nginx-service-networked" {
  type = "service"

  group "nginx-group" {
    count = 1

    network {
      # create a new network and map to port 80 inside container, host port will be generated randomly
      port "http" {
        to = 80
        # static = 8080
      }

      # create a new network with random container and host ports
      # container should use env variable to bind on generated random port
      port "api" {}

    }

    task "nginx-server" {
      driver = "docker"

      config {
        image = "nginx:latest"
        # bind networking to specific containers
        ports = ["http", "api"]
      }
    }
  }
}