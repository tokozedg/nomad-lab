data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

advertise {
  http = "10.10.0.2"       // Public IP for API access
  rpc  = "10.10.0.2"       // Internal IP servers advertise to clients
  serf = "10.10.0.2"       // Internal IP servers use for gossip and inter-server RPC
}

server {
  enabled          = true
#   bootstrap_expect = 1
  bootstrap_expect = 3

  # required only on manager 2-3 only 
  server_join {
    retry_join = ["10.10.0.1:4648"] # join manager 1
  }
}