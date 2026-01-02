Credentials and Access Control

## Overview

Process credentials control access to system resources. The `cred_t` structure contains user IDs, group IDs, and privilege information. Credentials are reference-counted and shared among processes to conserve memory.

## Credential Structure

The credential structure (cred.c) contains:

```c
typedef struct cred {
    u_long cr_ref;      /* reference count */
    uid_t cr_uid;       /* effective user ID */
    uid_t cr_ruid;      /* real user ID */
    uid_t cr_suid;      /* saved user ID */
    gid_t cr_gid;       /* effective group ID */
    gid_t cr_rgid;      /* real group ID */
    gid_t cr_sgid;      /* saved group ID */
    int cr_ngroups;     /* number of groups */
    gid_t cr_groups[NGROUPS]; /* supplementary groups */
} cred_t;
```

The effective UID (`cr_uid`) determines access permissions. The real UID identifies the actual user, while the saved UID enables setuid programs to temporarily drop and regain privileges.

## Credential Operations

`crdup()` duplicates credentials with copy-on-write semantics. Modifications require `cralloc()` to create a private copy if the reference count exceeds one. This ensures credential changes don't affect other processes sharing the structure.

The `setuid()` system call modifies credentials based on privilege:

```c
if (pm_denied(cr, P_SETUID)) {
    if (uid == cr->cr_ruid || uid == cr->cr_suid) {
        cr = crdup(cr);
        cr->cr_uid = uid;
    } else
        return EPERM;
} else {
    cr = crdup(cr);
    cr->cr_ruid = cr->cr_uid = cr->cr_suid = uid;
}
```

Superusers can set all three UIDs, while normal users can only switch between real, effective, and saved UIDs.

## Setuid Execution

When executing a setuid binary, the exec code saves the current effective UID to `cr_suid` and sets `cr_uid` to the file owner. This allows the program to drop privileges temporarily via `setuid(getuid())` and regain them via `setuid(saved_uid)`.

Supplementary groups extend access control beyond the primary group, enabling fine-grained permission management.


![](1.7-credentials.png)
