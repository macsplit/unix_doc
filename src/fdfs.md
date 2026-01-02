# File Descriptor File System

Imagine, if you will, a grand Victorian-era office where every document and correspondence is meticulously organized within a labyrinthine filing system. Each file drawer contains not only the original documents but also reflective mirrors that allow one to see into other drawers. This system of mirrors ensures that any document can be cross-referenced with others, creating an intricate web of interconnected information.

The File Descriptor File System (FDFS) in the SVR4 kernel operates much like this office. It provides a mechanism for processes to access file descriptors as if they were files themselves, allowing for seamless integration and manipulation within the filesystem.

<br/>

## Accessing File Descriptors via `/dev/fd/N`

In the SVR4 kernel, the FDFS subsystem allows processes to access their file descriptors through a special directory structure located at `/dev/fd`. Each entry in this directory corresponds to an open file descriptor of the process. For example, accessing `/dev/fd/0` would refer to the standard input (stdin) of the process.

<br/>

## The `fdfsget()` Function

When a process attempts to access a file descriptor via the FDFS, the kernel invokes the `fdfsget()` function. This function is responsible for parsing the numeric name provided in the pathname and creating a vnode that represents the corresponding file descriptor.

**The `fdfsget()` Function** (fs/fdfs/fdops.c:123):
```c
int fdfsget(struct vnode *vp, char *name, struct vnode **vpp) {
    int fd;
    if (!isdigit(name[0])) {
        return ENOENT;
    }
    fd = atoi(name);
    if (fd < 0 || fd >= curproc->p_fd->fd_nfiles) {
        return EBADF;
    }
    *vpp = vn_make(fd, VDUP);
    return 0;
}
```

The `fdfsget()` function performs the following steps:
1. **Parse the Name**: It checks if the name is a digit and converts it to an integer.
2. **Validate the File Descriptor**: It ensures that the file descriptor is within the valid range for the process.
3. **Create Vnode**: It creates a vnode with the `VDUP` flag, indicating that this vnode duplicates an existing file descriptor.

<br/>

## Vnode Creation and the VDUP Flag

The creation of vnodes in FDFS is unique due to the use of the `VDUP` flag. This flag indicates that the vnode does not represent a new file but rather a duplicate reference to an existing file descriptor. This mechanism allows processes to manipulate file descriptors as if they were regular files, facilitating operations such as redirection and sharing.

**The Vnode Creation Process** (fs/fdfs/fdops.c:150):
```c
struct vnode *vn_make(int fd, int flags) {
    struct vnode *vp;
    vp = getnewvnode(VT_NON);
    if (flags & VDUP) {
        vp->v_fd = curproc->p_fd->fd_ofiles[fd];
        VN_HOLD(vp->v_fd);
    }
    return vp;
}
```

The `vn_make()` function, when called with the `VDUP` flag, performs the following:
1. **Allocate Vnode**: It allocates a new vnode structure.
2. **Duplicate File Descriptor**: It sets the vnode's file descriptor to point to the existing file descriptor and increments its reference count.

<br/>

## Fake Directory with Entries "0", "1", "2" etc.

The FDFS subsystem maintains a fake directory that contains entries corresponding to each open file descriptor of the process. These entries are named as numeric strings ("0", "1", "2", etc.), representing standard input, output, and error respectively. This fake directory structure allows processes to interact with their file descriptors using familiar filesystem operations.

<br/>

> **The Ghost of SVR4:** In 1990, the FDFS subsystem provided a clever mechanism for accessing file descriptors as files, leveraging the existing filesystem infrastructure. By 2026, Linux's `/proc/self/fd` symlinks offer a more sophisticated and flexible approach, allowing processes to access their file descriptors through symbolic links that point directly to the open file table entries.

<br/>

## Conclusion

Returning to our Victorian office metaphor, the FDFS subsystem in SVR4 is akin to a system of reflective mirrors within a filing cabinet. Each mirror allows one to see into other drawers, facilitating cross-referencing and seamless access to information. Similarly, FDFS provides processes with a mechanism to access their file descriptors as if they were files, leveraging the existing filesystem infrastructure to create an intricate web of interconnected resources.

The elegance of this design lies in its simplicity and efficiency, allowing for seamless integration and manipulation of file descriptors within the SVR4 kernel.
