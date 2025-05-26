// Defines a Nomad job named "docker-tools-example".
// This job demonstrates running simple command-line tools using the Docker driver.
job "hello-job" {
  // Specifies the datacenter(s) where this job can run.
  // Ensure your Nomad agent is part of "dc1" or adjust as needed.
  // For dev mode (nomad agent -dev), this is typically "dc1".
  datacenters = ["dc1"]

  // "batch" type jobs are expected to run to completion.
  // These tasks will run, print their output, and then exit.
  type = "batch"

  // Task group for running docker/whalesay.
  group "hello-group" {
    task "hello-task" {
      driver = "docker"
      config {
        image   = "alpine:latest"
        command = "echo"
        args    = ["Hello from Nomad and Docker!"]
      }
      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}