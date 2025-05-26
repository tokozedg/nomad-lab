### Lesson 02: Introducing the Docker Driver

In the previous lesson, we used `raw_exec` to run commands directly on the host. Now, we'll explore the **Docker driver**, which allows Nomad to orchestrate Docker containers. This provides better isolation, portability, and access to a vast ecosystem of pre-built images for running your applications and tools.

**Prerequisites:**
*   Docker must be installed and running on the Nomad client node(s) where these tasks will be scheduled.
*   If you are running Nomad locally with `nomad agent -dev`, ensure Docker Desktop or Docker Engine is running on your machine.

**Key Concepts:**

*   `driver = "docker"`: This directive in a task stanza tells Nomad to use the Docker runtime for executing the task.
*   `task.config.image`: Specifies the Docker image to be pulled and run.
*   `task.config.command` & `task.config.args`: Similar to `raw_exec`, these can be used to override the Docker image's default `ENTRYPOINT` and/or `CMD`. This is useful for running specific commands within a general-purpose image.

## How to Use:

1.  **Run the job**:
    ```bash
    nomad job run 02-docker-driver.hcl
    ```
    Nomad will schedule the tasks. The Docker driver will pull the images if they are not already present on the client node.

2.  **Check job status**:
    ```bash
    nomad job status docker-tools-example
    ```
    You should see two task groups and their allocations. Note the Allocation IDs for each task.