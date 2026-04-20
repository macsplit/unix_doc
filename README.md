# The Ghost of SVR4

A comprehensive technical guide to the SVR4 (System V Release 4) i386 kernel architecture.

## About This Book

This documentation explores the internal architecture of the SVR4 operating system, covering:

- **Process Management:** Process lifecycle, scheduling, signals, and system calls
- **Memory Management:** Virtual memory, paging, HAT layer, and segments
- **File Systems:** VFS layer, vnodes, pathname resolution, and filesystem implementations
- **Networking:** STREAMS architecture, TCP/IP stack, and NFS
- **I/O and Device Management:** Device drivers, interrupts, and boot process

## License

This repository is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

You may copy, redistribute, and adapt the material, including material produced with AI assistance, provided appropriate attribution is given.

## Repository Scope

This repository is the source for the book project itself: markdown, diagrams, theme assets, and generated book output.

- **Book repository:** <https://github.com/macsplit/unix_doc>
- **SVR4 source repository referenced by the book:** <https://github.com/calmsacibis995/svr4-src>

If a path such as `svr4-src/uts/i386/...` appears in the published text, the authoritative upstream repository to consult is `calmsacibis995/svr4-src`. The `macsplit/unix_doc` repository is not the canonical host for the original SVR4 source tree.

## Building the Book

This book uses [mdbook](https://rust-lang.github.io/mdBook/) for building:

```bash
# Build the book
mdbook build

# Serve with live reload during editing
mdbook serve

# Test the book configuration
mdbook test
```

The built HTML will be in the `book/` directory.

## Project Structure

```
unix_doc/
├── src/                # Markdown source files and images
│   ├── SUMMARY.md      # Table of contents (auto-generates navigation)
│   ├── *.md            # Chapter markdown files
│   └── *.png           # Diagram images and cartoons
├── diagrams/           # Mermaid source files for technical diagrams
│   ├── *.mmd           # Editable diagram sources
│   └── README.md       # Instructions for regenerating diagrams
├── theme/              # Custom fonts and styling
│   ├── *.ttf           # Alegreya and Space Mono fonts
│   └── custom.css      # Font configuration
├── book.toml           # mdbook configuration
└── README.md           # This file
```

## Typography

The book uses custom fonts for enhanced readability:
- **Alegreya** (serif) for body text
- **Space Mono** (monospace) for code

## Diagrams

Technical diagrams are created using [Mermaid](https://mermaid.js.org/) and stored as `.mmd` files in the `diagrams/` directory. See `diagrams/README.md` for instructions on editing and regenerating diagrams.

## Recent Improvements

Based on technical review feedback, the following improvements were made:

1. **Complete Decision Branches:** All flowchart decision diamonds now show both yes/no paths
2. **Modern System Call Entry:** Added SYSENTER/SYSCALL fast entry path alongside legacy INT 0x80
3. **Terminology Consistency:** Uses formal kernel state names (e.g., SZOMB) throughout
4. **Enhanced Documentation:** Explained modern CPU features while maintaining historical context

See `git log` for detailed history of changes.

## Git Workflow

This repository tracks source files only (markdown, diagrams, fonts), not build outputs:

```bash
# View history
git log --oneline

# See what changed
git diff

# Revert to previous version if needed
git checkout <commit-hash>
```

## Author

Lee Hanken

*for India*
