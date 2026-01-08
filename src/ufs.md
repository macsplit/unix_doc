# Unix File System (UFS)

## Overview: The Grand Library and its Index

The Unix File System (UFS) is the Grand Library of the SVR4 kernel, a meticulously organized repository for the Empire's vast collection of data. In this library, files are the books, and the directories are the various reading rooms and sections where these books are organized. The librarians are the UFS kernel code, tasked with managing this collection, locating books upon request, and finding space on the shelves for new acquisitions.

At the heart of this library is the card catalog, a vast and detailed index known as the inode table. Each book in the library has a corresponding card in this catalog, and it is this card, not the book's title or its position on a shelf, that is its ultimate identity. This is the fundamental principle of UFS: files are inodes, and the directory hierarchy is merely a convenient and user-friendly way of giving these inodes names.

## The Superblock: The Librarian's Master Ledger

Every UFS filesystem is governed by its superblock, a master ledger located at a fixed position on the disk. This is the head librarian's desk, the central point of control and information for the entire library. The `fs` structure holds this critical information.

A copy of the superblock is replicated in each cylinder group, a crucial redundancy that allows the librarians to rebuild the library's master plan in the event that the primary copy is lost or damaged.

## Inodes: The Card Catalog

The inode is the fundamental data structure in UFS, the card in the catalog that describes a file. Each inode contains all the metadata about a file, with the notable exception of its name, which is stored in a directory file.

![UFS Inode](3.1-ufs-inode.png)
*The UFS Inode Structure*

The key information on each card includes:

*   **Mode and Type**: The type of the file (regular file, directory, symbolic link, etc.) and its access permissions.
*   **Link Count**: The number of directory entries (names) that refer to this inode. When this count drops to zero, the file is deleted.
*   **Owner and Group**: The user and group IDs of the file's owner.
*   **Size**: The size of the file in bytes.
*   **Timestamps**: The last access, modification, and inode change times.
*   **Block Pointers**: A set of pointers to the data blocks that hold the file's contents. These are divided into direct blocks, single indirect blocks, double indirect blocks, and triple indirect blocks, a scheme that allows for both fast access to small files and the ability to address very large files.

The `ufs_iget` function in `ufs_inode.c` is the librarian responsible for finding a specific card in the catalog, reading an inode from disk into memory.

## Cylinder Groups: The Library's Wings

A key innovation of the Berkeley Fast File System (FFS), from which UFS is derived, is the concept of cylinder groups. A large disk is divided into a number of these groups, each of which is a miniature filesystem in its own right, with its own set of inodes, data blocks, and a copy of the superblock.

This design is akin to organizing a vast library into a series of smaller, self-contained wings. Each wing has its own shelves (data blocks) and its own section of the card catalog (inodes). The goal is to keep the books and the catalog cards that describe them in the same wing, minimizing the distance the librarians have to travel. In disk terms, this translates to keeping a file's data blocks and its inode in the same cylinder group, reducing the seek time of the disk head and dramatically improving performance.

## Block Allocation: Reshelving the Books

When a file grows, the UFS librarians must find new shelf space for it. The `ufs_alloc` function in `ufs_alloc.c` is responsible for this task. It uses the summary information in the cylinder group structures to make intelligent decisions about where to place new blocks.

The allocation policy attempts to keep all the blocks of a file in the same cylinder group. If this is not possible, it will choose a new cylinder group, preferably one with a higher-than-average number of free blocks, to start a new "cluster" of blocks for the file. This strategy of localization is the key to UFS's performance.

<br/>

> **The Ghost of SVR4:**
>
> "Our Grand Library was a marvel of its time, a carefully designed system for the orderly storage and retrieval of information. But it was a fragile place. A sudden loss of power during a busy day of reshelving could leave the catalog in a state of disarray, requiring the painstaking efforts of the `fsck` program, our head catalog-keeper, to restore order. Your modern filesystems, with their 'journaling', are a different breed. They are like librarians who keep a meticulous log of every intended change before they make it. If the lights go out, they simply consult their log to quickly restore the library to a consistent state. And your 'copy-on-write' filesystems like ZFS are even more remarkable. They never change a book once it is written; they simply write a new, updated version in a new location and update the catalog to point to it. It is a world of incredible resilience, a world that we, with our delicate, in-place modifications, could only dream of."

## Conclusion

UFS, as implemented in SVR4, is a classic, BSD-derived filesystem, a testament to the power of good design and the principle of locality. It is a well-organized library, with a detailed catalog, a clear layout, and a set of intelligent librarians working to keep everything in its proper place. While it may lack the resilience and advanced features of its modern descendants, it was a reliable and performant workhorse for its time, the foundation upon which the SVR4 system was built.