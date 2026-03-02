# Linux Filesystem & Commands — Mental Models + Container Perspective

> **Core Philosophy**: In Linux, *everything is a file* — devices, processes, network sockets, directories, and pipes all appear as files in a unified tree rooted at `/`.

---

## Table of Contents

1. [Mental Model 1: The Inverted Tree](#1-mental-model-1-the-inverted-tree)
2. [Mental Model 2: "Everything is a File"](#2-mental-model-2-everything-is-a-file)
3. [FHS — The Directory Map](#3-fhs--the-directory-map)
4. [Directory Deep Dive](#4-directory-deep-dive)
5. [Container Filesystem Architecture](#5-container-filesystem-architecture)
6. [OverlayFS — How Docker Layers Work](#6-overlayfs--how-docker-layers-work)
7. [Namespaces & chroot — Isolation Primitives](#7-namespaces--chroot--isolation-primitives)
8. [File Permissions Mental Model](#8-file-permissions-mental-model)
9. [Inodes & Links Mental Model](#9-inodes--links-mental-model)
10. [Essential Commands by Category](#10-essential-commands-by-category)
11. [/proc & /sys — The Live Kernel Window](#11-proc--sys--the-live-kernel-window)
12. [Mount Points & Volume Mounts](#12-mount-points--volume-mounts)
13. [Quick Cheatsheet](#13-quick-cheatsheet)

---

## 1. Mental Model 1: The Inverted Tree

```
                         ┌─────────┐
                         │    /    │  ← Root of EVERYTHING (like a tree trunk)
                         └────┬────┘
          ┌──────────┬────────┼────────┬──────────┬──────────┐
       ┌──┴──┐   ┌───┴──┐ ┌──┴──┐ ┌───┴──┐   ┌───┴──┐  ┌───┴──┐
       │ bin │   │ etc  │ │ var │ │ usr  │   │ proc │  │ home │
       └──┬──┘   └───┬──┘ └──┬──┘ └───┬──┘   └───┬──┘  └───┬──┘
          │          │       │         │           │          │
        Commands  Config   Logs    Programs      Kernel   User dirs
        (ls,cat)  Files  (/var/log)  (/usr/bin) Data (PID) (/home/alice)

ANALOGY: Like a company org chart — CEO (/) → Departments → Teams → People
         Everything has ONE parent, every file has ONE path from root
```

**Key Rule**: No matter how many disks, partitions, or network shares you attach — they all *mount* into this single tree. There is no `C:\` or `D:\` concept.

---

## 2. Mental Model 2: "Everything is a File"

```
┌─────────────────────────────────────────────────────────────────┐
│                    LINUX FILE TYPES                             │
│                                                                 │
│  Regular File  ─── Text, binary, scripts, images               │
│        -                                                        │
│                                                                 │
│  Directory     ─── A file containing a list of other files     │
│        d                                                        │
│                                                                 │
│  Symlink       ─── A file pointing to another file path        │
│        l             (like Windows shortcut)                   │
│                                                                 │
│  Block Device  ─── Hard disk, SSD (/dev/sda)                   │
│        b             Read/write in fixed-size blocks           │
│                                                                 │
│  Char Device   ─── Keyboard, terminal (/dev/tty)               │
│        c             Read/write character by character         │
│                                                                 │
│  FIFO/Pipe     ─── Inter-process communication                 │
│        p             One process writes, another reads         │
│                                                                 │
│  Socket        ─── Network or Unix domain socket               │
│        s             (Nginx, Docker daemon use these)          │
└─────────────────────────────────────────────────────────────────┘

Check type: ls -la /dev/    (look at first character of permission string)
```

**Why this matters for containers**: Docker daemon communicates via `/var/run/docker.sock` (a socket file). Mounting this into a container gives it full Docker control — a major security risk.

---

## 3. FHS — The Directory Map

```
/
├── bin/          User commands (ls, cat, cp, mv) — symlink to /usr/bin in modern distros
├── sbin/         System commands (mount, reboot, iptables) — for root
├── boot/         Kernel + bootloader (vmlinuz, initrd)     ← NOT in containers
├── dev/          Device files — kernel creates these dynamically
│   ├── null      Discard everything written (black hole)
│   ├── zero      Source of infinite zeros
│   ├── random    Cryptographic random bytes
│   └── sda       First hard disk
├── etc/          Configuration files (text-based, human-readable)
│   ├── passwd    User accounts (no passwords! just metadata)
│   ├── shadow    Hashed passwords (root-only)
│   ├── hosts     Local DNS overrides
│   ├── resolv.conf DNS server config              ← Containers override this
│   └── fstab     Filesystem mount table
├── home/         User home directories (/home/alice, /home/bob)
├── lib/          Shared libraries (.so files) for /bin and /sbin
├── lib64/        64-bit shared libraries
├── media/        Auto-mounted removable media (USB, CD)
├── mnt/          Temporary manual mount points
├── opt/          Optional/third-party software (Oracle, custom apps)
├── proc/         VIRTUAL — kernel exposes process & system info as files
│   ├── 1/        PID 1 process info (init / systemd / your entrypoint)
│   ├── cpuinfo   CPU details
│   ├── meminfo   Memory stats
│   └── net/      Network interface stats
├── root/         Home dir for root user (not /home/root!)
├── run/          Runtime data (PIDs, sockets) — cleared on reboot
│   └── docker.sock  Docker daemon socket
├── srv/          Data served by the system (web files, FTP)
├── sys/          VIRTUAL — kernel hardware/driver info
├── tmp/          Temporary files — cleared on reboot (world-writable!)
├── usr/          Unix System Resources — read-only user programs
│   ├── bin/      All user commands (the real location modern distros use)
│   ├── lib/      Libraries for /usr/bin
│   ├── local/    Locally compiled software (not managed by package manager)
│   └── share/    Architecture-independent data (man pages, icons)
└── var/          Variable data — grows over time
    ├── log/      Log files (syslog, auth.log, nginx/access.log)
    ├── cache/    Application cache
    ├── lib/      Persistent app state (databases, package lists)
    └── tmp/      Temp files that survive reboots (unlike /tmp)
```

---

## 4. Directory Deep Dive

### The "Container Survival" Directories

| Directory | What lives here | Container Relevance |
|-----------|----------------|---------------------|
| `/etc` | All config | Mounted as ConfigMaps in K8s |
| `/var/log` | Logs | Mount volume here for log persistence |
| `/tmp` | Scratch space | tmpfs mount — lives in RAM |
| `/proc` | Kernel data | Shared with host (careful!) |
| `/dev` | Devices | Containers get a minimal subset |
| `/run` | Runtime sockets | Docker socket lives here |
| `/usr/local/bin` | Custom binaries | Where your app binary goes |
| `/app` or `/workspace` | Convention | Where Dockerfiles copy app to |

### /etc — The Config Brain

```
/etc/
├── passwd        # username:x:uid:gid:comment:home:shell
├── group         # groupname:x:gid:members
├── shadow        # username:$6$hash:lastchange:...  (root-readable only)
├── sudoers       # Who can run sudo and how
├── ssh/
│   └── sshd_config   # SSH server settings
├── nginx/
│   └── nginx.conf    # Nginx config (if installed)
├── cron.d/       # Scheduled jobs
├── environment   # System-wide env variables
└── profile.d/    # Shell startup scripts
```

---

## 5. Container Filesystem Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONTAINER VIEW                                   │
│                                                                     │
│   Container Process sees:    /                                      │
│                               ├── bin/                              │
│                               ├── etc/                              │
│                               ├── app/          ← your code        │
│                               └── var/log/      ← (may be volume)  │
│                                                                     │
│   Looks like a complete Linux system — but it's an ILLUSION        │
│   built from layers + Linux kernel features                         │
└────────────────────────┬────────────────────────────────────────────┘
                         │ powered by
          ┌──────────────▼──────────────────────┐
          │          HOST KERNEL                │
          │  (namespaces + cgroups + OverlayFS) │
          └─────────────────────────────────────┘
```

### What a Container Actually Is

```
┌────────────────────────────────────────────────────────────────┐
│  CONTAINER = Isolated Process (NOT a VM)                       │
│                                                                │
│  Isolation via:                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │  Namespaces  │  │   cgroups    │  │      OverlayFS       │ │
│  │              │  │              │  │                      │ │
│  │ pid  → own   │  │ CPU limit    │  │ Layered filesystem   │ │
│  │       PID 1  │  │ Memory limit │  │ (covered next)       │ │
│  │ net  → own   │  │ I/O limit    │  │                      │ │
│  │       eth0   │  │ Process limit│  │                      │ │
│  │ mnt  → own   │  │              │  │                      │ │
│  │       /      │  │              │  │                      │ │
│  │ uts  → own   │  │              │  │                      │ │
│  │       hostname│ │              │  │                      │ │
│  │ ipc  → own   │  │              │  │                      │ │
│  │       semaphores              │  │                      │ │
│  │ user → own   │  │              │  │                      │ │
│  │       uid map│  │              │  │                      │ │
│  └──────────────┘  └──────────────┘  └──────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

---

## 6. OverlayFS — How Docker Layers Work

**Mental Model**: Think of transparent acetate sheets stacked on a projector.
- Lower sheets = read-only base images
- Top sheet = your writable changes (the container layer)
- What you see = the combined image from all sheets

```
┌──────────────────────────────────────────────────────────────┐
│                    DOCKER IMAGE LAYERS                        │
│                                                              │
│   ┌─────────────────────────────────────┐                   │
│   │  CONTAINER LAYER (writable)         │  ← Your writes   │
│   │  /app/data/cache.db (new file)      │    go here       │
│   │  /etc/myapp.conf (modified)         │    DELETED on    │
│   └─────────────────────────────────────┘    rm container  │
│                      ↑                                      │
│   ┌─────────────────────────────────────┐                   │
│   │  COPY . /app  (Dockerfile layer 4) │  ← Read-only     │
│   └─────────────────────────────────────┘                   │
│                      ↑                                       │
│   ┌─────────────────────────────────────┐                   │
│   │  RUN dotnet restore (layer 3)      │  ← Read-only     │
│   └─────────────────────────────────────┘                   │
│                      ↑                                       │
│   ┌─────────────────────────────────────┐                   │
│   │  FROM mcr.microsoft.com/dotnet:8   │  ← Read-only     │
│   │  (base OS + runtime)               │    Shared by ALL │
│   └─────────────────────────────────────┘    containers   │
│                                              using same base│
└──────────────────────────────────────────────────────────────┘

OverlayFS structure on host:
  lowerdir  = image layers (read-only, stacked)
  upperdir  = container layer (writable)
  workdir   = OverlayFS internal use
  merged    = what the container sees (unified view)
```

### Copy-on-Write (CoW)

```
Container modifies /etc/hosts:

1. File found in lowerdir (base image)
2. OverlayFS copies it UP to upperdir     ← "copy-on-write"
3. Container now reads/writes the copy
4. Original in lowerdir UNCHANGED
5. Other containers still see original

This is why:
  • 100 containers from same image share base layers (disk efficient)
  • Each container has its own upperdir (isolated writes)
  • Container deletion = delete only upperdir
```

### Volume Mounts Bypass OverlayFS

```
┌──────────────────────────────────────────┐
│  Without volume:  container writes       │
│  → upperdir → lost when container dies  │
│                                          │
│  With volume:     container writes       │
│  → host path → PERSISTS                 │
└──────────────────────────────────────────┘

docker run -v /host/data:/container/data myapp
             ↑                ↑
         Host path      Container path
         (persists)     (where container writes)
```

---

## 7. Namespaces & chroot — Isolation Primitives

### chroot — The Original Container

```bash
# chroot changes what "/" means for a process
chroot /opt/myapp-root /bin/bash
# Now this bash process thinks / = /opt/myapp-root
# It CANNOT see /etc/passwd of the real system
# All file paths are relative to /opt/myapp-root

# Docker does this automatically — each container gets
# its merged OverlayFS path as its root
```

### Mount Namespace (most important for filesystem)

```
HOST                           CONTAINER
/                              /
├── etc/  (host config)        ├── etc/  (container config)
├── home/ (host users)         ├── app/  (your code)
├── var/  (host logs)          ├── var/log/ (volume-mounted back to host)
└── proc/ (ALL processes)      └── proc/ (only container PIDs visible)
                                          ← filtered by PID namespace
```

### What Containers CAN'T do by default

```
┌─────────────────────────────────────────────────────────┐
│  Blocked by default (requires --privileged or caps):    │
│                                                         │
│  • Mount arbitrary filesystems                          │
│  • Load kernel modules                                  │
│  • Access raw network (packet capture)                  │
│  • Write to /proc/sys (kernel tuning)                   │
│  • Access other containers' /proc/<pid>/               │
│                                                         │
│  Allowed by default:                                    │
│  • Read /proc/cpuinfo, /proc/meminfo (host values!)     │
│    ← This is why you see HOST memory in container      │
│  • Write to /tmp (tmpfs or writable layer)              │
│  • Read/write to mounted volumes                        │
└─────────────────────────────────────────────────────────┘
```

---

## 8. File Permissions Mental Model

**Mental Model**: Think of a nightclub bouncer system — Owner, Group, Everyone Else.

```
ls -la /etc/passwd
-rw-r--r-- 1 root root 2847 Jan 15 10:00 /etc/passwd
│││││││││
││││││││└─ Other: can Read
│││││││└── Other: cannot Write
││││││└─── Other: cannot eXecute
│││││└──── Group: can Read
││││└───── Group: cannot Write
│││└────── Group: cannot eXecute
││└─────── Owner: can Read
│└──────── Owner: can Write
└───────── Owner: cannot eXecute
 │         ↑    ↑
 │        owner group
 └── File type: - (regular), d (dir), l (symlink)
```

### Numeric Permissions

```
┌───────────────────────────────────────┐
│  r = 4   w = 2   x = 1               │
│                                       │
│  rwx = 4+2+1 = 7  (full access)      │
│  rw- = 4+2+0 = 6  (read/write)       │
│  r-- = 4+0+0 = 4  (read only)        │
│  --- = 0+0+0 = 0  (no access)        │
│                                       │
│  chmod 755 myfile                     │
│  → owner: rwx(7) group: r-x(5) other:r-x(5)│
│                                       │
│  chmod 644 config.txt                 │
│  → owner: rw-(6) group: r--(4) other:r--(4)│
└───────────────────────────────────────┘

Common patterns:
  755  → executable scripts, directories (public read/execute)
  644  → config files (public read, owner write)
  600  → SSH private keys (owner only!)
  777  → DANGER: world-writable (avoid in production)
  1777 → /tmp (sticky bit: only owner can delete their files)
```

### Special Bits

```
┌─────────────────────────────────────────────────────────┐
│  SETUID (4xxx): Run as file owner, not current user     │
│  chmod 4755 /usr/bin/passwd                             │
│  → passwd runs as root even when called by alice        │
│  → ls shows: -rwsr-xr-x (s in owner execute position)  │
│                                                         │
│  SETGID (2xxx): Run as file's group                     │
│  chmod 2755 /usr/bin/screen                             │
│  → useful for shared directories                        │
│                                                         │
│  STICKY (1xxx): Only owner can delete in directory      │
│  chmod 1777 /tmp                                        │
│  → Alice can't delete Bob's files in /tmp               │
└─────────────────────────────────────────────────────────┘

Container Security Note:
  • Never run containers as root (UID 0)
  • Use USER directive in Dockerfile
  • Setuid binaries in containers are a security risk
  • K8s PodSecurityContext: runAsNonRoot: true
```

---

## 9. Inodes & Links Mental Model

**Mental Model**: An inode is like a library card — the card has all the metadata (author, shelf location) and the book's actual content is on the shelf. Multiple cards can point to the same book.

```
┌──────────────────────────────────────────────────────────────┐
│                      INODE STRUCTURE                         │
│                                                              │
│  filename ──→ inode number ──→ INODE TABLE ENTRY            │
│                               ┌─────────────────────┐       │
│                               │ File type           │       │
│                               │ Permissions (rwxrwxrwx)    │
│                               │ Owner (UID, GID)    │       │
│                               │ Size                │       │
│                               │ Timestamps (atime, mtime, ctime)│
│                               │ Link count          │       │
│                               │ Data block pointers ────→ actual data│
│                               └─────────────────────┘       │
│                                                              │
│  NOTE: Filename is stored in the DIRECTORY, not the inode!  │
└──────────────────────────────────────────────────────────────┘
```

### Hard Links vs Soft Links

```
HARD LINK:                          SOFT LINK (Symlink):
  file.txt ──→ inode #42              file.txt ──→ inode #42
  backup.txt ──→ inode #42            link.txt ──→ inode #99
  (same inode, same data)             inode #99 contains → "file.txt"

  • Both names are EQUAL              • link.txt points TO file.txt
  • Delete file.txt → backup.txt      • Delete file.txt → link.txt BREAKS
    still works (inode stays alive)   • Can cross filesystems
  • Cannot cross filesystems          • Can link to directories
  • Cannot link to directories        • ls -la shows: link.txt -> file.txt

ln file.txt backup.txt              ln -s file.txt link.txt
                                    ln -s /etc/nginx nginx-conf

Container example:
  /bin → /usr/bin (symlink on modern distros)
  /lib → /usr/lib (symlink on modern distros)

  Docker base images use these symlinks — 'ls /bin' works but
  actual files are in /usr/bin
```

---

## 10. Essential Commands by Category

### Navigation & Discovery

```bash
$ pwd
/app

$ ls -la /etc
total 200
drwxr-xr-x 1 root root  4096 Mar  1 09:00 .
drwxr-xr-x 1 root root  4096 Mar  1 09:00 ..
-rw-r--r-- 1 root root  2847 Jan 15 10:00 passwd
-rw-r----- 1 root shadow 1423 Jan 15 10:00 shadow
-rw-r--r-- 1 root root   220 Jan 15 10:00 hosts
drwxr-xr-x 2 root root  4096 Jan 15 10:00 nginx
#           ↑    ↑    ↑   ↑       ↑          ↑
#       perms  owner group size  timestamp   name

$ ls -lah /var/log
total 48M
drwxr-xr-x 4 root   root    4.0K Mar  1 09:00 .
-rw-r--r-- 1 root   root     12M Mar  1 12:34 syslog
-rw-r----- 1 root   adm     512K Mar  1 12:30 auth.log
drwxr-xr-x 2 www-data www-data 4.0K Mar  1 09:00 nginx

$ ls -lt /var/log | head -5      # newest files first
total 49152
-rw-r--r-- 1 root root 12582912 Mar  1 12:34 syslog
-rw-r----- 1 root adm    524288 Mar  1 12:30 auth.log
-rw-r--r-- 1 root root   204800 Mar  1 11:00 kern.log

$ tree -L 2 /app
/app
├── appsettings.json
├── MyApi.dll
├── MyApi.deps.json
└── logs
    └── app-2026-03-01.log

$ find /etc -name "*.conf" 2>/dev/null
/etc/nginx/nginx.conf
/etc/nginx/conf.d/default.conf
/etc/ld.so.conf
/etc/resolv.conf

$ find /app -type f -newer /tmp/ref
/app/logs/app-2026-03-01.log
/app/data/cache.db
```

### File Inspection

```bash
$ cat /etc/hosts
127.0.0.1   localhost
::1         localhost ip6-localhost
10.244.0.15 myapp-pod-7d9f8b   myapp-pod  # K8s injects pod's own entry
10.96.0.1   kubernetes                     # K8s injects cluster IP

$ cat /etc/resolv.conf
nameserver 10.96.0.10         # kube-dns ClusterIP — K8s injects this!
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5

$ head -5 /var/log/nginx/access.log
10.244.0.1 - - [01/Mar/2026:09:00:01 +0000] "GET /health HTTP/1.1" 200 15
10.244.0.1 - - [01/Mar/2026:09:00:05 +0000] "POST /api/users HTTP/1.1" 201 87
10.244.0.1 - - [01/Mar/2026:09:00:10 +0000] "GET /api/data HTTP/1.1" 500 42

$ tail -f /var/log/app.log       # streams live — Ctrl+C to stop
[12:34:01] INFO  Starting application...
[12:34:02] INFO  Connected to DB at db-host:5432
[12:34:05] ERROR Failed to process request: timeout
[12:34:06] WARN  Retry attempt 1/3

$ grep "ERROR" /var/log/app.log
[12:34:05] ERROR Failed to process request: timeout
[12:35:11] ERROR NullReferenceException in UserService.cs:42
[12:36:00] ERROR DB connection refused

$ grep -n "listen" /etc/nginx/nginx.conf   # show line numbers
8:    listen 80;
9:    listen [::]:80;
45:   listen 443 ssl;

$ grep -r "connectionString" /etc/myapp/
/etc/myapp/appsettings.json:  "connectionString": "Server=db;Database=myapp;"
/etc/myapp/appsettings.prod.json:  "connectionString": "Server=prod-db;..."

$ grep -v "DEBUG" /var/log/app.log | grep -E "ERROR|WARN"
[12:34:05] ERROR Failed to process request: timeout
[12:34:06] WARN  Retry attempt 1/3

$ cat /proc/1/environ | tr '\0' '\n'   # env vars of PID 1 (the container entrypoint)
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ASPNETCORE_URLS=http://+:80
DB_HOST=postgres-service
DB_PASSWORD=s3cr3t
KUBERNETES_SERVICE_HOST=10.96.0.1
HOSTNAME=myapp-pod-7d9f8b-xk2p9
```

### File & Directory Operations

```bash
$ mkdir -p /opt/myapp/logs/archive
$ ls -la /opt/myapp/
total 12
drwxr-xr-x 3 root root 4096 Mar  1 12:00 .
drwxr-xr-x 4 root root 4096 Mar  1 12:00 ..
drwxr-xr-x 3 root root 4096 Mar  1 12:00 logs

$ touch /tmp/marker.txt
$ ls -la /tmp/marker.txt
-rw-r--r-- 1 root root 0 Mar  1 12:01 /tmp/marker.txt
#                      ↑ size=0 (empty file)

$ cp -r /etc/nginx /tmp/nginx-backup
$ ls /tmp/nginx-backup/
nginx.conf  conf.d/  mime.types  sites-enabled/

$ mv /tmp/nginx-backup /tmp/nginx-backup-2026-03-01    # rename
$ ls /tmp/
nginx-backup-2026-03-01/  marker.txt

$ ln -s /etc/nginx /home/admin/nginx-conf
$ ls -la /home/admin/
lrwxrwxrwx 1 root root 10 Mar  1 12:02 nginx-conf -> /etc/nginx
#↑ 'l' = symlink, shows target after ->

$ find /var/log -name "*.log" -mtime +30   # logs older than 30 days
/var/log/nginx/access.log.1
/var/log/nginx/error.log.2
/var/log/syslog.3.gz

$ find /app -type f -name "*.dll" | head -5
/app/MyApi.dll
/app/MyApi.deps.json
/app/System.Text.Json.dll
```

### Permissions & Ownership

```bash
$ stat /etc/passwd
  File: /etc/passwd
  Size: 2847            Blocks: 8     IO Block: 4096  regular file
Device: fd01h/64769d    Inode: 1048578   Links: 1
Access: (0644/-rw-r--r--)  Uid: (0/ root)   Gid: (0/ root)
Access: 2026-03-01 09:00:00.000
Modify: 2026-01-15 10:00:00.000
Change: 2026-01-15 10:00:00.000
#        ↑ octal    ↑ symbolic      ↑ owner uid    ↑ group gid

$ ls -la /usr/bin/passwd
-rwsr-xr-x 1 root root 68208 Jan 15 2026 /usr/bin/passwd
#   ↑ 's' here = SETUID — runs as root even when called by alice

$ ls -la /tmp
drwxrwxrwt 8 root root 4096 Mar  1 12:00 /tmp
#        ↑ 't' = sticky bit — only owner can delete their own files

$ id
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser),999(docker)
#   ↑ UID          ↑ primary group    ↑ all groups this user belongs to

$ whoami
appuser

$ cat /proc/1/status | grep -E "^(Uid|Gid)"
Uid:    1000    1000    1000    1000
Gid:    1000    1000    1000    1000
#       ↑real   ↑eff    ↑saved  ↑filesystem UID
# If running as root: Uid: 0  0  0  0  ← DANGER in production!

$ chmod 755 /app/startup.sh
$ ls -la /app/startup.sh
-rwxr-xr-x 1 appuser appuser 512 Mar  1 12:00 /app/startup.sh
#  ↑7=rwx   ↑5=r-x   ↑5=r-x

$ chown -R www-data:www-data /var/www/html
$ ls -la /var/www/
drwxr-xr-x 2 www-data www-data 4096 Mar  1 12:00 html
```

### Disk & Filesystem

```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
overlay         100G   18G   77G  19% /           ← container root (OverlayFS!)
tmpfs            64M     0   64M   0% /dev
tmpfs            16G  1.2G   15G   8% /sys/fs/cgroup
/dev/sda1       100G   18G   77G  19% /etc/hosts  ← bind-mounted from host
shm              64M  4.0K   64M   1% /dev/shm
tmpfs            16G     0   16G   0% /tmp         ← tmpfs if mounted
# NOTE: overlay = entire host disk! Not your container limit.

$ df -h /
Filesystem      Size  Used Avail Use% Mounted on
overlay         100G   18G   77G  19% /

$ du -sh /var/log/*
4.0K    /var/log/alternatives.log
12M     /var/log/nginx
512K    /var/log/auth.log
48M     /var/log/syslog            ← disk hog!

$ du -sh /var/log/* | sort -h     # sorted: smallest first
4.0K    /var/log/alternatives.log
512K    /var/log/auth.log
12M     /var/log/nginx
48M     /var/log/syslog

$ mount | grep overlay             # show Docker container mounts
overlay on / type overlay (rw,relatime,lowerdir=/var/lib/docker/overlay2/abc123/diff,
  upperdir=/var/lib/docker/overlay2/xyz789/diff,
  workdir=/var/lib/docker/overlay2/xyz789/work)
#                ↑ image layers (read-only)     ↑ container layer (writable)

$ cat /proc/mounts | head -8       # inside container view
overlay / overlay rw,relatime,... 0 0
proc /proc proc rw,nosuid,... 0 0
tmpfs /dev tmpfs rw,nosuid,... 0 0
devpts /dev/pts devpts rw,... 0 0
/dev/sda1 /etc/hosts ext4 rw,... 0 0    ← bind mount (hosts file)
/dev/sda1 /etc/resolv.conf ext4 rw,... 0 0
tmpfs /tmp tmpfs rw,... 0 0

$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0  100G  0 disk
└─sda1   8:1    0  100G  0 part /
sdb      8:16   0   20G  0 disk
└─sdb1   8:17   0   20G  0 part /var/lib/docker

$ cat /sys/fs/cgroup/memory/memory.limit_in_bytes
536870912      # 512 MB — THE REAL LIMIT for this container
               # compare: /proc/meminfo shows 32GB (host)!
```

### Process & System Info via /proc

```bash
$ ls /proc/ | head -20
1        9        15       cpuinfo   meminfo   version
4        10       self     devices   mounts    net
5        11       thread-self  filesystems  stat  sys
# ↑ numbers = PIDs running on host (visible if no PID namespace)
# Inside container with PID namespace: you only see container PIDs

$ cat /proc/1/cmdline | tr '\0' ' '
dotnet MyApi.dll
# ↑ This is your container ENTRYPOINT / CMD — PID 1

$ cat /proc/self/status | head -10
Name:   bash
Umask:  0022
State:  S (sleeping)
Tgid:   42
Ngid:   0
Pid:    42
PPid:   1
Uid:    1000    1000    1000    1000
Gid:    1000    1000    1000    1000
VmRSS:  4096 kB

$ ls -la /proc/self/fd/
lrwx------ 1 root root 64 Mar 1 12:00 0 -> /dev/pts/0    # stdin
lrwx------ 1 root root 64 Mar 1 12:00 1 -> /dev/pts/0    # stdout
lrwx------ 1 root root 64 Mar 1 12:00 2 -> /dev/pts/0    # stderr
lr-x------ 1 root root 64 Mar 1 12:00 3 -> /var/log/app.log  # open log file

$ cat /proc/version
Linux version 5.15.0-1034-azure (buildd@...) (gcc 11.3.0) #39-Ubuntu...
# ↑ HOST kernel version — same for ALL containers on this host

$ uname -a
Linux myapp-pod-7d9f8b-xk2p9 5.15.0-1034-azure #39-Ubuntu SMP x86_64 GNU/Linux
#     ↑ hostname (K8s pod name)  ↑ host kernel

$ hostname
myapp-pod-7d9f8b-xk2p9      # K8s sets this to pod name automatically

$ env | sort
ASPNETCORE_URLS=http://+:80
DB_HOST=postgres-service
DB_NAME=myapp_db
DB_PASSWORD=s3cr3t
HOME=/root
HOSTNAME=myapp-pod-7d9f8b-xk2p9
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_SERVICE_HOST=10.96.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/sbin:/bin

$ printenv DB_HOST
postgres-service

$ cat /proc/meminfo | grep -E "^(MemTotal|MemFree|MemAvailable)"
MemTotal:       32874936 kB    ← HOST memory (32 GB!) — NOT container limit
MemFree:        18432000 kB
MemAvailable:   24576000 kB
# Your container limit: cat /sys/fs/cgroup/memory/memory.limit_in_bytes → 512MB
```

### Networking Files

```bash
$ cat /etc/resolv.conf
nameserver 10.96.0.10          # kube-dns — K8s rewrites this on pod start
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
# ndots:5 means: if name has <5 dots, try search domains first
# So "postgres" resolves to "postgres.default.svc.cluster.local"

$ cat /etc/hosts
127.0.0.1   localhost
::1         localhost
10.244.2.15 myapp-pod-7d9f8b-xk2p9   # pod's own IP + hostname
# K8s writes pod IP here at startup

$ cat /etc/nsswitch.conf | grep hosts
hosts:          files dns    # check /etc/hosts first, then DNS
# "files" = /etc/hosts   "dns" = /etc/resolv.conf

$ ss -tlnp
State   Recv-Q  Send-Q   Local Address:Port    Peer Address:Port  Process
LISTEN  0       128            0.0.0.0:80           0.0.0.0:*     users:(("dotnet",pid=1,fd=9))
LISTEN  0       128            0.0.0.0:8080         0.0.0.0:*     users:(("dotnet",pid=1,fd=10))
# ↑ dotnet app listening on port 80 and 8080

$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP>
    link/loopback 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
85: eth0@if86: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether 92:d1:f2:3a:4b:5c brd ff:ff:ff:ff:ff:ff
    inet 10.244.2.15/24 brd 10.244.2.255 scope global eth0
#       ↑ pod's IP address assigned by CNI (Flannel/Calico)

$ ip route show
default via 10.244.2.1 dev eth0    # default gateway
10.244.0.0/16 via 10.244.2.1 dev eth0   # pod network (cluster-wide)
10.244.2.0/24 dev eth0 proto kernel     # local pod subnet

$ nslookup postgres-service           # test K8s service DNS
Server:   10.96.0.10                  # kube-dns answered
Address:  10.96.0.10#53

Name:     postgres-service.default.svc.cluster.local
Address:  10.96.48.120                # ClusterIP of the Service
```

### Log Files

```bash
$ tail -f /var/log/nginx/access.log
10.244.0.1 - - [01/Mar/2026:12:34:01 +0000] "GET /health HTTP/1.1" 200 15 "-" "kube-probe/1.27"
10.244.0.1 - - [01/Mar/2026:12:34:05 +0000] "POST /api/orders HTTP/1.1" 201 312
10.244.0.1 - - [01/Mar/2026:12:34:10 +0000] "GET /api/data HTTP/1.1" 500 42
# format: ip - user [timestamp] "method path proto" status bytes

$ tail -f /var/log/nginx/error.log
2026/03/01 12:34:10 [error] 7#7: *23 connect() failed (111: Connection refused)
  while connecting to upstream, client: 10.244.0.1, upstream: "http://127.0.0.1:5000"

# Container best practice — write to stdout, read with:
$ docker logs myapp-container --tail 50 --follow
$ kubectl logs myapp-pod-7d9f8b-xk2p9 -f --tail=100
$ kubectl logs myapp-pod-7d9f8b-xk2p9 -c sidecar-container   # specific container
```

### Text Processing Trio (grep + sed + awk)

```bash
# ── GREP ─────────────────────────────────────────────────
$ grep "ERROR" /var/log/app.log | grep -v "404"
[12:34:05] ERROR Failed to process request: timeout
[12:35:11] ERROR NullReferenceException in UserService.cs:42

$ grep -c "ERROR" /var/log/app.log    # count matching lines
47

$ grep -B2 -A3 "NullReference" /var/log/app.log   # 2 lines before, 3 after
[12:35:09] DEBUG Processing user request id=9901
[12:35:10] INFO  Fetching user from DB...
[12:35:11] ERROR NullReferenceException in UserService.cs:42
[12:35:11] DEBUG Stack: at UserService.Get(Int32 id)
[12:35:11] DEBUG   at ApiController.GetUser()
[12:35:11] INFO  Sending 500 response

# ── SED ──────────────────────────────────────────────────
$ echo "Server=localhost;Database=myapp" | sed 's/localhost/prod-db/g'
Server=prod-db;Database=myapp

$ sed -n '5,8p' /etc/nginx/nginx.conf     # print only lines 5-8
    server_name  _;
    listen 80;
    location / {
        proxy_pass http://backend;

$ sed '/^#/d' /etc/nginx/nginx.conf | sed '/^$/d'  # strip comments + blank lines
worker_processes auto;
events { worker_connections 1024; }
http { server { listen 80; ... } }

$ sed -i 's/DEBUG/INFO/g' /app/appsettings.json   # in-place edit (no output)

# ── AWK ──────────────────────────────────────────────────
$ awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -5
    142 10.244.0.1       # ← most requests from kube-probe
     38 10.244.2.20
     12 192.168.1.5

$ awk -F: '{print $1, $3}' /etc/passwd | head -5
root 0
daemon 1
bin 2
appuser 1000            # ← username and UID

$ awk '$9 == "500" {print $7}' /var/log/nginx/access.log   # HTTP 500 URLs
/api/data
/api/orders
/api/users/99

$ awk '$9 == "500"' /var/log/nginx/access.log | wc -l    # count 500s
17

# ── PIPELINE (real debugging pattern) ────────────────────
$ cat /var/log/nginx/access.log \
    | grep "POST" \
    | awk '{print $7}' \
    | sort | uniq -c | sort -rn
     42 /api/orders
     18 /api/users
      3 /api/login

$ cat /var/log/nginx/access.log \
    | awk '{print $9}' \
    | sort | uniq -c | sort -rn
    8423 200
     142 304
      47 500
      12 404
      3  401
```

---

## 11. /proc & /sys — The Live Kernel Window

```
/proc/                    # Process & kernel info (pseudo-filesystem)
├── 1/                    # PID 1 (init/systemd/your container entrypoint)
│   ├── cmdline           # Command line (null-separated)
│   ├── environ           # Environment variables (null-separated)
│   ├── fd/               # Open file descriptors (symlinks)
│   ├── maps              # Memory mappings
│   ├── net/              # Network stats for this process
│   ├── status            # Human-readable process status
│   └── cgroup            # Which cgroups this process belongs to
├── self/                 # Symlink to current process's /proc/<pid>
├── cpuinfo               # CPU info (WARNING: reflects HOST in containers)
├── meminfo               # Memory info (WARNING: reflects HOST in containers)
├── mounts                # Currently mounted filesystems
├── net/
│   ├── dev              # Network interface stats
│   └── tcp              # TCP socket table
└── sys/                  # Kernel parameters (writable = tune kernel)
    └── vm/swappiness     # e.g., echo 10 > /proc/sys/vm/swappiness

/sys/                     # Hardware & driver info
├── class/net/            # Network interfaces
├── block/                # Block devices
└── fs/cgroup/            # cgroup filesystem (limits for containers)
```

### Container Gotcha: /proc shows HOST values

```bash
# INSIDE CONTAINER:
$ cat /proc/meminfo | grep -E "^(MemTotal|MemFree|MemAvailable)"
MemTotal:       32874936 kB    ← HOST memory (32 GB!) NOT your container limit!
MemFree:        18432000 kB
MemAvailable:   24576000 kB

# ACTUAL container limit (enforced by kernel cgroups):
$ cat /sys/fs/cgroup/memory/memory.limit_in_bytes
536870912                      ← 512 MB (set by K8s resources.limits.memory)

# Current container memory usage:
$ cat /sys/fs/cgroup/memory/memory.usage_in_bytes
314572800                      ← 300 MB currently used

# CPU limit (in microseconds per 100ms period):
$ cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us
50000                          ← 50ms/100ms = 0.5 CPU cores
$ cat /sys/fs/cgroup/cpu/cpu.cfs_period_us
100000                         ← 100ms period

# Which cgroup does PID 1 belong to?
$ cat /proc/1/cgroup
12:memory:/kubepods/besteffort/pod-abc123/container-xyz
11:cpu:/kubepods/besteffort/pod-abc123/container-xyz
# ↑ K8s hierarchy: kubepods → QoS class → pod → container

# WHY JAVA OOMs:
# Java reads /proc/meminfo → thinks it has 32GB → sets heap to 8GB (25%)
# cgroup limit = 512MB → JVM exceeds limit → OOM Killer terminates container
# FIX: -XX:MaxRAMPercentage=75.0  (reads cgroup limit, not /proc/meminfo)
```

---

## 12. Mount Points & Volume Mounts

### How Mounting Works

```
BEFORE mount:
  /mnt/data/   (empty directory on host)

MOUNT COMMAND:
  mount /dev/sdb1 /mnt/data

AFTER mount:
  /mnt/data/   (now shows contents of /dev/sdb1)

The directory becomes the "window" into the filesystem.
Like connecting a USB drive and having it appear in a folder.
```

### Container Volume Types

```
┌──────────────────────────────────────────────────────────────────┐
│                   DOCKER VOLUME TYPES                            │
│                                                                  │
│  1. BIND MOUNT — map host path to container path                 │
│     -v /host/config:/etc/app/config                              │
│     • Host controls the path                                     │
│     • Good for: development (live code reload), sharing configs  │
│     • Risk: container can modify host files                      │
│                                                                  │
│  2. NAMED VOLUME — Docker manages the storage location           │
│     -v mydata:/var/lib/postgresql/data                           │
│     • Docker creates at /var/lib/docker/volumes/mydata/_data     │
│     • Persists across container restarts                         │
│     • Good for: databases, stateful data                         │
│                                                                  │
│  3. TMPFS MOUNT — lives in RAM only                              │
│     --tmpfs /tmp:rw,size=100m                                    │
│     • Fastest I/O (memory speed)                                 │
│     • Gone when container stops                                  │
│     • Good for: secrets, session data, scratch space            │
│                                                                  │
│  4. ANONYMOUS VOLUME — unnamed, harder to manage                 │
│     VOLUME /data in Dockerfile                                   │
│     • Docker generates random name                               │
│     • Avoid in production — use named volumes                    │
└──────────────────────────────────────────────────────────────────┘
```

### Kubernetes Volume Mounts

```yaml
# ConfigMap as filesystem mount
volumes:
  - name: app-config
    configMap:
      name: myapp-config          # K8s ConfigMap

  - name: app-secret
    secret:
      secretName: db-credentials  # K8s Secret
      defaultMode: 0400           # Read-only for owner (secure!)

  - name: data
    persistentVolumeClaim:
      claimName: myapp-pvc        # Persistent storage

  - name: scratch
    emptyDir:
      medium: Memory              # tmpfs in RAM
      sizeLimit: 100Mi

containers:
  - name: myapp
    volumeMounts:
      - name: app-config
        mountPath: /etc/myapp/     # ConfigMap files appear here
        readOnly: true
      - name: app-secret
        mountPath: /run/secrets/   # Secrets appear here
        readOnly: true
      - name: data
        mountPath: /var/data/      # Persistent volume
      - name: scratch
        mountPath: /tmp/           # RAM-backed temp space
```

---

## 13. Quick Cheatsheet

### "I Need To..." Reference Card

```
┌────────────────────────────────────────────────────────────────┐
│  TASK                          │  COMMAND                      │
├────────────────────────────────┼───────────────────────────────┤
│  Find a file by name           │  find / -name "app.conf"      │
│  Find where a command is       │  which python3 / type nginx   │
│  Show open files by process    │  lsof -p <pid>                │
│  Show who has file open        │  lsof /var/log/app.log        │
│  Check disk space              │  df -h                        │
│  Find disk hog                 │  du -sh /* | sort -h          │
│  Follow log live               │  tail -f /var/log/app.log     │
│  Search logs for errors        │  grep -i "error" *.log        │
│  Check file permissions        │  stat file.txt / ls -la       │
│  Make script executable        │  chmod +x script.sh           │
│  Change file owner             │  chown user:group file        │
│  Check current user            │  id && whoami                 │
│  See mount points              │  mount / findmnt              │
│  Check DNS config              │  cat /etc/resolv.conf         │
│  Check hosts file              │  cat /etc/hosts               │
│  Count lines in file           │  wc -l file.txt               │
│  Sort and deduplicate          │  sort file.txt | uniq         │
│  Replace text in file          │  sed -i 's/old/new/g' file    │
│  Print specific column         │  awk '{print $2}' file        │
│  Show running processes        │  ps aux / ps aux | grep app   │
│  Show PID 1 command            │  cat /proc/1/cmdline          │
│  Show all env variables        │  env / printenv               │
│  Show network connections      │  ss -tlnp                     │
│  Test DNS inside container     │  nslookup svc-name            │
│  Check file type               │  file myfile / ls -la         │
│  Show inode number             │  ls -i file.txt               │
│  Create symlink                │  ln -s /target /link          │
│  Show dir tree                 │  tree -L 2 /etc               │
└────────────────────────────────┴───────────────────────────────┘
```

### Container Debugging Checklist (with sample output)

```bash
# ── 1. WHO AM I? ─────────────────────────────────────────
$ id && whoami && hostname
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)
appuser
myapp-pod-7d9f8b-xk2p9
# ✓ NOT root (uid=0 would be a security concern)

# ── 2. WHERE AM I? ───────────────────────────────────────
$ pwd && ls -la /
/app
total 76
drwxr-xr-x  1 root root 4096 Mar  1 09:00 .
drwxr-xr-x  1 root root 4096 Mar  1 09:00 ..
drwxr-xr-x  2 root root 4096 Jan 15 10:00 app        ← your code
drwxr-xr-x  2 root root 4096 Jan 15 10:00 bin
drwxr-xr-x  1 root root 4096 Jan 15 10:00 etc
drwxr-xr-x  5 root root 4096 Jan 15 10:00 proc       ← virtual
drwxr-xr-x  1 root root 4096 Jan 15 10:00 sys        ← virtual
drwxrwxrwt  2 root root 4096 Mar  1 12:00 tmp        ← world-writable (t=sticky)
drwxr-xr-x  1 root root 4096 Jan 15 10:00 usr

# ── 3. WHAT CONFIG DO I HAVE? ────────────────────────────
$ cat /etc/resolv.conf
nameserver 10.96.0.10          # kube-dns ✓
search default.svc.cluster.local svc.cluster.local cluster.local
# If nameserver is 127.0.0.11 → Docker's embedded DNS (non-K8s)

$ cat /etc/hosts
127.0.0.1  localhost
10.244.2.15 myapp-pod-7d9f8b-xk2p9

$ env | sort | grep -v PASSWORD    # sort all, hide secrets
ASPNETCORE_URLS=http://+:80
DB_HOST=postgres-service
DB_NAME=myapp_db
HOSTNAME=myapp-pod-7d9f8b-xk2p9
KUBERNETES_SERVICE_HOST=10.96.0.1

# ── 4. WHAT IS MY PROCESS? ───────────────────────────────
$ cat /proc/1/cmdline | tr '\0' ' '
dotnet MyApi.dll
# PID 1 = your ENTRYPOINT. If it dies → container exits!

$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT  COMMAND
appuser      1  0.5  2.1 274000 43520 ?        Ssl   dotnet MyApi.dll
appuser     42  0.0  0.0  18700  3200 pts/0    Ss    /bin/bash
appuser     67  0.0  0.0  36800  3100 pts/0    R+    ps aux

# ── 5. WHAT STORAGE DO I HAVE? ───────────────────────────
$ df -h
Filesystem    Size  Used Avail Use% Mounted on
overlay       100G   18G   77G  19% /           ← HOST disk (misleading!)
tmpfs          64M     0   64M   0% /dev
/dev/sda1     100G   18G   77G  19% /etc/hosts  ← bind mount

$ cat /sys/fs/cgroup/memory/memory.limit_in_bytes
536870912     # 512 MB ← REAL container memory limit (not the 100G above!)

$ mount | grep -v -E "proc|sys|dev|cgroup"
overlay on / type overlay (rw,relatime,lowerdir=...,upperdir=...,workdir=...)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,size=102400k)
/dev/sda1 on /etc/hosts type ext4 (rw,relatime)
/dev/sda1 on /etc/resolv.conf type ext4 (rw,relatime)
# Meaningful mounts: root overlay + any volumes + bind-mounts

# ── 6. WHAT NETWORK DO I HAVE? ───────────────────────────
$ ip addr show eth0
85: eth0@if86: <BROADCAST,MULTICAST,UP,LOWER_UP>
    inet 10.244.2.15/24 brd 10.244.2.255 scope global eth0

$ nslookup postgres-service
Server:   10.96.0.10
Name:     postgres-service.default.svc.cluster.local
Address:  10.96.48.120    # ✓ resolves → Service exists

$ nslookup nonexistent-svc
** server can't find nonexistent-svc: NXDOMAIN   # ✗ Service missing or wrong namespace

# ── 7. WHAT LOGS EXIST? ──────────────────────────────────
$ find /var/log -type f -name "*.log" 2>/dev/null
/var/log/nginx/access.log
/var/log/nginx/error.log
/var/log/dpkg.log

$ ls -lah /app/logs/ 2>/dev/null || echo "No /app/logs directory"
total 24M
-rw-r--r-- 1 appuser appuser  12M Mar  1 12:34 app-2026-03-01.log
-rw-r--r-- 1 appuser appuser   8M Mar  1 00:00 app-2026-02-29.log
# If this is big → logs not going to stdout, fix: log to stdout!
```

### Key File Locations for Common Services

```
┌────────────────────────────────────────────────────────────────┐
│  SERVICE      │  CONFIG                   │  LOGS              │
├───────────────┼───────────────────────────┼────────────────────┤
│  Nginx        │  /etc/nginx/nginx.conf    │  /var/log/nginx/   │
│  PostgreSQL   │  /etc/postgresql/pg_hba   │  /var/log/pg/      │
│  Redis        │  /etc/redis/redis.conf    │  /var/log/redis/   │
│  SSH          │  /etc/ssh/sshd_config     │  /var/log/auth.log │
│  Cron         │  /etc/cron.d/            │  /var/log/cron.log │
│  .NET app     │  /app/appsettings.json   │  /app/logs/        │
│  K8s secrets  │  /run/secrets/ (mounted) │  (stdout)          │
│  K8s config   │  /etc/myapp/ (mounted)   │  (stdout)          │
└───────────────┴───────────────────────────┴────────────────────┘
```

---

## Mental Model Summary — Connect It All

```
┌─────────────────────────────────────────────────────────────────┐
│               THE BIG PICTURE                                   │
│                                                                 │
│   HOST KERNEL                                                   │
│   ┌────────────────────────────────────────────────────────┐   │
│   │                                                        │   │
│   │  /proc/sys/net  ←── shared with privileged containers  │   │
│   │  /sys/fs/cgroup ←── enforces CPU/Memory limits        │   │
│   │                                                        │   │
│   │  OverlayFS (lowerdir=image layers, upperdir=container) │   │
│   │  ┌──────────────┐  ┌──────────────┐                   │   │
│   │  │ Container A  │  │ Container B  │                   │   │
│   │  │              │  │              │                   │   │
│   │  │  PID NS: 1   │  │  PID NS: 1   │ ← both think     │   │
│   │  │  NET NS: eth0│  │  NET NS: eth0│   they are PID 1 │   │
│   │  │  MNT NS: /   │  │  MNT NS: /   │   on their own   │   │
│   │  │              │  │              │   network         │   │
│   │  │  reads /proc │  │  reads /proc │                   │   │
│   │  │  sees HOST   │  │  sees HOST   │ ← GOTCHA!        │   │
│   │  │  memory!     │  │  memory!     │                   │   │
│   │  └──────┬───────┘  └──────┬───────┘                   │   │
│   │         │                 │                            │   │
│   │         └────── share base image layers ───────────────│   │
│   │                (nginx:latest lowerdir)                  │   │
│   └────────────────────────────────────────────────────────┘   │
│                                                                 │
│   KEY INSIGHTS:                                                 │
│   1. / in container ≠ / on host (mount namespace)              │
│   2. /proc in container = HOST kernel data (careful!)          │
│   3. Writes go to upperdir (lost on delete) unless volume      │
│   4. Shared base layers = fast startup, low disk usage         │
│   5. cgroup limits enforced by kernel OUTSIDE container        │
└─────────────────────────────────────────────────────────────────┘
```
