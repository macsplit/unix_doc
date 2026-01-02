Swap Space Management

## Overview

The swap space manager provides backing storage for anonymous pages. It presents a logical concatenation of multiple physical swap devices as a single virtual swap device. Each swap area contains an anon array representing available slots, with allocation balancing load across all active swap devices.

## Swapinfo Structure

Each swap area is tracked by a swapinfo structure (swap.h):

```c
struct swapinfo {
    struct swapinfo *si_next;    /* next swap area */
    struct vnode *si_vp;         /* swap device vnode */
    uint si_soff;                /* start offset in swap device */
    uint si_eoff;                /* end offset */
    struct anon **si_anon;       /* array of anon slot pointers */
    uint si_allocs;              /* allocation count */
    uint si_npgs;                /* number of pages */
    uint si_nfpgs;               /* number of free pages */
};
```

The `si_anon` array holds anon structures for the swap area. Free slots are linked into a free list through the `an_next` field in the anon structure.

## Logical Concatenation

The swap device provides a logical address space formed by concatenating all swap areas sequentially (vm_swap.c:38):

"Each physical swap area has an associated anon array representing its physical storage. These anon arrays are logically concatenated sequentially to form the overall swap device anon array. Thus, the offset of a given entry within this logical array is computed as the sum of the sizes of each area preceding the entry plus the offset within the area containing the entry."

This design allows the system to add and remove swap devices dynamically without changing the virtual swap interface.

## Adding Swap Space

The `swapadd()` function (vm_swap.c:565) adds a new swap area:

```c
STATIC int
swapadd(vp, lowblk, nblks, swapname)
    struct vnode *vp;
    uint lowblk;
    uint nblks;
    char *swapname;
{
    register struct anon *ap, *ap2;
    register struct swapinfo **sipp, *nsip;
    register struct vnode *cvp;
    struct vattr vattr;
    register uint pages;
    uint soff, eoff, off;
    int error;

    if (error = VOP_OPEN(&vp, FREAD|FWRITE, u.u_cred)) {
        return error;
    }
    cvp = common_specvp(vp);
```

The function opens the swap device, validates the partition size, allocates the swapinfo structure and anon array, then links the new area into the global swap list.

## Swap Allocation

The `swap_alloc()` function allocates an anon slot from the most appropriate swap area. It attempts to balance allocation across areas by selecting the area with the most free slots relative to its size. This load balancing ensures even wear on swap devices and prevents any single area from becoming a bottleneck.

## Swap Translation

The `swap_xlate()` function translates an anon pointer to a vnode/offset pair for I/O operations. It traverses the an_bap indirection chain to handle deleted swap areas:

"When we delete a swap device, since it is too complicated to find and relocate all the data structures that point to our anon slots, we use the an_bap field to go indirect to the new backing anon slot."

This indirection allows swap removal without invalidating existing anon pointers.

## Swap Deletion

The `swapdel()` function removes a swap area by relocating all allocated pages to other areas, updating an_bap pointers, then freeing the swapinfo structure. This process ensures that removing swap space does not lose any active data.


![](2.9-swap-management.png)
