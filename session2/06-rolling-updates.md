### Lesson 06: Rolling Updates and Versioning

Previously, when we changed a job (e.g., updating an image tag) and re-ran `nomad job run`, Nomad would typically stop all old instances and start new ones. For services that need to remain available, this downtime is unacceptable. This lesson introduces **rolling updates**, a strategy to update applications with minimal or zero downtime by gradually replacing old instances with new ones. We'll also touch upon how Nomad handles job versions.

**Key Concepts:**

*   `group.update {}` stanza: This block within a `group` defines the strategy for updating allocations in that group.
    *   `max_parallel`: The maximum number of allocations that will be updated (stopped and started) simultaneously. Setting this to `1` means one-by-one updates.
    *   `min_healthy_time`: The duration a new allocation must remain healthy (passing its health checks) before Nomad considers it successfully updated and proceeds with the next one. This relies on `service.check` being configured.
    *   `healthy_deadline`: The maximum time Nomad will wait for an allocation to become healthy. If it doesn't become healthy within this time, the update for that allocation (and potentially the deployment) is considered failed.
    *   `progress_deadline`: The maximum time allowed for the entire update process for the group to complete.
    *   `auto_revert = true`: If the update fails (e.g., new instances don't become healthy), Nomad will automatically roll back to the previously known good version of the job.
    *   `canary = <count>`: (Set to 0 in our example) Specifies how many "canary" instances of the new version should be deployed and monitored first. If canaries are healthy, the rest of the update proceeds. If `canary > 0`, `auto_promote = false` is often used, requiring manual promotion via `nomad deployment promote`.

*   **Job Versions:** Every time you successfully run `nomad job run` with changes to a job specification, Nomad creates a new version of that job. This allows you to see the history and potentially revert to older versions.

*   **Deployments:** When an update is triggered for a job, Nomad creates a "deployment" object to track the progress of this change across task groups and allocations.

## How to Use:

1.  **Save the HCL:**
    Ensure the HCL content for this lesson is saved as `06-rolling-updates.hcl`. It defines an Nginx service initially running `nginx:1.25.0` with `count = 2` and an update strategy that includes health checking.

2.  **Initial Deployment (Version 1 - nginx:1.25.0)**:
    ```bash
    nomad job run 06-rolling-updates.hcl
    ```
    Nomad will schedule two instances of `nginx:1.25.0`.

3.  **Check Initial Status**:
    ```bash
    nomad job status nginx-updater
    ```
    Wait until both allocations are `running` and their health checks (defined in the `service` block) are passing. You can also find the dynamically assigned ports using `nomad alloc status <ALLOC_ID>` and verify Nginx is accessible.

4.  **Prepare for an Update (Version 2 - nginx:1.26.0)**:
    *   Open `06-rolling-updates.hcl`.
    *   Change the Nginx image version in the `task "nginx-server"` block:
        ```hcl
        // Inside task "nginx-server" -> config
        image = "nginx:1.26.0" // Update to a newer version
        ```
    *   Save the file.

5.  **Trigger the Rolling Update**:
    Run the modified job file:
    ```bash
    nomad job run 06-rolling-updates.hcl
    ```
    Nomad detects the change and starts a deployment based on the `update` strategy.

6.  **Observe the Update Process**:
    *   **Job Status:**
        ```bash
        nomad job status nginx-updater
        ```
        You'll see the "Desired" count for allocations reflect the update, and allocations being replaced one by one (due to `max_parallel = 1`). Watch the "Healthy" and "Unhealthy" counts for the task group.
    *   **Deployment List:**
        ```bash
        nomad deployment list
        ```
        You should see a deployment for the `nginx-updater` job with a status like `running` or `successful`. Note the **Deployment ID**.
    *   **Deployment Status (Detailed Progress):**
        ```bash
        nomad deployment status <DEPLOYMENT_ID>
        ```
        This command provides detailed information about the update, showing which allocations are pending, running, healthy, or being stopped for each task group. It will show new allocations waiting for `min_healthy_time`.

7.  **Verify the Update**:
    Once `nomad job status nginx-updater` shows all allocations are running and healthy with the new desired version, and `nomad deployment status <DEPLOYMENT_ID>` shows "successful":
    *   Inspect an allocation:
        ```bash
        nomad alloc status <NEW_ALLOC_ID>
        ```
        Check the "Task Configuration" or similar section to confirm it's now running `image = "docker.io/library/nginx:1.26.0"`.
    *   Access Nginx through its exposed port to confirm it's still working.

8.  **Check Job Versions**:
    To see the different versions of the job Nomad has stored:
    ```bash
    nomad job status -versions nginx-updater
    ```
    You should see at least two versions listed. Note their version numbers and "Job Modify Index".

9.  **Stop the job**:
    ```bash
    nomad job stop -purge nginx-updater
    ```
