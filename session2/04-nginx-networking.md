### Lesson 04: Networking - Exposing Service Ports

In the previous lesson, we ran Nginx as a service, but it wasn't accessible from outside its container. This lesson focuses on configuring networking in Nomad to expose service ports, allowing us to interact with our applications.

**Key Concepts:**

*   `group.network {}`: This block within a `group` stanza is used to configure network resources for all tasks in that group.
*   `port "label" {}`: Defines a network port that Nomad should manage for the tasks in the group.
    *   `label`: A descriptive name for the port (e.g., "http", "db", "admin"). This label is used by Nomad for identification and can be referenced by service discovery.
    *   `to = <container_port>`: Specifies the port number inside the container that the host port should map to. For example, if Nginx listens on port `80` inside its container, you would set `to = 80`. This is highly recommended for clarity.
    *   **Dynamic Ports (Default & Recommended):** If you define a port like `port "http" { to = 80 }` without specifying a `static` host port, Nomad automatically finds an available dynamic port on the host machine. This host port is then mapped to the `to` port (e.g., port 80) inside the container. This is the preferred method as it avoids port conflicts on the host.
    *   **Static Ports:** You can request a specific port on the host using `static = <host_port>`. For example, `port "http" { static = 8080 to = 80 }` would map host port 8080 to container port 80. This is useful when an external system (like a fixed-configuration load balancer) expects a service to be on a predictable port. However, it increases the risk of port conflicts if another application on the host is already using that static port.

**Networking Related Environment Variables**

Those are environment variables set inside container.
We have 2 types of networking configuration, `http` has `to` port 80 defined and `api` network is set to random in both host binding and inside container too.
If container want to use random port like api, it should read the env variable: `$NOMAD_ALLOC_PORT_api` and bind a service to it.

```
NOMAD_ADDR_api=172.24.144.10:27645
NOMAD_ALLOC_PORT_api=27645
NOMAD_HOST_ADDR_api=172.24.144.10:27645
NOMAD_HOST_IP_api=172.24.144.10
NOMAD_HOST_PORT_api=27645
NOMAD_IP_api=172.24.144.10
NOMAD_PORT_api=27645

NOMAD_ADDR_http=172.24.144.10:30663
NOMAD_ALLOC_PORT_http=80
NOMAD_HOST_ADDR_http=172.24.144.10:30663
NOMAD_HOST_IP_http=172.24.144.10
NOMAD_HOST_PORT_http=30663
NOMAD_PORT_http=80
```

## How to Use:

1.  **Save the HCL:**
    Ensure the HCL content for this lesson is saved as `04-nginx-networking.hcl`.

2.  **Run the job**:
    ```bash
    nomad job run 04-nginx-networking.hcl
    ```
    Nomad will schedule the Nginx instance and configure the network, including port mapping.

3.  **Check job status**:
    ```bash
    nomad job status nginx-service-networked
    ```
    Note the Allocation ID from the output.

4.  **Find the allocated port**:
    To discover the dynamic port assigned by Nomad on the host, inspect the allocation:
    ```bash
    nomad alloc status <ALLOCATION_ID>
    ```
    Look for the "Allocated Resources" section, then "Network". You should see something similar to:
    ```
	Allocation Addresses:
	Label  Dynamic  Address
	*http  yes      127.0.0.1:22193 -> 80
    ```
    If you are running `nomad agent -dev` locally, the `<client_ip>` is often `127.0.0.1` or the IP of your Docker bridge network interface.

5.  **Access Nginx**:
    Open your web browser and navigate to `http://<client_ip>:<dynamic_port>`.
    You should see the "Welcome to nginx!" page.

6.  **Stop the job**:
    ```bash
    nomad job stop -purge nginx-service-networked
    ```
