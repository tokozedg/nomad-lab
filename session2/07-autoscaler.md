### Lesson 07: Basic Autoscaling with `nomad-autoscaler`

We will perform this lesson in two main steps:
1.  Deploying the `nomad-autoscaler` itself as a Nomad job using `07-autoscaler.hcl`.
2.  Deploying an example application (`cpu-stress`) using `07-cpu-stress.hcl`, which includes a scaling policy that `nomad-autoscaler` will manage.

## Steps:

### Step 1: Deploy `nomad-autoscaler`

The first essential step is to deploy the `nomad-autoscaler` application to your Nomad cluster.

1.  **Run the `nomad-autoscaler` Job:**
    Deploy `nomad-autoscaler` using its job file:
    ```bash
    nomad job run 07-autoscaler.hcl
    ```

2.  **Follow `nomad-autoscaler` Logs:**
    The logs from `nomad-autoscaler` are the primary source of information about its operations, including policy evaluations, metric fetching, scaling decisions, and any errors. Stream these logs:
    ```bash
    nomad alloc logs -f <allocation>
    ```

### Step 2: Deploy and Test the CPU-Stressing Application

With `nomad-autoscaler` running and its logs being monitored, we can now deploy the `cpu-stress` application that we intend to autoscale.

1.  **Understand `07-cpu-stress.hcl` (Conceptual):**
    This job file defines the `cpu-stress-autoscaler` application. Its `scaling` block is specifically designed to be interpreted by the `nomad-autoscaler` we just deployed. `nomad-autoscaler` will detect this job and its policy, then attempt to manage its scale based on the specified metric and target.

2.  **Run the `cpu-stress` Job:**
    Deploy the application to be autoscaled:
    ```bash
    nomad job run 07-cpu-stress.hcl
    ```
    This job will initially start with one instance of the `cpu-stresser` task, as per its `count` setting.

3.  **Verify Scaled Allocations:**
    Once `nomad-autoscaler` has scaled up the `cpu-stress-autoscaler` job, you can inspect its allocations to confirm that multiple instances are indeed running.
