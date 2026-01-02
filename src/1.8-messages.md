Inter-Process Communication - Messages

## Overview

System V message queues provide asynchronous message passing between processes. Messages are typed, allowing selective retrieval. The kernel maintains message queues in `msqid_ds` structures with permission controls and flow control.

## Message Queue Structure

```c
struct msqid_ds {
    struct ipc_perm msg_perm; /* permissions */
    struct msg *msg_first;    /* first message */
    struct msg *msg_last;     /* last message */
    ulong msg_qnum;           /* number of messages */
    ulong msg_qbytes;         /* max bytes in queue */
    pid_t msg_lspid;          /* last send PID */
    pid_t msg_lrpid;          /* last receive PID */
};
```

Messages are linked in FIFO order. The `msg_qbytes` limit prevents unbounded queue growth.

## Message Operations

`msgsnd()` (msg.c) copies the message from user space and links it to the queue. If the queue is full, the sender sleeps until space becomes available. `msgrcv()` searches for messages matching the requested type, removes them from the queue, and wakes waiting senders.

Message types enable multiplexing - different message types can share a queue, with receivers selecting specific types via the `msgtyp` parameter. Type 0 retrieves the first message regardless of type.

Flow control prevents deadlock: senders block when the queue byte limit is exceeded, and receivers block when no matching messages exist. This implements producer-consumer synchronization without explicit locking.


![](1.8-message-queues.png)
