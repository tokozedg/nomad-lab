### Lesson 03: Service Jobs - Long-Running Applications

In previous lessons, we used `type = "batch"` jobs, which run to completion. Now, we introduce `type = "service"` jobs. These are designed for long-running applications like web servers, APIs, or databases that need to be continuously available. Nomad ensures that the desired number of instances of a service job are running and will restart any instances that fail.

**Key Concepts:**

*   `type = "service"`: This tells Nomad to treat the job as a long-running service. Nomad will actively monitor these tasks and reschedule them if they stop or fail, to maintain the desired state.
*   `group.count`: Within a task group, the `count` parameter specifies how many instances of the tasks in that group should be running. Nomad will distribute these instances across eligible client nodes.

## How to Use:

1.  **Run the job**:
    ```bash
    nomad job run 03-nginx-service.hcl
    ```
    Nomad will schedule two instances of the `nginx-server` task because `count = 2`.

2.  **Check job status**:
    ```bash
    nomad job status nginx-service
    ```
    You will see the overall job status. Under "Allocations", you should see two allocations, each in a `running` state (eventually).

3.  **Inspect an allocation**:
    Grab an Allocation ID from the `nomad job status nginx-service` output.
    ```bash
    nomad alloc status <ALLOCATION_ID>
    ```
    This shows details for one of the Nginx instances.

4.  **View task logs**:
    ```bash
    nomad alloc logs <ALLOCATION_ID>
    ```
    You should see the Nginx startup logs. Note that Nginx is running, but we haven't exposed its port yet, so you can't access it via a browser. We'll cover networking in the next lesson.

5.  **Observe self-healing (Optional but Recommended)**:
    Pick one of the allocation IDs and stop it manually:
    ```bash
    nomad alloc stop <ANOTHER_ALLOCATION_ID>
    ```
    Now, quickly re-check the job status:
    ```bash
    nomad job status nginx-service
    ```
    You'll observe that the stopped allocation is marked as `complete` or `failed`, and Nomad almost immediately schedules a *new* allocation to replace it and bring the running count back to 2. This demonstrates the self-healing nature of service jobs.

6.  **Stop the job**:
    To stop the Nginx service and remove its allocations:
    ```bash
    nomad job stop -purge nginx-service
    ```
