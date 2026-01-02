Inter-Process Communication - Shared Memory

![Shared Memory](1.10-shared-memory.png)

## Overview

System V shared memory enables high-performance IPC by mapping the same physical memory into multiple process address spaces. Unlike message queues and semaphores, shared memory requires no kernel intervention after attachment, making it the fastest IPC mechanism.

## Shared Memory Structure

```c
struct shmid_ds {
    struct ipc_perm shm_perm;  /* permissions */
    int shm_segsz;             /* segment size */
    struct anon_map *shm_amp;  /* anonymous memory */
    ushort shm_nattch;         /* attach count */
    pid_t shm_lpid;            /* last operation PID */
    pid_t shm_cpid;            /* creator PID */
    time_t shm_atime;          /* last attach time */
    time_t shm_dtime;          /* last detach time */
    time_t shm_ctime;          /* last change time */
};
```

The `shm_amp` pointer references an anonymous memory map shared among all attached processes. Page faults in the shared region allocate pages that all processes see.

## Attachment and Mapping

The `shmat()` system call (shm.c) maps the segment into the process address space:

```c
addr = (caddr_t)as_map(p->p_as, addr, sp->shm_segsz,
    segshm_create, sp);
```

The `seg_shm` segment driver manages the mapping, delegating page faults to the underlying anonymous memory. Multiple processes mapping the same segment share physical pages through the `anon_map` structure.

Detachment via `shmdt()` unmaps the segment but doesn't free memory until all attachments are removed and IPC_RMID has been called. This allows clean resource management even when processes terminate unexpectedly.

## Synchronization

Shared memory provides no implicit synchronization - processes must use semaphores or other mechanisms to coordinate access. This separation of data sharing from synchronization enables flexible, high-performance designs where synchronization overhead matches actual requirements.

