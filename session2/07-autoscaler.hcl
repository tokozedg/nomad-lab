job "autoscaler" {
  type = "service"

  datacenters = ["dc1"]

  group "autoscaler" {
    count = 1

    task "autoscaler" {
      driver = "exec"
     
      config {
        command = "/usr/bin/nomad-autoscaler"
        args    = ["agent", "-log-level=DEBUG", "-config", "${NOMAD_TASK_DIR}/config.hcl"]
      }

      template {
        data = <<EOF
nomad {
  address = "http://{{env "attr.unique.network.ip-address" }}:4646"
}

strategy "target-value" {
  driver = "target-value"
}
          EOF

        destination = "${NOMAD_TASK_DIR}/config.hcl"
      }

      resources {
        cpu    = 50
        memory = 128
      }

	}
}
}