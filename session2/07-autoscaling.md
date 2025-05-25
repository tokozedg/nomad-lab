### Lesson 16: Autoscaling (Introduction)

In the previous lesson, we looked at manual scaling. Now, we introduce **autoscaling**, where Nomad automatically adjusts the number of running instances of a task group based on observed metrics, such as CPU or memory utilization. This helps ensure your application has enough resources to handle load while potentially reducing costs during quiet periods.

This lesson covers Nomad's built-in autoscaling capabilities, which are suitable for CPU and memory-based scaling. For more advanced scenarios, like scaling based on custom application metrics, queue lengths, or APM data, HashiCorp offers the `nomad-autoscaler`, a separate tool that integrates with Nomad.

**Key Concepts:**

*   `group.scaling {}` stanza: Configures autoscaling for a task group.
    *   `enabled = true`: Activates autoscaling for the group.
    *   `min = <count>`: The minimum number of allocations Nomad will maintain.
    *   `max = <count>`: The maximum number of allocations Nomad will scale out to.
    *   `policy {}`: Defines the rules for scaling.
        *   `type = "target-value"`: A common policy type where Nomad tries to maintain an average metric value (e.g., CPU utilization) across allocations.
        *   `cooldown = "duration"`: The period Nomad waits after a scaling event before it will consider another scaling event *in the same direction* (e.g., after scaling up, wait before scaling up again). This prevents thrashing.
        *   `evaluation_interval = "duration"`: How frequently Nomad evaluates the scaling policy.
        *   `target "metric_name" {}`: Specifies the metric to monitor.
            *   `value = <percentage>`: For CPU or memory targets, this is the desired average utilization percentage. Nomad will scale out if average utilization is above this target and scale in if it's sufficiently below. The utilization is calculated relative to the `resources` defined in the task.

*   **Nomad Server Role:** The Nomad server's scheduler is responsible for evaluating these `target-value` autoscaling policies and making scaling decisions for CPU/Memory targets directly.

*   **`nomad-autoscaler` (External Tool):** For scaling based on metrics from external systems (like Prometheus, Datadog, AWS CloudWatch, or custom metrics via an APM), you would deploy and configure the `nomad-autoscaler`. This is a more advanced setup beyond this introductory lesson.

## How to Use:

The provided `07-autoscaling-intro.hcl` job defines a service with a single task `cpu-stresser`. This task runs a command designed to consume CPU. The `scaling` policy is configured to target an average CPU utilization of 50%.

1.  **Save the HCL:**
    Ensure the HCL content for this lesson is saved as `07-autoscaling-intro.hcl`.

2.  **Run the job**:
    ```bash
    nomad job run 07-autoscaling-intro.hcl
    ```
    The job will start with `count = 1` as defined in `group "app-group"`.

3.  **Monitor Job Status and Scaling**:
    *   **Initial Status:**
        ```bash
        nomad job status autoscale-app
        ```
        You'll see 1 desired and 1 placed allocation.

    *   **Observe CPU Load and Scaling Decisions:**
        The `cpu-stresser` task is designed to use more than 50% of its allocated `100 MHz` CPU. This should trigger a scale-out event after the `evaluation_interval`.
        Use the following command to check the autoscaler's reasoning and recent decisions:
        ```bash
        nomad job scaling-status autoscale-app
        ```
        Look for "Policy Events" or similar sections that indicate why a scaling decision was (or wasn't) made. You might see messages about the current average CPU utilization and how it compares to the target.

    *   **Allocation Resource Usage (Optional):**
        To see the current resource usage of an individual allocation:
        ```bash
        nomad alloc status -verbose <ALLOC_ID>
        ```
        Scroll to the "Resource Usage" section for the task. This can help confirm if the task is indeed consuming enough CPU to trigger scaling.

    *   **Wait for Scaling:**
        Autoscaling decisions are not instantaneous due to `evaluation_interval` and `cooldown` periods. It might take a minute or two for the first scale-out event to occur.
        Keep checking `nomad job status autoscale-app`. You should eventually see the "Desired" and "Placed" counts increase from 1 up to the `max` of 3, as long as the average CPU usage remains above target.

4.  **Observe Scale-In (Potentially Harder to Demo Quickly)**:
    If you were to stop the CPU stress (e.g., by modifying the job to run a less intensive command and re-running it, or if the load naturally decreased), the average CPU utilization would drop. After the cooldowns and evaluation periods, Nomad would then scale the service back down towards the `min` count.
    For this example, the `cpu-stresser` will continuously run, so it will likely remain scaled out.

5.  **Stop the job**:
    ```bash
    nomad job stop -purge autoscale-app
    ```

**Important Considerations:**

*   **Metric Collection:** Nomad clients collect CPU and memory usage information. The accuracy and timeliness of these metrics are crucial for effective autoscaling.
*   **Resource Requests:** The `resources` block in your task (e.g., `cpu = 100`) is critical. The autoscaler calculates utilization percentage *based on this request*. If your request is too high, your application might never reach the target utilization to scale out. If too low, it might scale out prematurely.
*   **Tuning:** Finding the right `target` values, `cooldowns`, and `evaluation_interval` often requires experimentation and observation of your specific application's behavior under load.
*   **Readiness:** Ensure your application instances become "ready" (e.g., pass health checks if configured) quickly after startup. Long startup times can complicate autoscaling.

This lesson provides a basic introduction. Real-world autoscaling often involves more sophisticated metric analysis and might leverage the `nomad-autoscaler` for greater flexibility.