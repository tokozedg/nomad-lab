  List Raft peers:

      $ nomad operator raft list-peers

  Remove a Raft peer:

      $ nomad operator raft remove-peer -peer-address "IP:Port"

  Display info about the raft logs in the data directory:

      $ sudo nomad operator raft info /opt/nomad/data

  Display the log entries persisted in data dir in JSON format.

      $ sudo nomad operator raft logs /opt/nomad/data

  Display the server state obtained by replaying raft log entries
  persisted in data dir in JSON format.

      $ sudo nomad operator raft state /opt/nomad/data

  Please see the individual subcommand help for detailed usage information.