# Executable Formats: The Master Artisan's Workshop

Consider a master artisan in his workshop, a place of profound knowledge and skill. Upon his workbench is placed a complex automaton, a marvel of brass and clockwork, brought to him to be animated. The artisan does not simply wind it up; he knows that different makers use vastly different mechanisms. One might use steam pressure, another a series of descending weights, and a third a tightly coiled spring. To attempt to wind a steam-powered automaton would be folly.

Instead, the artisan first peers at the base of the machine, searching for a small, inscribed *maker's mark* or *magic number*. Upon finding it, he turns to a great wooden cabinet that lines the wall of his workshop. This cabinet contains many drawers, each labeled with the mark of a known maker. Inside each drawer is a specific set of tools and instructions—a `execsw` entry—perfectly suited to animating a machine from that particular maker. By matching the mark to the drawer, the artisan selects the correct tools and brings the automaton to life.

This is precisely the challenge and the solution employed by the SVR4 kernel when faced with the `exec()` system call. The kernel is a master artisan, and the various binary files it may be asked to execute—COFF, ELF, or even interpreted scripts—are the automata. It cannot assume a single method of activation. Instead, it relies on a modular system to identify and delegate the task to a specialized handler for that specific executable format.

<br/>

## The Cabinet of Toolsets: `struct execsw`

The kernel's "cabinet of toolsets" is the **executable switch table**, `execsw`, an array of `execsw` structures defined in `sys/exec.h`. This table is the kernel's registry of all known executable types. Each entry represents a complete, self-contained "toolset" for one format.

**The Artisan's Toolset Drawer** (sys/exec.h:48):
```c
struct execsw {
	short *exec_magic;
	int   (*exec_func)();
	int   (*exec_core)();
};

extern int nexectype;
extern struct execsw execsw[];
```

Each entry in the `execsw` array is elegantly simple, containing three essential items:
- **`exec_magic`**: A pointer to the "maker's mark," a short integer (or array of integers) that uniquely identifies the binary format. For an ELF file, this is the number `0x7f45` (the characters `\177ELF`). For a COFF file, it is `0514` (octal).
- **`exec_func`**: A function pointer to the specific "artisan" who knows how to read, map, and prepare this type of executable. This is the heart of the mechanism, pointing to a function like `elfexec()` or `coffexec()`.
- **`exec_core`**: A function pointer to a routine that knows how to generate a core dump file in this specific format, should the process meet an untimely end.

The kernel maintains a global array, `execsw[]`, and a count of its entries, `nexectype`. The `exec()` logic need not know the details of any format; it must only know how to consult this table.

<br/>

![Executable Formats - Customs House](cartoons/executable-formats-cartoon.png)
**Executable Formats - Customs House**

## The Master Artisan's Method: `gexec()`

The master artisan who presides over this process is the `gexec()` function, found in `os/exec.c`. When a user calls `exec()`, the generic system call logic performs initial setup (locating the file, checking basic permissions) and then hands control to `gexec()` to perform the magic.

`gexec()`'s method is a disciplined traversal of the `execsw` cabinet.

**The `gexec` Ritual** (os/exec.c:380, simplified):
```c
int
gexec(vpp, args, level, execsz)
	struct vnode **vpp;
	struct uarg *args;
	int level;
	long *execsz;
{
	/* ... variable setup ... */
	
	/* Read the first few bytes of the file to get the magic number */
	if ((error = exhd_getmap(&ehda, 0, 2, EXHD_NOALIGN, (caddr_t)&mcp)) != 0) {
		exhd_release(&ehda);
		goto closevp;
	}
	magic = getexmag(mcp);

	/* ... permission and setuid checks ... */

	error = ENOEXEC;
	for (i = 0; i < nexectype; i++) {
		if (execsw[i].exec_magic && magic != *execsw[i].exec_magic)
			continue; /* This is not the right toolset, try the next */

		u.u_execsw = &execsw[i];
		/* We found a match! Invoke the specialist function. */
		error = (*execsw[i].exec_func)
				  (vp, args, level, execsz, &ehda, setid);

		if (error != ENOEXEC)
			break; /* Success or a fatal error, our work is done. */
	}

	/* ... cleanup ... */

	return error;
}
```

