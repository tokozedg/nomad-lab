// Run Nomad: nomad agent -config=nomad_agent.hcl

// `data_dir` (string: required)
// Specifies a local directory used to store agent state.
// - For servers: stores cluster state, Raft log, snapshots.
// - For clients: stores allocation data, cluster info.
// MUST be an absolute path. Nomad creates it if it doesn't exist.
data_dir = "/opt/nomad/data" // Example: Using /opt/nomad/data. /var/lib/nomad is also common.

// `name` (string: [hostname])
// Specifies the name of the local node. Defaults to the system's hostname.
// When specified on a server, the name MUST be unique within the region.
// name = "nomad-server-01" // Uncomment and set if you want to override the hostname.

// `region` (string: "global")
// Specifies the region the Nomad agent is a member of.
// Typically maps to a geographic region, e.g., "us", "europe".
region = "us-east"

// `datacenter` (string: "dc1")
// Specifies the data center of the local agent. An abstract grouping within a region.
// Clients don't need to be in the same DC as servers, but must be in the same region.
datacenter = "us-east-1a"

// -----------------------------------------------------------------------------
// NETWORKING CONFIGURATION
// -----------------------------------------------------------------------------

// `bind_addr` (string: "0.0.0.0")
// Specifies the IP address the Nomad agent should bind to for ALL network services
// (HTTP, RPC, Serf gossip). "0.0.0.0" means listen on all available interfaces.
// For development, `nomad agent -dev` defaults to "127.0.0.1".
// Supports go-sockaddr/template format, e.g., "{{ GetPrivateInterfaces | include \"network\" \"10.0.0.0/8\" | attr \"address\" }}"
bind_addr = "0.0.0.0" // Listens on all interfaces. Change to a specific IP if needed.

// `ports` (Block: see defaults below)
// Specifies the network ports for different services.
ports {
  http = 4646 // Port for the HTTP API.
  rpc  = 4647 // Port for internal RPC (client-server, server-server Raft).
  serf = 4648 // Port for Serf gossip (cluster membership). TCP and UDP.
}

// `addresses` (Block: optional)
// Specifies bind addresses for individual network services, overriding `bind_addr`.
// Use IP format without port (port is set via `ports` block).
// Useful if you want HTTP on one interface and RPC/Serf on another.
// addresses {
//   http = "192.168.1.10" // Bind HTTP API to this specific internal IP
//   rpc  = "10.0.0.5"     // Bind RPC to a different internal IP (e.g., on a private network)
//   serf = "10.0.0.5"     // Bind Serf to the same private network IP
// }

// `advertise` (Block: optional)
// Specifies advertise addresses for individual network services.
// Required for NAT, proxies, or complex network topologies where the bind address
// is not reachable by other nodes or users.
// If bind_addr is "0.0.0.0", Nomad attempts to use the first private IP.
// You can include an alternate port here if needed.
advertise {
  // `http`: Address advertised for the HTTP API. Reachable by CLI users/UI.
  // http = "your.public.ip.address" // Or a load balancer IP

  // `rpc`: Address advertised to Nomad clients for connecting to servers (for RPC).
  // Allows clients behind NAT to connect to servers.
  // Must be reachable by all Nomad client nodes.
  // If set, servers use `advertise.serf` for their inter-server RPC.
  // rpc = "private.ip.of.server.routable.by.clients" // e.g., 10.1.2.3

  // `serf`: Address advertised for the gossip layer. Must be reachable by all server nodes.
  // Servers use this IP (and the advertised RPC port) for server-to-server RPC.
  // serf = "private.ip.of.server.routable.by.other.servers:5648" // Example with non-default port
}
// Full example for a server behind NAT:
// advertise {
//   http = "203.0.113.42"         // Public IP for API access
//   rpc  = "10.0.0.10"            // Internal IP servers advertise to clients
//   serf = "10.0.0.10:4648"       // Internal IP servers use for gossip and inter-server RPC
// }


// -----------------------------------------------------------------------------
// AGENT ROLE CONFIGURATION (SERVER / CLIENT)
// -----------------------------------------------------------------------------

