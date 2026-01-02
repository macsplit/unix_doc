Process ID Management

## Overview

Process IDs uniquely identify processes and are allocated from a finite pool. The `pid_assign()` function allocates PIDs using a hash table for fast lookup. PIDs are recycled after process termination, with special handling to avoid PID reuse races.

## PID Allocation

The `pid_t` structure maintains PID metadata:

```c
typedef struct pid {
    pid_t pid_id;           /* process ID */
    struct proc *pid_pglink;/* process group link */
    struct proc *pid_link;  /* proc table link */
    uint pid_ref;           /* reference count */
} pid_t;
```

The `pid_assign()` function (pid.c) searches for free PIDs and handles wraparound:

```c
for (;;) {
    if (next_pid >= MAXPID)
        next_pid = 1;
    if (prfind(next_pid) == NULL)
        break;
    next_pid++;
}
```

The search continues until an unused PID is found. Reference counting via `PID_HOLD()` and `PID_RELE()` prevents premature deallocation when a PID is shared across process groups or sessions.

## PID Recycling

When a process exits, `pid_exit()` decrements the reference count. Only when the count reaches zero (no process groups or sessions reference it) is the `pid_t` structure freed. This prevents PID reuse while parent processes still hold references for wait operations.

The pidhash table provides O(1) PID lookup via `prfind()`, critical for signal delivery and process management operations.


![](1.6-pid-allocation.png)
