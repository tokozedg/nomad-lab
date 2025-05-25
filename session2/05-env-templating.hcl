// Defines a Nomad job to demonstrate environment variables and templating.
job "env-templating-example" {
  datacenters = ["dc1"] // Ensure your Nomad agent is part of "dc1"
  type        = "service" // Run as a service to keep it active for inspection

  group "app-group" {
    count = 1

    task "app-task" {
      driver = "docker"

      // Define environment variables that will be available to the task
      // and can be used in templates.
      env {
        APP_NAME    = "MyNomadApp"
        APP_VERSION = "1.0.3"
        API_KEY     = "verysecretkey12345" // In production, use Vault for secrets
        FEATURE_FLAG_A = "true"
      }

      // The 'template' stanza renders a configuration file from a template.
      // This file can then be used by the task.
      template {
        // 'data' is the content of the template.
        data = <<EOH
API_KEY="{{ env "API_KEY" }}"
FEATURE_FLAG_A={{ env "FEATURE_FLAG_A" }}

# Nomad specific environment variables available:
NOMAD_JOB_ID="{{ env "NOMAD_JOB_ID" }}"
NOMAD_ALLOC_ID="{{ env "NOMAD_ALLOC_ID" }}"
NOMAD_TASK_NAME="{{ env "NOMAD_TASK_NAME" }}"
NOMAD_GROUP_NAME="{{ env "NOMAD_GROUP_NAME" }}"
NOMAD_SECRETS_DIR_IN_TEMPLATE="{{ env "NOMAD_SECRETS_DIR" }}" # Path to secrets dir
NOMAD_TASK_DIR_IN_TEMPLATE="{{ env "NOMAD_TASK_DIR" }}"     # Path to task's local dir
EOH
        // 'destination' is the path where the rendered file will be written
        // within the task's allocation directory structure.
        // Using "secrets/" prefix places it in the task's private secrets directory.
        // This directory (NOMAD_SECRETS_DIR) has restricted access.
        destination = "secrets/app.ini" // e.g., alloc/<alloc_id>/app-task/secrets/app.ini
      }
      template {
        data = file("05-app.conf")
        destination = "local/app.conf"
      }

      config {
        image = "alpine:3.19" // A small base image

        entrypoint = ["/bin/sh", "-c"]
        command = "tail -f /dev/null"

        mounts = [
          {
            type   = "bind"
            // 'source' is the path to the file on the host, relative to the task's
            // working directory root (alloc/<alloc_id>/<task_name>/).
            // "secrets/app.ini" matches the 'destination' of our template.
            source = "secrets/app.ini"
            // 'target' is the path where the file will be available inside the container.
            target = "/config/app.ini"
            readonly = true // Mount the config file as read-only in the container.
          },
          {
            type = "bind"
            source = "local/app.conf"
            target = "/config/app.conf"
          }
        ]
      }

    }
  }
}