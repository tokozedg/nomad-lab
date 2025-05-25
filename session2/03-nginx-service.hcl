// Defines a Nomad job named "nginx-service".
// This job demonstrates running a long-running service using the Docker driver.
job "nginx-service" {
  // Specifies the datacenter(s) where this job can run.
  datacenters = ["dc1"]

  // "service" type jobs are intended to run continuously.
  // Nomad will ensure the desired number of instances are running
  // and will restart failed instances.
  type = "service"

  // Defines a group of tasks for the nginx service.
  group "nginx-group" {
    // Specifies the desired number of instances (allocations) for this group.
    // Nomad will maintain 2 running instances of the nginx task.
    count = 2

    task "nginx-server" {
      driver = "docker"

      config {
        // Use a specific version of nginx for predictability.
        image = "nginx:1.25"
        // Nginx by default listens on port 80 inside the container.
        // We are not exposing this port to the host yet; that's for the next lesson.
      }
    }
  }
}
