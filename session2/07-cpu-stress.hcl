job "cpu-stress" {
  datacenters = ["dc1"]
  type        = "service"

  group "app-group" {
    count = 1 // Initial number of instances

    // Autoscaling configuration for this group
    scaling {
      enabled = true // Enable autoscaling for this group
      min     = 1    // Minimum number of allocations
      max     = 3    // Maximum number of allocations to scale out to

	  policy {
      cooldown = "30s"
      evaluation_interval = "10s"

      check "high_node-cpu" {
        source = "nomad-apm"
        query = "avg_cpu-allocated"
        query_window = "10s"

        strategy "target-value" {
          target    = 80
        }
      }
	  }
    }


    task "cpu-stresser" {
      driver = "docker"

      config {
        image = "alpine:latest"

        // This command continuously calculates SHA256 sums, which consumes CPU.
        // It's run in the background (&) so the main command (sleep) keeps the container alive.
        command = "/bin/sh"
        args = [
          "-c",
          "echo 'Starting CPU stress in background...' && (while true; do sha256sum /dev/zero > /dev/null; done) & echo 'Sleeping for an hour...' && sleep 3600"
        ]
      }

      resources {
        // Define CPU resources for the task. The autoscaler's CPU utilization percentage
        // is calculated against this requested value.
        // 100 MHz means if the task uses 50MHz on average, that's 50% utilization.
        // The stress command will likely try to use more than 50% of this limit.
        cpu    = 100 // Requested CPU in MHz.
        memory = 64  // Requested memory in MB.
      }
    }
  }
}