// `server` (Block: optional)
// Configures server-specific parameters.
server {
  enabled          = true     // Set to true to run this agent as a server.
  bootstrap_expect = 1      // Number of server nodes expected to start the cluster.
                            // For production, this should be 3 or 5.
                            // For a single server dev setup, 1 is fine.
  // server_join {            // Optional: For automatically joining other servers.
  //   retry_join = ["10.0.0.2", "10.0.0.3"] // List of other server IPs/hostnames to attempt to join.
  //   retry_max = 5
  //   retry_interval = "30s"
  // }
}

// `client` (Block: optional)
// Configures client-specific parameters.
client {
  enabled       = false    // Set to true to run this agent as a client (runs tasks).
                           // Note: Running as both client AND server is NOT recommended for production.
  // servers = ["10.0.0.1:4647", "10.0.0.2:4647", "10.0.0.3:4647"] // List of server addresses clients connect to
  // network_interface = "eth0" // Optional: Specify network interface for fingerprinting.
  // meta {                   // Optional: Arbitrary metadata for the client node.
  //  "instance_type" = "m5.large"
  //  "storage_type"  = "ssd"
  // }
  // host_volume "mydata" {   // Define host volumes available to jobs on this client
  //   path = "/mnt/mydata"
  //   read_only = false
  // }
  // drain_on_shutdown {      // Optional: Configuration for draining client on shutdown signal
  //  enabled = true
  //  deadline = "5m"        // Time to wait for allocations to stop. (Default: client `drain_deadline`)
  //  ignore_system_jobs = false // If true, system jobs are not drained.
  // }
}

// -----------------------------------------------------------------------------
// LOGGING CONFIGURATION
// -----------------------------------------------------------------------------

// `log_level` (string: "INFO")
// Verbosity of logs. Valid levels: "TRACE", "DEBUG", "INFO", "WARN", "ERROR".
log_level = "INFO" // Use "DEBUG" for more detailed troubleshooting.

// -----------------------------------------------------------------------------
// INTEGRATIONS (Consul, Vault)
// -----------------------------------------------------------------------------

// `consul` (Block: optional)
// Configuration for connecting to Consul for service discovery and KV.
consul {
  address = "127.0.0.1:8500" // Address of the Consul agent.
  // scheme = "http"            // "http" or "https".
  // token = "your-consul-acl-token" // Consul ACL token.
  // server_service_name = "nomad-server" // Service name for servers in Consul.
  // client_service_name = "nomad-client" // Service name for clients in Consul.
  // auto_advertise = true      // Advertise Nomad client/server addresses via Consul.
  // tags = ["dev", "us-east"]  // Tags for services registered in Consul.
}

// `vault` (Block: optional)
// Configuration for connecting to HashiCorp Vault for secrets management.
// vault {
//   enabled = true
//   address = "http://127.0.0.1:8200" // Address of the Vault server.
//   token   = "your-vault-token"       // Vault token with necessary policies.
//                                     // Alternatively, use other auth methods (e.g., approle).
//   // tls_skip_verify = true         // DANGEROUS: Disables SSL cert verification. For dev only.
//   // ca_file = "/path/to/vault_ca.crt"
//   // create_from_role = "nomad-cluster" // For Vault Agent token creation or Nomad auto-auth.
// }

// -----------------------------------------------------------------------------
// PLUGINS
// -----------------------------------------------------------------------------

// `plugin_dir` (string: "<data_dir>/plugins")
// Directory to search for task driver and artifact plugins. Absolute path.
// If empty, defaults to `data_dir` + "/plugins". E.g., "/opt/nomad/data/plugins"
// plugin_dir = "/opt/nomad/plugins"

// `plugin` (Block: repeatable)
// Configures a specific plugin. Block key is the plugin's executable name.
// Note: `plugin` blocks for the same plugin override each other if defined in multiple config files,
// they do not merge.
plugin "raw_exec" {
  config {
    enabled = true // Enable the raw_exec driver (use with caution).
    // no_cgroups = false
  }
}

plugin "docker" {
  config {
    volumes {
      enabled = true // Allow jobs to mount Docker volumes.
      // selinuxlabel = "z"
    }
    allow_privileged = false // Set to true to allow privileged Docker containers (security risk).
    // auth {
    //  enabled = true
    //  config = "/etc/docker/dockercfg" // Path to Docker auth config file
    // }
  }
}
