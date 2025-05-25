job "nginx-updater" {
  datacenters = ["dc1"]
  type        = "service"

  group "nginx-group" {
    count = 2 // We want 2 instances of Nginx running

    // Defines the strategy for updating allocations in this group.
    update {
      // max_parallel specifies how many allocations can be updated (stopped and new ones started)
      // at the same time. '1' means one-by-one.
      max_parallel      = 1

      // min_healthy_time is the duration a new allocation must be healthy (passing its checks)
      // before Nomad considers it successfully updated and moves to the next one.
      min_healthy_time  = "3s"

      // healthy_deadline is the maximum time Nomad will wait for an allocation to become healthy.
      // If it fails to become healthy within this time, the update for that allocation is failed.
      healthy_deadline  = "3m"

      // If true, Nomad will automatically roll back to the previously known good version
      // if the update fails (e.g., new instances don't become healthy).
      auto_revert       = true


      // canary specifies how many instances of the new version are deployed first for testing.
      // 0 means no canaries, proceed with rolling update directly.
      // If > 0, usually auto_promote is set to false, requiring manual promotion.
      canary            = 0
	  //auto_promote      = true
    }

    /*
    Blue-green example,
    By setting the canary count equal to that of the task group, blue/green
    deployments can be achieved. When a new version of the job is submitted,
    instead of doing a rolling upgrade of the existing allocations, the new
    version of the group is deployed along side the existing set. 

    update {
      canary       = 3
      max_parallel = 3
    }
    */

    network {
      port "http" {
        to = 80 // Nginx listens on port 80 inside the container
      }
    }

    // The 'service' stanza registers this task with service discovery (if configured)
    // and allows defining health checks.
    service {
      name = "nginx-web" // Name for service discovery
      port = "http"     // Health check this port
	  provider = "nomad"

      // Health check for Nginx. The update stanza relies on these checks
      // to determine if a new instance is "healthy".
      check {
        type     = "http" // Perform an HTTP GET request
        path     = "/"    // Path for the HTTP GET request
        interval = "10s" // Time between health checks
        timeout  = "2s"   // Time to wait for a response
      }
    }

    task "nginx-server" {
      driver = "docker"

      config {
        // Start with an initial version of Nginx.
        // Using specific patch versions is good practice for reproducibility.
        image = "nginx:1.26.0"
        ports = ["http"]
      }

    }
  }
}