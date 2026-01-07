# Character I/O: A Pneumatic Tube Telegraph

Imagine, if you will, a sprawling government ministry in the age of steam and brass. To convey memoranda, forms, and directives between its myriad departments, the architects have installed a magnificent and intricate **pneumatic tube system**. An urgent request, sealed in a brass canister, is dispatched from the Foreign Office; it travels through a branching network of tubes to the Records Department, where a clerk retrieves it, appends the necessary file, and sends it on to the Ministerial Secretariat for approval. The canister's journey is not fixed; it can be routed through any number of intermediate departments, each of which may inspect, modify, or add to its contents.

This, in essence, is the philosophy of the SVR4 **Character I/O subsystem**, which is built almost entirely upon the elegant and powerful **STREAMS** framework. Where the [Block I/O Subsystem](./block-io.md) deals with large, uniform blocks of data like a freight railway, Character I/O deals with streams of data of arbitrary length and format, like our versatile pneumatic tubes. It is the mechanism that drives terminals, network connections, and other byte-oriented devices, providing a flexible, modular framework for processing data as it flows between user processes and the hardware.

A "Stream" is the data path between a user process and a device driver. This path is constructed by linking together a series of processing modules, each a two-way junction in our tube network. Data, encapsulated in messages, flows up and down this chain, processed at each stage according to the module's function.

<br/>

## The Grand Directory of Stations: `cdevsw`

At the heart of the Character I/O system lies a grand directory, a master list of every "station" in the pneumatic tube network. This is the **Character Device Switch**, or `cdevsw`, an array defined in `sys/conf.h`. Each entry in this table represents a character device driver, providing the kernel with the initial entry points to establish a new Stream.

**The Character Device Switch** (sys/conf.h:31):
```c
struct cdevsw {
	int	(*d_open)();
	int	(*d_close)();
	int	(*d_read)();
	int	(*d_write)();
	int	(*d_ioctl)();
	int	(*d_mmap)();
	int	(*d_segmap)();
	int	(*d_poll)();
	/* ... fields omitted for brevity ... */
	struct streamtab *d_str;
	char	*d_name;
	int	*d_flag;
};
```

When a process opens a character device file, the kernel consults this table using the device's major number as an index. While there are pointers for direct `read` and `write` functions, for a STREAMS device, the most crucial field is `d_str`. If this pointer is not null, it signals that this device is a portal to the STREAMS framework. The kernel then uses the `streamtab` structure it points to for constructing the initial tube connection to the device driver.

<br/>

## The Blueprints of a Tube Line: `streamtab` and `queue`

The `d_str` field in `cdevsw` points to a `streamtab` structure, the blueprint for a STREAMS module or driver. It defines the processing procedures for both the upstream (read-side) and downstream (write-side) flow of data.

**The Stream Blueprint** (sys/stream.h:182):
```c
struct streamtab {
	struct qinit *st_rdinit;
	struct qinit *st_wrinit;
	struct qinit *st_muxrinit;
	struct qinit *st_muxwinit;
};
```
This structure simply points to two `qinit` structures, one for the read queue (`st_rdinit`) and one for the write queue (`st_wrinit`). The `qinit` structure, in turn, contains the function pointers that do the actual work.

The fundamental unit of a Stream is the **queue**. Every module, and indeed the stream head and driver, consists of a pair of queues: a read queue for data flowing upstream (from the device to the user) and a write queue for data flowing downstream.

**The Clerk's Workstation: `struct queue`** (sys/stream.h:55):
```c
struct	queue {
	struct	qinit	*q_qinfo;	/* procs and limits for queue */
	struct	msgb	*q_first;	/* first data block */
	struct	msgb	*q_last;	/* last data block */
	struct	queue	*q_next;	/* Q of next stream */
	struct	queue	*q_link;	/* to next Q for scheduling */
	_VOID		*q_ptr;		/* to private data structure */
	ulong		q_count;	/* number of bytes on Q */
	ulong		q_flag;		/* queue state */
	/* ... water marks and packet sizes ... */
};
```
Each queue acts as a clerk's workstation. It has:
- **`q_qinfo`**: A pointer to the `qinit` structure, defining the procedures this clerk knows how to perform.
- **`q_first`, `q_last`, `q_count`**: The message queue itself—the clerk's inbox.
- **`q_next`**: A pointer to the *next* queue in the stream. This is the crucial link that determines where to send the canister next.
- **`q_ptr`**: A private data pointer for the module to maintain its own state.

