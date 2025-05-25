### Lesson 01: Cron Jobs

This job, is designed to run a simple command (`/bin/date`) every minute.

## How to Use:

1.  **Run the job**:
    ```bash
    nomad job run 01-cron.hcl
    ```

2.  **Check job status**:
    ```bash
    nomad job status cron
    ```
    You'll see the job status

3.  **Check executed job status**:
    ```bash
    nomad job status cron/periodic-XXXXXX
    ```
    You will see the execute job status and under "Allocations", you'll see instances of the task being run.

4.  **Inspect an allocation**:
    Grab an Allocation ID from the `nomad job status` output.
    ```bash
    nomad alloc status <ALLOCATION_ID>
    ```
    This shows details about a specific instance of the task.

5.  **View task logs (to see the output of `date`)**:
    Since the `/bin/date` command outputs to stdout, we can view its output in the task logs.
    ```bash
    nomad alloc logs <ALLOCATION_ID>
    ```
    You should see the current date and time printed, corresponding to when that allocation ran.
    *Note: For very short-lived tasks, the allocation might complete before you can check logs easily. The periodic nature helps here as new ones will keep appearing.*

6.  **Stop the job**:
    To stop the job and remove it completely (including past allocations from view):
    ```bash
    nomad job stop -purge cron
    ```
