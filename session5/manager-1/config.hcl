# /etc/consul-template/config.hcl on 10.10.0.1

# This block configures the connection to the Consul agent.
consul {
  address = "10.10.0.1:8500"
}

# This block defines a template to render.
template {
  # Path to the template on disk
  source      = "/etc/consul-template/templates/index.ctmpl"

  # Path to where the file will be rendered
  destination = "/var/www/html/index.html"

  # Command to run after the template is rendered.
  # This tells Nginx to reload its configuration to serve the new file.
  command = "sudo systemctl reload nginx"
}