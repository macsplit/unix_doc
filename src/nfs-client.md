# Network File System (NFS) Client

## Overview: The Foreign Office and its Diplomatic Cables

The Network File System (NFS) client is the kernel's Foreign Office, an agency dedicated to the complex and delicate art of diplomacy with foreign powers (NFS servers). Its mission is to make the resources of these foreign powers (their files and directories) appear as if they are part of our own domestic territory. A file on a remote server, once mounted, should be indistinguishable from a file on a local disk.

This transparency is achieved through a sophisticated protocol of diplomatic exchanges. The Foreign Office does not send simple letters; it dispatches formal diplomatic cables, carefully encoded in a universal language of diplomacy to ensure they are understood by all parties, regardless of their native tongue. These cables are Remote Procedure Calls (RPC), and the language of diplomacy is the External Data Representation (XDR).

## RPC: The Diplomatic Protocol

At the heart of NFS is the Remote Procedure Call (RPC) protocol. Instead of reading and writing blocks from a local disk, the NFS client makes RPCs to the NFS server, requesting it to perform filesystem operations on its behalf. These are requests like "read from this file", "write to this directory", or "get the attributes of this file".

The `rfscall` function in `nfs_subr.c` is the heart of the SVR4 NFS client's RPC mechanism. It is responsible for packaging up a request, sending it to the server, and waiting for a reply. It handles the complexities of network timeouts and retransmissions, ensuring that the diplomatic cable reaches its destination.

## XDR: The Language of Diplomacy

To ensure that diplomatic cables can be understood by all parties, regardless of their native computer architecture, they must be written in a standardized, machine-independent language. This is the role of the External Data Representation (XDR). XDR specifies a standard way to represent data types like integers, strings, and arrays, so that a machine with a big-endian byte order can communicate seamlessly with a machine with a little-endian byte order.

The `nfs_xdr.c` file contains the XDR routines for all the NFS data structures. These functions are responsible for encoding and decoding the arguments and results of the RPC calls, translating between the kernel's internal data structures and the standardized format used on the wire.

## The `rnode`: The Ambassador's Dossier

For each remote file that the client is accessing, it maintains an `rnode` (remote inode). This is the ambassador's dossier on that file, a local repository of all the information needed to interact with it. The `rnode` contains the file handle (the server's unique identifier for the file), the file's attributes, and other client-side state.

The file handle is the key to the entire system. It is an opaque identifier that the client uses to tell the server which file it wants to operate on. The `makenfsnode` function in `nfs_subr.c` is responsible for creating a new `rnode` and its associated vnode when the client first accesses a remote file.

## The `biod` Daemons: The Queen's Messengers

To improve performance, the NFS client employs a team of dedicated Queen's Messengers, the `biod` (block I/O daemon) processes. When an application performs a write to an NFS file, the data is not immediately sent to the server. Instead, it is placed in a buffer, and the `biod` daemon is woken up to perform the write asynchronously. This allows the application to continue its work without waiting for the slow, trans-continental journey of the diplomatic cable.

The `async_daemon` function in `nfs_vnops.c` is the code that the `biod`s execute. They sleep, waiting for work, and when they are woken, they take a buffer from a queue and send it to the server via an RPC call.

<br/>

> **The Ghost of SVR4:**
>
> "Our Foreign Office was a marvel of its time, a system that made the resources of a foreign power appear as if they were our own. But our diplomacy was based on trust. The NFS version 2 protocol, which we spoke, had no strong concept of security. The server, for the most part, simply trusted that the client was who it claimed to be. In your time, you have learned the hard way that such trust is often misplaced. Your later versions of NFS, with their support for Kerberos and other strong authentication mechanisms, are a testament to this lesson. You have also learned the value of state. Our NFS was stateless, a design that prized simplicity and robustness, but which came at a cost in performance. Your modern distributed filesystems, with their complex locking protocols and caching strategies, have embraced state in a way that we would have found both fascinating and terrifying."

## Conclusion

The NFS client is a masterpiece of abstraction, a complex system of protocols and daemons that work together to create a simple illusion: that a file on a remote machine is just another file. It is the Foreign Office of the kernel, a tireless diplomat that extends the boundaries of the local filesystem across the network, making the resources of the entire Empire available to every citizen, no matter where they may reside.