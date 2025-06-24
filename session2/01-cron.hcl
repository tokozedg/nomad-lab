// Defines a Nomad job named "cron".
// A job is the top-level unit of work submitted to Nomad.
job "cron" {
  // Specifies the job type.
  // "batch" jobs run to completion and are typically used for short-lived tasks.
  // Other types include "service" (long-running) and "system" (runs on all clients).
  type = "batch"

  // Defines a periodic scheduler for this job.
  // This allows the job to be run automatically at specified intervals.
  # periodic {
  #   // Cron expression specifying when the job should run.
  #   // "* * * * *" means "run every minute".
  #   // Format: minute hour day_of_month month day_of_week
  #   crons = ["* * * * *"]
  #   time_zone = "Asia/Tbilisi"

  #   // If true, Nomad will not start a new instance of the job
  #   // if the previous instance is still running. This prevents overlaps.
  #   prohibit_overlap = true
  # }

  parameterized {
    payload       = "forbidden"
    // meta_required specifies a list of meta keys that *must* be provided during dispatch.
    meta_required = ["DATE_F"]
  }

  // Defines a group of tasks within the job.
  // All tasks within a group are scheduled on the same Nomad client node.
  group "date-group" {
    // Defines a task named "cron-task".
    // A task is the smallest unit of work in Nomad and represents a single command or application.
    task "cron-task" {
      // Specifies the task driver.
      // The "raw_exec" driver runs commands directly on the Nomad client host's OS.
      // It does not provide isolation like Docker or Podman.
      driver = "raw_exec"

      // Driver-specific configuration.
      config {
        // The command to be executed by the "exec" driver.
        command = "/bin/date"
        // Optional: arguments can be passed as a list
        args = ["${NOMAD_META_DATE_F}"]
      }

      // Resource allocation for this task.
      // Nomad uses these to find a suitable client node
      resources {
        cpu    = 100 // Requested CPU in MHz (e.g., 100 MHz = 0.1 CPU core)
        memory = 32  // Requested memory in MB
      }
    }
  }
}