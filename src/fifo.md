# FIFO File System: The Whispering Gallery

Picture, if you will, a grand Victorian-era mansion with an intricate network of corridors and chambers. In one such chamber, there exists a peculiar device known as the "Whispering Gallery." This gallery is lined with curved walls that carry sound from one end to the other, allowing a whisper spoken at one point to be heard clearly at the opposite end. The Whispering Gallery serves as a metaphor for the FIFO (First-In-First-Out) File System in the SVR4 kernel—a mechanism that allows processes to communicate through named pipes.

In this system, data written by one process into a FIFO can be read by another process, much like a whispered message traveling along the curved walls of the gallery. The FIFO ensures that the order of messages is preserved, just as the Whispering Gallery preserves the sequence of whispers.

<br/>

## Creating FIFOs with `mknod()`

In the SVR4 kernel, FIFOs are created using the `mknod()` system call. This call creates a special file in the filesystem that acts as a named pipe. The `mknod()` function is responsible for setting up the necessary data structures and marking the file as a FIFO.

```c
int mknod(const char *pathname, mode_t mode, dev_t dev);
```
**The `mknod()` Function** (sys/mkdev.h:123)

The `mknod()` function takes three parameters:
- **`pathname`**: The path to the FIFO file.
- **`mode`**: The file type and permissions. For a FIFO, this includes the `S_IFIFO` flag.
- **`dev`**: This parameter is ignored for FIFOs.

When `mknod()` is called with the appropriate mode flags, it creates a special entry in the filesystem that represents the FIFO.

<br/>

## Opening FIFOs with `fifo_open()`

Once a FIFO is created, processes can open it using the `open()` system call. The kernel internally invokes the `fifo_open()` function to handle the opening of FIFO files.

**The `fifo_open()` Function** (fs/fifo.c:150):
```c
int fifo_open(struct vnode *vp, int mode) {
    struct fifoinfo *fip;
    if ((fip = getfifoinfo(vp)) == NULL) {
        return ENOMEM;
    }
    if (mode & FREAD) {
        fip->fi_readers++;
    }
    if (mode & FWRITE) {
        fip->fi_writers++;
    }
    return 0;
}
```

The `fifo_open()` function performs the following steps:
- **Retrieve FIFO Info**: It retrieves or allocates a `fifoinfo` structure associated with the vnode.
- **Increment Counters**: It increments the reader and/or writer counters based on the open mode.

<br/>

## Reading from FIFOs with `fifo_read()`

Processes read data from a FIFO using the `read()` system call. The kernel internally invokes the `fifo_read()` function to handle the reading operation.

**The `fifo_read()` Function** (fs/fifo.c:200):
```c
ssize_t fifo_read(struct vnode *vp, struct uio *uio) {
    struct fifoinfo *fip = getfifoinfo(vp);
    if (fip->fi_writers == 0 && fip->fi_size == 0) {
        return 0; // End of file
    }
    ssize_t bytes_read = min(uio->uio_resid, fip->fi_size);
    copyout(fip->fi_buffer + fip->fi_head, uio->uio_iov->iov_base, bytes_read);
    fip->fi_head += bytes_read;
    fip->fi_size -= bytes_read;
    return bytes_read;
}
```

The `fifo_read()` function performs the following steps:
- **Check Writers**: If there are no writers and the buffer is empty, it returns 0 (end of file).
- **Read Data**: It reads data from the buffer into the user's buffer.
- **Update Pointers**: It updates the head pointer and size of the buffer.

<br/>

## Writing to FIFOs with `fifo_write()`

Processes write data to a FIFO using the `write()` system call. The kernel internally invokes the `fifo_write()` function to handle the writing operation.

**The `fifo_write()` Function** (fs/fifo.c:250):
```c
ssize_t fifo_write(struct vnode *vp, struct uio *uio) {
    struct fifoinfo *fip = getfifoinfo(vp);
    if (fip->fi_readers == 0) {
        return EPIPE; // No readers
    }
    ssize_t bytes_written = min(uio->uio_resid, FIFO_SIZE - fip->fi_size);
    copyin(uio->uio_iov->iov_base, fip->fi_buffer + fip->fi_tail, bytes_written);
    fip->fi_tail += bytes_written;
    fip->fi_size += bytes_written;
    return bytes_written;
}
```

The `fifo_write()` function performs the following steps:
- **Check Readers**: If there are no readers, it returns `EPIPE` (broken pipe).
- **Write Data**: It writes data from the user's buffer into the FIFO buffer.
- **Update Pointers**: It updates the tail pointer and size of the buffer.

<br/>

## Circular Buffer Implementation

The FIFO subsystem in SVR4 uses a circular buffer to store data. This buffer is managed by the `fifoinfo` structure, which includes pointers to the head and tail of the buffer, as well as the current size of the data stored.

**The `fifoinfo` Structure** (fs/fifo.h:50):
```c
struct fifoinfo {
    char *fi_buffer;    /* Pointer to the circular buffer */
    int fi_head;        /* Head pointer in the buffer */
    int fi_tail;        /* Tail pointer in the buffer */
    int fi_size;        /* Current size of data in the buffer */
    int fi_readers;     /* Number of active readers */
    int fi_writers;     /* Number of active writers */
};
```

The circular buffer allows for efficient reading and writing operations, ensuring that data is preserved in the order it was written.

<br/>

> **The Ghost of SVR4:** In 1990, the FIFO subsystem provided a simple yet effective mechanism for inter-process communication using named pipes. By 2026, Linux's FIFOs offer similar functionality but with enhanced features such as better error handling and integration with modern filesystem operations. The core principle remains: a circular buffer in kernel memory, allowing processes to communicate through a shared pipe.

<br/>

## Conclusion

Returning to our Victorian mansion metaphor, the FIFO subsystem in SVR4 is akin to the Whispering Gallery—a mechanism that allows messages to travel from one process to another with precision and order. Just as whispers echo along the curved walls of the gallery, data written by one process can be read by another, preserving the sequence of information.

The elegance of this design lies in its simplicity and efficiency, allowing for seamless inter-process communication within the SVR4 kernel.
