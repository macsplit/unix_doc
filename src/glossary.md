# Glossary

**Operating System (OS)**
:   Software that manages computer hardware and software resources and provides common services for computer programs.

**Unix**
:   A family of multitasking, multi-user computer operating systems that derive from the original AT&T Unix.

**Kernel**
:   The core component of an operating system, managing system resources and acting as a bridge between hardware and applications.

**Process**
:   An instance of a computer program that is being executed. It contains the program code and its current activity.

**Process ID (PID)**
:   A unique identifier assigned to each process by the operating system kernel.

**Fork**
:   A system call that creates a new process (child process) by duplicating an existing process (parent process).

**Exec**
:   A family of system calls that loads and executes a new program within the context of an existing process.

**Zombie Process**
:   A process that has completed execution but still has an entry in the process table to allow its parent process to read its exit status.

**Orphan Process**
:   A process whose parent has terminated without waiting for the child to exit. Orphaned processes are adopted by the `init` process.

**Context Switch**
:   The process of storing the state of a process or thread, so that it can be restored and resume execution later.

**Scheduler**
:   The part of the operating system that selects which ready process will be executed by the CPU next.

**System Call**
:   A programmatic way in which a computer program requests a service from the kernel of the operating system.

**Virtual Memory**
:   A memory management technique that provides an idealized abstraction of the storage resources that are actually available on a given machine, making it seem like a process has continuous, private memory.

**Physical Memory**
:   The actual RAM (Random Access Memory) installed in the computer, directly accessible by the CPU.

**Page**
:   A fixed-size block of virtual memory.

**Page Frame**
:   A fixed-size block of physical memory, typically the same size as a virtual memory page.

**Paging**
:   The process of moving data between physical memory and secondary storage (like a hard drive) in fixed-size blocks (pages).

**Swap Space**
:   A dedicated area on a hard disk used as an extension of physical memory when RAM is full.

**Address Space**
:   The range of memory addresses that a process can refer to. For a virtual memory system, this is the virtual address space.

**Memory Management Unit (MMU)**
:   A hardware component that translates virtual memory addresses used by the CPU into physical memory addresses.

**File System**
:   A method and data structure that an operating system uses to control how data is stored and retrieved on storage devices.

**Inode**
:   A data structure in a Unix-style file system that describes a file-system object such as a file or a directory. It stores metadata about the file.

**File Descriptor**
:   An abstract indicator (handle) used to access a file or other input/output resource, such as a pipe or network socket.

**VFS (Virtual File System)**
:   An abstraction layer on top of a more concrete file system. The purpose of VFS is to allow client applications to access different types of concrete file systems in a uniform way.

**Mount Point**
:   A directory in a file system where another file system is attached.

**Buffer Cache**
:   A region of main memory used by the operating system to store frequently accessed disk blocks, improving I/O performance.

**Networking Stack**
:   A set of network protocol layers that work together to provide network communication services.

**Socket**
:   An endpoint of a communication flow across a computer network. Sockets provide a standardized way for applications to send and receive data.

**TCP (Transmission Control Protocol)**
:   A core protocol of the Internet Protocol Suite, providing reliable, ordered, and error-checked delivery of a stream of octets between applications.

**UDP (User Datagram Protocol)**
:   A minimal, connectionless protocol that provides an unreliable, unordered, and non-guaranteed delivery of data between applications.

**IP (Internet Protocol)**
:   The primary protocol in the Internet Layer of the Internet Protocol Suite, used for delivering datagrams (packets) across network boundaries.

**Signal**
:   A limited form of inter-process communication (IPC) used in Unix-like operating systems to notify a process about an event.

**Interrupt**
:   A signal to the processor emitted by hardware or software indicating an event that needs immediate attention.

**Device Driver**
:   A computer program that operates or controls a particular type of device that is attached to a computer.

**I/O (Input/Output)**
:   The communication between an information processing system and the outside world, e.g., reading from a keyboard or writing to a screen.

**DMA (Direct Memory Access)**
:   A feature of computer systems that allows certain hardware subsystems to access main system memory (RAM) independently of the central processing unit (CPU).

**Boot Process**
:   The sequence of operations that a computer performs from power-on until it is ready to execute user applications.

**Semaphore**
:   A variable or abstract data type used to control access to a common resource by multiple processes and avoid critical section problems.

**Message Queue**
:   A form of asynchronous inter-process communication where processes exchange messages by passing them through a queue.

**Shared Memory**
:   A method of inter-process communication that allows multiple processes to access the same region of memory, enabling efficient data exchange.