When a Stream is first opened, it consists of a **stream head** (the kernel's interface to the user process) connected directly to the **stream driver** (the kernel's interface to the hardware). Later, processing modules can be "pushed" onto the Stream, inserting them between the head and the driver, creating a processing pipeline of arbitrary complexity.

<br/>

## Sending a Canister: Message Passing with `putnext()`

Data and control information travel through a Stream in the form of messages (`mblk_t`). A message is a linked list of blocks, allowing for efficient, zero-copy processing. When a module's clerk has finished with a message, he does not need to know the intricate details of the entire tube network. He simply invokes `putnext()`.

The `putnext` macro is a masterpiece of indirection:
`#define putnext(q, mp)	((*(q)->q_next->q_qinfo->qi_putp)((q)->q_next, (mp)))`

It is a simple yet powerful instruction: "Take this message (`mp`), look at *my* `q_next` pointer to find the next station, and deliver it to that station's `put` procedure." This single mechanism allows for the seamless flow of data through the chain of modules. Each module only needs to know about its immediate neighbor, allowing for a highly modular and extensible system. A terminal line discipline module can be pushed, followed by a JSON parsing module, followed by a data logging module, all without any module needing specific knowledge of the others.

---

> #### **The Ghost of SVR4: The Decline of a Grand Design**
>
> Ah, STREAMS. It was a grand, unifying theory. A single, beautiful framework intended to solve all of character I/O, from serial ports to the most complex networking protocols. We believed it was the future. Every character device, every TTY, every network interface was a stream. The modularity was intoxicating; one could construct intricate processing pipelines on the fly. We built TCP/IP, UDP, and even parts of the file system upon its elegant foundation.
>
> **Modern Contrast (2026):** And yet, where is STREAMS now? Vanished, a ghost in the machine. Its very generality became its downfall. The framework, while flexible, imposed a significant overhead. The constant allocation and deallocation of message blocks, the multiple function calls to traverse the queue chain—it was the bureaucracy of our pneumatic tube system made manifest. For simple cases, it was overkill. For high-performance networking, it became a bottleneck.
>
> The architects of Linux, observing from afar, chose a different path. They rejected the single, unified theory in favor of specialized, purpose-built tools. The terminal subsystem in Linux has its own intricate line discipline and TTY handling, optimized for that specific purpose. Networking is handled by the socket layer and the `netdevice` framework, which are brutally efficient and tailored for high-speed packet processing. The `struct file_operations` in a Linux character device driver now points directly to the functions that will handle I/O, with no intermediary queueing system unless the driver itself implements one. STREAMS' complexity, its many interlocking structures—`queue`, `qinit`, `mblk`, `dblk`—were deemed a liability. The grand, unified design was replaced by a pragmatic collection of disparate, but faster, mechanisms.

---

<br/>

## Conclusion: The Flexible Conduit

The Character I/O subsystem, through its embodiment of the STREAMS framework, provided SVR4 with a remarkably flexible and powerful tool. It treated all forms of character-based data flow as a journey through a dynamic network, capable of modification and extension at will. By breaking down complex processing tasks into a series of modular, interconnected clerks, it allowed for unprecedented code reuse and rapid development of new drivers and protocols.

While the performance demands of the modern era may have led to the ascendancy of more specialized subsystems, the vision of STREAMS—our pneumatic tube network—remains a compelling example of elegant design. It recognized that the journey of data is as important as its destination, and provided a framework to shape that journey with precision and modular grace.
