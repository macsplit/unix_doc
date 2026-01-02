Inter-Process Communication - Semaphores

## Overview

System V semaphores provide synchronization primitives for processes. Unlike simple mutexes, semaphore operations are atomic and support multiple operations in a single call. Semaphores use integer counters with wait and signal operations.

## Semaphore Structure

```c
struct semid_ds {
    struct ipc_perm sem_perm; /* permissions */
    struct sem *sem_base;     /* array of semaphores */
    ushort sem_nsems;         /* number in set */
    time_t sem_otime;         /* last operation time */
    time_t sem_ctime;         /* last change time */
};

struct sem {
    ushort semval;   /* semaphore value */
    pid_t sempid;    /* last operation PID */
    ushort semncnt;  /* waiting for increase */
    ushort semzcnt;  /* waiting for zero */
};
```

Each semaphore set contains multiple semaphores, enabling complex synchronization patterns with a single system call.

## Semaphore Operations

The `semop()` system call (sem.c) performs atomic operations:

```c
struct sembuf {
    ushort sem_num;  /* semaphore number */
    short sem_op;    /* operation */
    short sem_flg;   /* flags */
};
```

Operations: `sem_op > 0` increments (signal), `sem_op < 0` decrements if sufficient value exists (wait), `sem_op == 0` blocks until semaphore reaches zero.

The IPC_NOWAIT flag makes operations non-blocking, returning EAGAIN instead of sleeping. SEM_UNDO flag enables automatic undo on process exit, preventing deadlock when a process terminates while holding semaphores.


![](1.9-semaphores.png)
