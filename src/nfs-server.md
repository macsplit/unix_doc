# NFS Server

## Overview: The Colonial Office

If the NFS client is the Foreign Office, then the NFS server is the Colonial Office, the powerful administrative body responsible for governing the Empire's overseas territories and granting access to accredited foreign representatives. The Colonial Office is the guardian of the local filesystem, serving its data to the network while strictly enforcing the access policies of the Crown.

The office receives a constant stream of diplomatic cables (RPC requests) from Foreign Offices around the world. Each cable is a request to perform some action in one of the Crown's territories: to read a document, to establish a new outpost, or to consult the public records. The clerks of the Colonial Office (the `nfsd` daemons) are responsible for processing these requests, but only after carefully vetting the credentials of the representative who sent them.

## The `exports` Table: The List of Crown Territories

Not all of the Empire's territories are open to foreigners. The `/etc/exports` file is the official list of Crown Territories—the filesystems that are made available to the network. For each territory, the list specifies the rules of engagement: which foreign powers are granted access, and what level of access they are permitted.

In the kernel, this information is stored in a list of `exportinfo` structures. When a request arrives, the server consults this list to ensure that the requested file or directory is part of an exported filesystem and that the client has the right to access it. The `findexport` function in `nfs_export.c` is responsible for this lookup.

## The `nfsd` Daemons: The Colonial Office Clerks

The `nfsd` daemons are the tireless clerks of the Colonial Office. These are user-level processes that are created at system startup and then enter the kernel to do their work. They are the ones who actually process the incoming RPC requests.

When a request arrives, it is handed off to one of the waiting `nfsd` clerks. The clerk decodes the request, performs the requested operation by calling the appropriate VFS and filesystem functions, and then sends a reply back to the client. The `rfs_dispatch` function in `nfs_server.c` is the central dispatch routine that directs the incoming requests to the appropriate service procedures.

## Authentication: Checking Credentials

Before any request is processed, the Colonial Office must first check the credentials of the diplomat who sent it. In the world of NFSv2, this is a relatively simple affair. The most common form of authentication is `AUTH_UNIX`, where the client simply asserts the user and group IDs of the user making the request. The server, for the most part, trusts the client to be telling the truth.

SVR4 also supports the more secure `AUTH_DES`, which uses DES encryption to provide a much stronger guarantee of the client's identity. The `checkauth` function in `nfs_server.c` is responsible for this critical step.

## File Handles: The Queen's Seal

To access a file in one of the Crown's territories, a foreign representative must present a document bearing the Queen's Seal. This is the file handle, an opaque identifier that uniquely identifies a file or directory on the server. The file handle is constructed from the filesystem ID and the file's inode number and generation number.

When a client performs a lookup on a file, the server returns a file handle. The client then uses this file handle in all subsequent requests for that file. The `makefh` function in `nfs_export.c` is responsible for creating these seals of authenticity.

<br/>

> **The Ghost of SVR4:**
>
> "Our Colonial Office was a product of its time, a time of open protocols and assumed trust. We could not have foreseen a world where the network would be such a hostile place. Your modern storage systems, with their end-to-end encryption and their complex, multi-factor authentication schemes, are a response to this new reality. And our simple model of exporting filesystems has been supplanted by new paradigms. Your object stores, with their simple `PUT` and `GET` operations, and your modern, clustered filesystems, which distribute data across hundreds or even thousands of machines, are a far cry from our humble `nfsd`s, serving up files from a single, monolithic kernel."

![NFS Server - Central Warehouse](cartoons/nfs-server-cartoon.png)
**NFS Server - Central Warehouse**

## Conclusion

The NFS server in SVR4 is a classic example of a client-server system, a well-defined protocol for sharing files across a network. It is the Colonial Office to the client's Foreign Office, the guardian of the local filesystem, and the gatekeeper to its resources. While its security model may be dated and its performance limited by its stateless design, it was a robust and reliable system that laid the foundation for the distributed computing environments of the future.