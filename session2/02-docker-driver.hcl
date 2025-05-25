// Defines a Nomad job named "docker-tools-example".
// This job demonstrates running simple command-line tools using the Docker driver.
job "docker-tools-example" {
  // Specifies the datacenter(s) where this job can run.
  // Ensure your Nomad agent is part of "dc1" or adjust as needed.
  // For dev mode (nomad agent -dev), this is typically "dc1".
  datacenters = ["dc1"]

  // "batch" type jobs are expected to run to completion.
  // These tasks will run, print their output, and then exit.
  type = "batch"

  // Task group for running docker/whalesay.
  group "whalesay-group" {
    task "whalesay-hello" {
      driver = "docker"
      config {
        image   = "docker/whalesay:latest" // For this simple tool, latest is fine
        command = "cowsay"
        args    = ["Hello from Nomad and Docker!"]
      }
      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}