The procedure is methodical:
1.  **Read the Maker's Mark**: `gexec` first reads the first two bytes of the file to retrieve its `magic` number.
2.  **Consult the Cabinet**: It then enters a loop, iterating through every drawer (`execsw` entry) from `0` to `nexectype`.
3.  **Find the Right Toolset**: In each iteration, it compares the file's magic number with the `exec_magic` number for that toolset. If they do not match, it `continue`s to the next drawer.
4.  **Delegate to the Specialist**: When a match is found, it calls the specialist function pointed to by `exec_func` (e.g., `elfexec`), passing it the file's vnode and user arguments.
5.  **Assess the Result**: If the specialist returns `ENOEXEC`, it means that despite the matching magic number, it was not a valid executable of that type (perhaps a corrupted file or a non-executable object file). `gexec` will then continue its search. If any other error (or success) is returned, the loop is broken.

<br/>

## The Specialized Toolsets: `elfexec` and `coffexec`

The functions `elfexec()` (in `exec/elf/elf.c`) and `coffexec()` (in `exec/coff/coff.c`) are the specialist artisans. Once invoked by `gexec`, their job is to understand the intricate internal structure of their respective formats.

They are responsible for:
- Reading the file's main header, program headers, and section headers.
- Mapping the text and data segments into the process's address space using `execmap()`.
- Handling requests for shared libraries, a complex dance of its own.
- Preparing the initial stack frame for the new process.
- Ultimately, preparing the `execenv` structure that tells the kernel how the new process image is laid out in memory.

This division of labor is the key to the system's extensibility. To add a new executable format to the kernel, a programmer would only need to write a new `myformatexec()` function and add a new entry to the `execsw` table, with no changes required to the core `gexec` logic.

---

> #### **The Ghost of SVR4: A Self-Describing Workshop**
>
> Our `execsw` table was a fine piece of engineering, but it was a static affair. The cabinet of toolsets was built, polished, and sealed at the factory—that is, when the kernel was compiled. To add support for a new executable format, one had to be a kernel artisan oneself, adding the new toolset to the master `conf.c` file and forging an entirely new kernel. This was a high barrier to entry, reserved for the most dedicated of engineers.
>
> **Modern Contrast (2026):** The workshop of a 2026 Linux kernel is a far more dynamic and magical place. The `execsw` concept has evolved into `binfmt_misc`, a "miscellaneous binary format" handler. This is not a static, compiled-in table, but a fully dynamic interface exposed through the `/proc` filesystem. A system administrator, without even touching a compiler, can simply `echo` a specially formatted string into `/proc/sys/fs/binfmt_misc/register` to teach the kernel about a new executable type.
>
> This string acts as a recipe, telling the kernel: "If you see a file whose first few bytes match this magic number (or whose filename ends in this extension, e.g., `.py`), do not try to load it yourself. Instead, invoke this user-space interpreter program (e.g., `/usr/bin/python`) and pass it the executable's path as an argument." This has allowed Linux to seamlessly execute Java JAR files, Python scripts, and even Windows `.exe` files via Wine, all without a single change to the core kernel code. The artisan's cabinet is no longer sealed; it is an open book, and any user with sufficient privilege can add a new chapter.

---

<br/>

## Conclusion: The Wisdom of Delegation

The `exec()` mechanism in SVR4 demonstrates a powerful design pattern: the dispatch table. By separating the generic task of *identifying* a format from the specific task of *interpreting* it, the kernel remains agile and extensible. The master artisan, `gexec`, does not need to be an expert in every type of automaton; he only needs to be an expert in identifying the maker's mark and delegating to the appropriate specialist.

This clear separation of concerns, embodied in the `execsw` table, allowed SVR4 to support both the legacy COFF and the modern ELF formats side-by-side, providing a smooth transition during a critical period in UNIX history. It created a workshop where new toolsets could be added with minimal disruption, ensuring that the kernel could adapt to new and unforeseen types of clockwork automata for years to come.
