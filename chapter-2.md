# CHAPTER 2: THE LINUX FILESYSTEM

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 2
═══════════════════════════════════════════════════════════════
  PART A  →  The Filesystem Tree & FHS Standard
  PART B  →  Important Directories Explained One by One
  PART C  →  Virtual Filesystems: /proc and /sys
  PART D  →  Inodes — The Real Identity of a File
  PART E  →  Hard Links vs Soft Links
  PART F  →  Mounting — Attaching Storage to the Tree
  PART G  →  Filesystem Types (ext4, XFS, Btrfs...)
  PART H  →  Disk & Filesystem Commands Mastery
  PART I  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: THE FILESYSTEM TREE & FHS STANDARD

## 🌳 Everything Starts From One Root: `/`

This is the single biggest difference between Linux and Windows.

```
WINDOWS vs LINUX FILESYSTEM
═══════════════════════════════════════════════════════════════
  WINDOWS                          LINUX
  ───────                          ─────
  C:\  (System drive)              /  (Root — everything starts here)
  D:\  (Data drive)                   │
  E:\  (USB drive)                    ├── /home
  Each drive = separate tree          ├── /etc
                                      ├── /var
  Multiple ROOTS                      ├── /mnt/usb  ← USB attaches HERE
                                      └── ...
                                   ONE ROOT, everything is a
                                   branch hanging off it!
═══════════════════════════════════════════════════════════════
```

In Linux, your USB drive, your second hard disk, even a remote network folder — **all of them get attached (mounted) somewhere inside the same single tree** that starts at `/`.

## 🌲 The Linux Directory Tree (Visualized)

```
THE LINUX FILESYSTEM TREE
═══════════════════════════════════════════════════════════════════════

                                  /  (ROOT)
                                  │
        ┌──────┬──────┬──────┬──┴───┬──────┬──────┬──────┬──────┐
        │      │      │      │      │      │      │      │      │
      /bin   /boot  /dev   /etc   /home  /lib   /media /mnt   /opt
        │
        │
   ┌──────┬──────┬──────┬──────┬──────┬──────┐
   │      │      │      │      │      │      │
 /proc  /root  /run   /sbin  /srv   /sys   /tmp
                                              │
                                       ┌──────┴──────┐
                                       │             │
                                     /usr          /var
                                       │             │
                              ┌────────┼────────┐    ├── /var/log
                            /usr/bin /usr/lib /usr/  ├── /var/www
                                              local   └── /var/spool

═══════════════════════════════════════════════════════════════════════
```

## 📐 What is FHS?

**FHS = Filesystem Hierarchy Standard**

It's a **rulebook** that says: "Configuration files go HERE, logs go HERE, user data goes HERE." Every major Linux distribution (Ubuntu, RHEL, Fedora, Debian, Arch) follows this standard. That's why once you learn Linux on Ubuntu, you instantly understand RHEL too!

```
WHY FHS MATTERS
═══════════════════════════════════════════════════════════════
  Without FHS:                    With FHS:
  Every distro puts files          Every distro agrees:
  wherever they want.              • Configs → /etc
  Chaos! 😫                        • Logs → /var/log
                                   • User data → /home
                                   • Programs → /usr/bin
                                   Predictable! 😊
═══════════════════════════════════════════════════════════════
```

### Real World: Explore the Tree

```bash
# See the top-level structure
ls -l /

# See it as an actual tree diagram
tree -L 1 /                    # Install: sudo apt install tree
tree -L 2 /etc                 # 2 levels deep into /etc

# See the FHS man page (yes, it has its own manual!)
man hier

# Count directories under root
ls -d /*/ | wc -l
```

**Sample Output of `ls -l /`:**

```
drwxr-xr-x   2 root root  4096 Jan  1 10:00 bin -> usr/bin
drwxr-xr-x   3 root root  4096 Jan  1 10:00 boot
drwxr-xr-x  19 root root  3680 Jun 14 09:00 dev
drwxr-xr-x 140 root root 12288 Jun 14 08:55 etc
drwxr-xr-x   3 root root  4096 Mar  2 11:20 home
...
```

---

# PART B: IMPORTANT DIRECTORIES EXPLAINED ONE BY ONE

## 📁 The Complete Directory Reference Table

| Directory | Full Meaning          | What Lives Here                      | Real Example                |
| --------- | --------------------- | ------------------------------------ | --------------------------- |
| `/`       | Root                  | Top of the entire tree               | Everything starts here      |
| `/bin`    | Binaries              | Essential user commands              | `ls`, `cp`, `cat`           |
| `/sbin`   | System Binaries       | Admin-only commands                  | `fdisk`, `reboot`           |
| `/boot`   | Boot files            | Kernel + bootloader files            | `vmlinuz`, `initrd.img`     |
| `/dev`    | Devices               | Hardware represented as files        | `/dev/sda`, `/dev/null`     |
| `/etc`    | Etcetera (configs)    | System-wide configuration            | `/etc/passwd`, `/etc/fstab` |
| `/home`   | Home directories      | Personal user folders                | `/home/ahmed`               |
| `/lib`    | Libraries             | Shared libraries for /bin, /sbin     | `libc.so`                   |
| `/media`  | Media                 | Auto-mounted removable devices       | USB drives, CDs             |
| `/mnt`    | Mount                 | Temporary manual mount point         | Manually mounted disks      |
| `/opt`    | Optional              | Third-party software                 | Custom installed apps       |
| `/proc`   | Process info          | Virtual files about kernel/processes | `/proc/cpuinfo`             |
| `/root`   | Root's home           | Home directory of root user          | NOT same as `/`!            |
| `/run`    | Runtime data          | Data since last boot                 | PID files, sockets          |
| `/srv`    | Service data          | Data for servers (web, ftp)          | Website files               |
| `/sys`    | System                | Virtual files about kernel/devices   | `/sys/class`                |
| `/tmp`    | Temporary             | Temp files, cleared on reboot        | Scratch space               |
| `/usr`    | Unix System Resources | Most user programs & data            | `/usr/bin`, `/usr/share`    |
| `/var`    | Variable data         | Data that changes constantly         | Logs, mail, caches          |

## 🏠 `/home` — Your Personal Space

```
/home STRUCTURE
═══════════════════════════════════════════
  /home
    ├── ahmed/           ← User "ahmed" lives here
    │     ├── Desktop/
    │     ├── Documents/
    │     ├── Downloads/
    │     ├── .bashrc      (hidden config file)
    │     └── .ssh/        (hidden SSH keys folder)
    │
    └── fatima/          ← User "fatima" lives here
          ├── Desktop/
          └── Documents/
═══════════════════════════════════════════
```

```bash
echo $HOME                 # Shows your home directory path
cd ~                        # Go to your home directory
ls -la ~                    # See hidden files in home (dotfiles)
```

> **📌 Key Point:** Files/folders starting with `.` (dot) are **hidden** by default. `.bashrc`, `.ssh`, `.config` are common examples. Use `ls -a` to see them.

## ⚙️ `/etc` — The Control Room

Almost EVERY configuration file on Linux lives in `/etc`. If you want to change how something behaves system-wide, you'll edit a file here.

```bash
cat /etc/passwd             # All user accounts
cat /etc/group              # All groups
cat /etc/hostname           # This machine's name
cat /etc/hosts              # Manual IP-to-name mappings
cat /etc/fstab              # Filesystems to auto-mount at boot
cat /etc/os-release         # Which Linux distro is this?
ls /etc/ssh/                # SSH server configuration folder
ls /etc/systemd/system/     # Custom systemd services
```

**Important `/etc` files to know:**

| File               | Purpose                                  |
| ------------------ | ---------------------------------------- |
| `/etc/passwd`      | User account database                    |
| `/etc/shadow`      | Encrypted passwords (root only readable) |
| `/etc/group`       | Group definitions                        |
| `/etc/fstab`       | Filesystems mounted at boot              |
| `/etc/hosts`       | Manual hostname → IP mapping             |
| `/etc/hostname`    | This machine's hostname                  |
| `/etc/resolv.conf` | DNS server settings                      |
| `/etc/sudoers`     | Who can use `sudo`                       |
| `/etc/crontab`     | System-wide scheduled jobs               |

## 📊 `/var` — The "Variable" Data Folder

Data here **changes constantly** — logs grow, mail arrives, caches fill up.

```bash
ls /var/log/                # All system logs live here
tail -f /var/log/syslog     # Watch system log live (Debian/Ubuntu)
tail -f /var/log/messages   # Watch system log live (RHEL/CentOS)
du -sh /var/log/*           # See size of each log file
ls /var/www/                # Default website files location
ls /var/spool/cron/         # Scheduled cron jobs per user
ls /var/cache/              # Cached data from package managers etc.
```

```
/var/log — YOUR DEBUGGING TREASURE CHEST
═══════════════════════════════════════════════════════
  /var/log/syslog       → General system messages (Debian/Ubuntu)
  /var/log/auth.log      → Login attempts, sudo usage
  /var/log/kern.log      → Kernel messages
  /var/log/dpkg.log      → Package install/remove history
  /var/log/nginx/        → Web server logs
  /var/log/mysql/        → Database logs
═══════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"A user says the disk is full but `df -h` looks fine on `/`. What do you check?"_ **Answer:** Check `/var/log` for runaway log files (`du -sh /var/log/*`), check inode usage with `df -i`, and check for deleted-but-open files using `lsof | grep deleted`.

## 🧰 `/usr` — Where Most Software Actually Lives

Don't be fooled by the name — `/usr` doesn't mean "user." It stands for **Unix System Resources**, and it holds the bulk of installed programs.

```
/usr STRUCTURE
═══════════════════════════════════════════
  /usr
    ├── bin/        ← Most user commands (python3, vim, git)
    ├── sbin/        ← Most admin commands
    ├── lib/         ← Libraries for /usr/bin programs
    ├── local/       ← Manually compiled/installed software
    ├── share/       ← Shared data: docs, icons, man pages
    └── include/     ← C/C++ header files for development
═══════════════════════════════════════════
```

```bash
ls /usr/bin | wc -l         # Count how many commands are available!
ls /usr/share/man           # Manual page sources
ls /usr/local/bin           # Custom-installed programs
which python3               # Usually /usr/bin/python3
```

## 🥾 `/boot` — Kernel and Bootloader Files

```bash
ls -lh /boot/
# Typical contents:
#   vmlinuz-6.5.0-35-generic   ← The compressed Linux kernel itself!
#   initrd.img-6.5.0-35-generic ← Initial RAM disk (mini filesystem for boot)
#   grub/                      ← GRUB bootloader files
#   config-6.5.0-35-generic    ← Kernel build configuration
```

> **⚠️ Never delete files in `/boot` unless you know exactly what you're doing** — your system won't boot without them!

## 🔌 `/dev` — Hardware as Files (The Linux Philosophy)

This is one of the most beautiful ideas in Linux: **"Everything is a file."** Even hardware devices appear as files you can read/write.

```
/dev EXAMPLES
═══════════════════════════════════════════════════════
  /dev/sda           → First hard disk (whole disk)
  /dev/sda1          → First partition on that disk
  /dev/nvme0n1       → First NVMe SSD
  /dev/null          → The "black hole" — discards anything written
  /dev/zero          → Infinite stream of zero bytes
  /dev/random        → Random data generator
  /dev/tty1          → A terminal session
  /dev/usb/          → USB devices
═══════════════════════════════════════════════════════
```

```bash
ls -l /dev/sda*             # See your disk and its partitions
ls -l /dev/null             # The famous "trash bin" device

# Practical examples of /dev/null:
command > /dev/null              # Discard normal output
command > /dev/null 2>&1         # Discard ALL output (errors too)
echo "test" > /dev/null          # Output vanishes — verify it does nothing

# /dev/zero example: create a 100MB blank file
dd if=/dev/zero of=testfile bs=1M count=100
```

> **🎓 Interview Question:** _"What is `/dev/null` used for?"_ **Answer:** It's a special device file that discards everything written to it and returns EOF when read. Commonly used to silence command output: `command > /dev/null 2>&1`.

---

# PART C: VIRTUAL FILESYSTEMS — /proc AND /sys

## 🌀 These Aren't Real Files — They're Windows Into the Kernel!

This is a mind-blowing concept for beginners: `/proc` and `/sys` don't contain real files on disk. They're **virtual** — generated by the kernel **live, in real time**, as you read them.

```
VIRTUAL FILESYSTEM CONCEPT
═══════════════════════════════════════════════════════════════
  Normal file:                    /proc file:
  Stored on disk                  Generated by kernel on-the-fly
  cat file.txt                    cat /proc/cpuinfo
  → reads bytes from disk         → kernel builds the text RIGHT NOW
                                   and hands it to you
  Size shown might be 0 or odd —  that's normal for virtual files!
═══════════════════════════════════════════════════════════════
```

## 📂 `/proc` — A Window Into Every Running Process

Every running process gets its own folder inside `/proc`, named by its **Process ID (PID)**.

```bash
ls /proc | grep -E "^[0-9]+$" | head    # See process ID folders
echo $$                                  # Show current shell's PID
ls /proc/$$/                             # Explore your own shell's info

cat /proc/cpuinfo          # CPU details (used by lscpu internally!)
cat /proc/meminfo          # Memory details (used by free internally!)
cat /proc/version          # Kernel version string
cat /proc/uptime           # System uptime in seconds
cat /proc/loadavg          # System load average
cat /proc/1/status         # Status of PID 1 (systemd)
cat /proc/1/cmdline        # Command line that started PID 1
ls /proc/1/fd/             # Open file descriptors of PID 1
```

**Useful `/proc` entries:**

| Path                | What It Shows                           |
| ------------------- | --------------------------------------- |
| `/proc/cpuinfo`     | CPU information                         |
| `/proc/meminfo`     | Memory information                      |
| `/proc/version`     | Kernel version                          |
| `/proc/uptime`      | How long system has run                 |
| `/proc/loadavg`     | CPU load averages                       |
| `/proc/PID/status`  | A process's memory, state, etc.         |
| `/proc/PID/cmdline` | Command that launched a process         |
| `/proc/PID/fd/`     | Files currently opened by that process  |
| `/proc/sys/`        | Kernel tunable parameters (read/write!) |

### 🔧 Tuning the Kernel Live Through `/proc`

```bash
# View a kernel parameter
cat /proc/sys/net/ipv4/ip_forward     # Is IP forwarding on? (0 or 1)

# Change it LIVE (no reboot needed!)
sudo sysctl -w net.ipv4.ip_forward=1
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# See ALL tunable kernel parameters
sysctl -a | less

# Make a change PERMANENT (survives reboot)
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p          # Reload from config file
```

## 🗃️ `/sys` — Window Into Devices and Drivers

While `/proc` focuses on processes, `/sys` focuses on **hardware devices, drivers, and kernel objects**.

```bash
ls /sys/class/                 # See device classes (net, block, etc.)
ls /sys/class/net/             # See network interfaces
ls /sys/class/block/           # See block storage devices
cat /sys/class/net/eth0/address    # MAC address of eth0 (live from kernel!)
cat /sys/class/power_supply/BAT0/capacity   # Battery percentage (laptops)
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq   # CPU0's current speed!
```

```
/proc vs /sys — THE DIFFERENCE
═══════════════════════════════════════════════════════════════
  /proc                              /sys
  ─────                              ────
  Focus: Processes + kernel info     Focus: Devices + drivers
  Older (since Linux 1.0)            Newer (since Linux 2.6)
  Less organized                     Strict, well-organized structure
  Example: /proc/cpuinfo             Example: /sys/class/net/eth0
═══════════════════════════════════════════════════════════════
```

---

# PART D: INODES — THE REAL IDENTITY OF A FILE

## 🆔 What Is an Inode?

This is one of THE most important Linux concepts. Many beginners never truly understand this — but you will, right now.

> **The filename is NOT the file. The filename is just a label pointing to the real file, which is identified by a number called the inode.**

```
THE INODE CONCEPT
═══════════════════════════════════════════════════════════════════

  What you SEE:               What ACTUALLY exists:
  ─────────────                ──────────────────────
  notes.txt        ────────►   Inode #884521
                                ┌─────────────────────────┐
                                │  Inode #884521 contains:│
                                │  • File size            │
                                │  • Permissions (rwx)    │
                                │  • Owner (UID/GID)      │
                                │  • Timestamps           │
                                │  • Pointers to DATA     │
                                │    BLOCKS on disk       │
                                │  (NOT the filename!)    │
                                └─────────────────────────┘

  The directory is just a TABLE mapping:
  "notes.txt"  →  Inode #884521
  "report.pdf" →  Inode #991022

═══════════════════════════════════════════════════════════════════
```

### Real World: See Inodes

```bash
ls -i file.txt              # Show inode number of a file
ls -li                      # Long list WITH inode numbers
stat file.txt               # FULL inode details

df -i                       # See inode usage per filesystem (can run out!)
df -ih                      # Human-readable inode usage
```

**Sample `stat` output:**

```
  File: notes.txt
  Size: 1234         Blocks: 8          IO Block: 4096   regular file
Device: 803h/2051d    Inode: 884521      Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/  ahmed)   Gid: ( 1000/  ahmed)
Access: 2026-06-14 10:20:11.000000000 +0000
Modify: 2026-06-14 09:15:03.000000000 +0000
Change: 2026-06-14 09:15:03.000000000 +0000
```

```
UNDERSTANDING THE 3 TIMESTAMPS
═══════════════════════════════════════════════════════
  Access (atime)  → Last time file was READ
  Modify (mtime)  → Last time CONTENT was changed
  Change (ctime)  → Last time METADATA changed
                     (permissions, owner, etc.)
═══════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Why can you delete a file while a program is still using it on Linux, but not on Windows?"_ **Answer:** On Linux, "deleting" a file just removes its name from the directory listing. If a process still has the inode open (a file descriptor pointing to it), the actual data blocks stay alive until that process closes the file. Windows locks files while open, but Linux uses reference counting on the inode.

### ⚠️ Running Out of Inodes (A Real Production Problem!)

```bash
# Disk shows space available, but you still get "No space left on device"?
df -h        # Shows plenty of space...
df -i        # ...but THIS shows 100% inode usage!

# This happens when millions of TINY files fill up all inode slots
# Common cause: mail servers, session cache folders, log spam
```

---

# PART E: HARD LINKS VS SOFT LINKS

## 🔗 Two Ways to "Link" to a File

```
HARD LINK vs SOFT LINK (SYMLINK)
═══════════════════════════════════════════════════════════════════

  HARD LINK                          SOFT LINK (Symbolic Link)
  ──────────                         ──────────────────────────

  file.txt ──┐                       file.txt
             ├──► Inode #884521       (real file, inode #884521)
  link.txt ──┘                            ▲
                                           │ (just a pointer/path)
  Both names point to the           shortcut.txt
  SAME inode — they are              (different inode, #991022,
  literally the same file            contains the TEXT
  with two names!                    "/home/ahmed/file.txt")

  • Same inode number                • Different inode number
  • Same file content always         • Breaks if original moves/deleted
  • Cannot link across               • CAN link across filesystems
    different filesystems            • Can link to directories
  • Cannot link to a directory       • Shows as "broken link" if
  • Deleting one doesn't               target is missing
    delete the data (until
    ALL links are removed)

═══════════════════════════════════════════════════════════════════
```

### Real World: Creating Links

```bash
# Create original file
echo "Original content" > original.txt

# CREATE A HARD LINK
ln original.txt hardlink.txt
ls -li original.txt hardlink.txt    # SAME inode number!

# Edit through either name — both show the change!
echo "Changed!" >> hardlink.txt
cat original.txt                    # Shows "Changed!" too!

# CREATE A SOFT LINK (SYMLINK)
ln -s original.txt softlink.txt
ls -li original.txt softlink.txt    # DIFFERENT inode numbers!
ls -l softlink.txt                  # Shows: softlink.txt -> original.txt

# What happens if we delete the original?
rm original.txt
cat hardlink.txt                    # Still works! Data survives.
cat softlink.txt                    # BROKEN! "No such file or directory"
ls -l softlink.txt                  # Shows in red: broken link
```

### Hard Link Counter

```bash
ls -l original.txt
# -rw-r--r-- 2 ahmed ahmed 18 Jun 14 10:00 original.txt
#            │
#            └── This "2" means 2 hard links point to this inode!

stat original.txt | grep Links     # Confirms: Links: 2
```

### When To Use Which?

| Use Case                                          | Use This  |
| ------------------------------------------------- | --------- |
| Linking across different disks/partitions         | Soft link |
| Linking to a directory                            | Soft link |
| You want the link to survive original being moved | Hard link |
| You want a simple "shortcut" (like Windows)       | Soft link |
| Backup systems wanting space-efficient duplicates | Hard link |
| Configuration management (`/etc/alternatives`)    | Soft link |

```bash
# Real-world symlink example: switching Python versions
ls -l /usr/bin/python3
# /usr/bin/python3 -> python3.11

sudo ln -sf /usr/bin/python3.12 /usr/bin/python3   # Switch the symlink!
```

---

# PART F: MOUNTING — ATTACHING STORAGE TO THE TREE

## 🔧 What Is Mounting?

Remember: Linux has only ONE tree, starting at `/`. So how does a second disk, USB drive, or network folder become accessible?

**Answer: Mounting** — attaching a storage device's filesystem to a specific folder (called a **mount point**) inside the existing tree.

```
THE MOUNTING CONCEPT
═══════════════════════════════════════════════════════════════════

  BEFORE MOUNTING:                AFTER MOUNTING /dev/sdb1 to /mnt/usb:

       /                                    /
       │                                    │
   ┌───┼───┐                            ┌───┼───┐
   │   │   │                            │   │   │
  etc home mnt                        etc home mnt
       │    │ (empty folder)               │    │
                                            │  usb/ ◄── now shows USB
                                            │     ├── photo.jpg
       [USB Drive]                         │     └── document.pdf
       /dev/sdb1                           │
       (separate filesystem,                    USB drive's files now
        not yet visible)                         appear INSIDE the tree!

═══════════════════════════════════════════════════════════════════
```

### Real World: Mounting Commands

```bash
# See ALL currently mounted filesystems
mount
df -h                          # Simpler view with disk usage

# See it in a clean table
findmnt

# MOUNT a device manually
sudo mkdir -p /mnt/usb              # Create the mount point folder first
sudo mount /dev/sdb1 /mnt/usb       # Mount the USB partition there
ls /mnt/usb                         # See its contents now!

# UNMOUNT (always do this before removing USB!)
sudo umount /mnt/usb
# or by device:
sudo umount /dev/sdb1

# If "device is busy" error:
sudo lsof /mnt/usb                  # See what's using it
sudo fuser -k /mnt/usb              # Force kill processes using it (careful!)
```

## 📜 `/etc/fstab` — Auto-Mount at Boot

If you want a drive to mount automatically every time the system boots, you add it to `/etc/fstab`.

```bash
cat /etc/fstab
```

**Sample `/etc/fstab`:**

```
# <device>                                <mount point>   <type>  <options>       <dump> <pass>
UUID=1a2b3c4d-... /                        ext4    errors=remount-ro 0       1
UUID=5e6f7g8h-... /boot                    ext4    defaults          0       2
UUID=9i0j1k2l-... /boot/efi                vfat    umask=0077        0       1
/dev/sdb1          /mnt/data               ext4    defaults          0       2
```

```
READING AN /etc/fstab LINE
═══════════════════════════════════════════════════════════════
  UUID=xxxx   /          ext4    defaults    0    1
     │         │           │         │        │    │
     │         │           │         │        │    └─ fsck order (1=root first)
     │         │           │         │        └────── dump backup flag (usually 0)
     │         │           │         └─────────────── mount options
     │         │           └───────────────────────── filesystem type
     │         └───────────────────────────────────── where to mount it
     └─────────────────────────────────────────────── which device/partition
═══════════════════════════════════════════════════════════════
```

```bash
# Find a partition's UUID (use this instead of /dev/sdX which can change!)
sudo blkid

# Test your fstab WITHOUT rebooting (important before you reboot!)
sudo mount -a              # Mounts everything listed in fstab
# If this gives no errors, your fstab is safe to reboot with!
```

> **⚠️ WARNING:** A broken `/etc/fstab` can prevent your system from booting at all! Always test with `sudo mount -a` before rebooting, and always use `nofail` option for non-critical drives: `/dev/sdb1 /mnt/data ext4 defaults,nofail 0 2`

---

# PART G: FILESYSTEM TYPES

## 💽 Common Linux Filesystem Types

```
POPULAR LINUX FILESYSTEMS
═══════════════════════════════════════════════════════════════
  ext4    → Most common default (Ubuntu, Debian). Reliable, mature.
  XFS     → Default on RHEL/CentOS. Great for large files, servers.
  Btrfs   → Modern, supports snapshots, used by openSUSE, Fedora option.
  ZFS     → Advanced features (snapshots, checksums), needs more RAM.
  vfat/   → Used for EFI boot partition, USB compatibility with
  FAT32     Windows.
  NTFS    → Windows filesystem, Linux can read/write with ntfs-3g.
  tmpfs   → Lives in RAM only! Used for /tmp, /run. Vanishes on reboot.
  swap    → Not really a filesystem — disk space used as virtual RAM.
═══════════════════════════════════════════════════════════════
```

```bash
# Check filesystem type of each mounted partition
df -hT

# Check filesystem type of a specific device
sudo blkid /dev/sda1
lsblk -f

# Create a new filesystem on a partition (DESTROYS existing data!)
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.xfs /dev/sdb1
```

---

# PART H: DISK & FILESYSTEM COMMANDS MASTERY

## 🛠️ The Complete Toolkit

### `df` — Disk Free (Space Used/Available)

```bash
df -h                  # Human-readable sizes (GB, MB)
df -h /home            # Just check one mount point
df -i                  # Inode usage instead of space
df -T                  # Show filesystem type too
df -hT                 # Combine: human-readable + type
```

**Syntax:** `df [OPTIONS] [FILE]`

| Option | Meaning                                      |
| ------ | -------------------------------------------- |
| `-h`   | Human-readable (KB, MB, GB instead of bytes) |
| `-i`   | Show inode info instead of block info        |
| `-T`   | Show filesystem type                         |
| `-a`   | Include pseudo/virtual filesystems too       |

### `du` — Disk Usage (Per File/Folder)

```bash
du -sh /var/log              # Total size of /var/log (summary, human-readable)
du -h /home/ahmed            # Size of every item inside, recursively
du -sh /home/*               # Size of each user's home folder
du -ah /home/ahmed | sort -rh | head -10   # Top 10 largest items
```

**Syntax:** `du [OPTIONS] [PATH]`

| Option | Meaning                                   |
| ------ | ----------------------------------------- |
| `-s`   | Summary only (don't list every subfolder) |
| `-h`   | Human-readable sizes                      |
| `-a`   | Show files too, not just directories      |
| `-c`   | Show grand total at the end               |

> **🎓 Common Mistake:** Confusing `df` and `du`! Remember: `df` = "disk FREE" (whole filesystem view), `du` = "disk USAGE" (specific files/folders). A classic gotcha: `df` can show a disk as full even when `du` of visible files looks small — this happens when a deleted file is still held open by a running process.

### `mount` / `umount`

```bash
mount | column -t                  # Pretty-print all mounts
mount | grep "^/dev"                # Only real device mounts
sudo mount -t ext4 /dev/sdb1 /mnt   # Mount specifying filesystem type
sudo mount -o ro /dev/sdb1 /mnt     # Mount as READ-ONLY
sudo umount /mnt                    # Unmount
sudo umount -l /mnt                 # Lazy unmount (if busy)
```

### `fdisk` / `parted` — Partition Management

```bash
sudo fdisk -l                  # List all disks and partitions
sudo fdisk /dev/sdb             # Interactive partition editor (CAREFUL!)
  # Inside fdisk:
  #   p = print partition table
  #   n = new partition
  #   d = delete partition
  #   w = write changes (PERMANENT!)
  #   q = quit without saving

sudo parted -l                  # List partitions (alternative tool)
```

### `lsblk` — List Block Devices (Visual Tree)

```bash
lsblk                  # Tree view of disks and partitions
lsblk -f                # Include filesystem type and UUID
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT     # Custom columns
```

### `blkid` — Identify Block Devices

```bash
sudo blkid                      # Show UUID and filesystem type for all devices
sudo blkid /dev/sda1             # Just one device
```

### `find` — Locate Files by Inode, Size, Date, etc.

```bash
find / -inum 884521 2>/dev/null         # Find file BY inode number!
find / -xdev -size +500M 2>/dev/null    # Files >500MB, stay on one filesystem
find / -mtime -1 2>/dev/null            # Modified in last 24 hours
find /var/log -name "*.log" -mtime +30 -delete   # Delete logs older than 30 days
```

### `stat` — Full Metadata of a File

```bash
stat /etc/passwd
stat -f /home              # Stats about the FILESYSTEM itself, not a file
```

---

# PART I: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 2 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Filesystem Tree:
     • Everything starts at ONE root: /
     • No drive letters like Windows (C:\, D:\)
     • FHS standard makes all distros consistent

  ✅ Key Directories:
     /etc = configs   /var = logs/changing data   /home = user files
     /usr = software   /boot = kernel files         /dev = hardware-as-files

  ✅ Virtual Filesystems:
     /proc = live process & kernel info (generated on-the-fly)
     /sys  = live device & driver info, organized by class

  ✅ Inodes:
     • The REAL identity of a file (not its name!)
     • Contains size, permissions, owner, timestamps, data block pointers
     • Filenames are just labels in a directory table

  ✅ Links:
     • Hard link = same inode, same data, cannot cross filesystems
     • Soft link = pointer to a path, can break, can cross filesystems

  ✅ Mounting:
     • Attaching a device's filesystem to a folder (mount point)
     • /etc/fstab = auto-mount configuration for boot time
     • Always test fstab changes with `mount -a` before rebooting!

  ✅ Filesystem Types:
     ext4 (default), XFS (RHEL/servers), Btrfs (snapshots),
     tmpfs (RAM-based), swap (virtual RAM on disk)

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 2 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

DIRECTORY EXPLORATION          INODES & LINKS                 MOUNTING
──────────────────────         ─────────────────────         ───────────────────
tree -L 2 /etc   Tree view     ls -i file        Inode #      mount             List all
man hier         FHS manual    ls -li            Inode + perm df -h              Disk usage
ls -l /          Top level     stat file         Full meta    findmnt           Clean table
                                ln a b            Hard link    sudo mount dev mp Mount manually
PROC & SYS                     ln -s a b         Soft link    sudo umount mp    Unmount
──────────────────────         df -i             Inode usage  cat /etc/fstab    Auto-mount cfg
cat /proc/cpuinfo  CPU info                                    sudo mount -a    Test fstab
cat /proc/meminfo  RAM info    DISK USAGE
cat /proc/uptime   Uptime      ─────────────────────         FILESYSTEM TYPES
ls /sys/class/net  NICs        df -h    Free space (disk)    ───────────────────
sysctl -a          Tunables    du -sh   Used space (folder)  sudo blkid        UUID + type
sysctl -w x=1       Set live   du -sh /* Per-folder sizes     lsblk -f          Tree + fs type
                                                               sudo mkfs.ext4    Format (! data loss)

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 2 Interview Questions

| #   | Question                                                            | Key Answer Points                                                                                           |
| --- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| 1   | What is FHS?                                                        | Filesystem Hierarchy Standard — defines where files go on Linux                                             |
| 2   | What's the difference between `/proc` and `/sys`?                   | `/proc`=process/kernel info (older); `/sys`=devices/drivers (newer, structured)                             |
| 3   | What is an inode?                                                   | Data structure storing file metadata (size, perms, owner, data block pointers); the real identity of a file |
| 4   | Difference between hard link and soft link?                         | Hard link = same inode, can't cross filesystems; soft link = path pointer, can break, can cross filesystems |
| 5   | What happens when you delete a file that's still open by a process? | Data stays alive until last reference (inode link/fd) is closed; this is why `df` and `du` can disagree     |
| 6   | What is mounting?                                                   | Attaching a filesystem from a device to a directory (mount point) in the existing tree                      |
| 7   | What is `/etc/fstab`?                                               | Config file listing filesystems to mount automatically at boot                                              |
| 8   | Difference between `df` and `du`?                                   | `df` = filesystem-level free/used space; `du` = file/folder-level usage                                     |
| 9   | Can you run out of disk space even if `df -h` shows space free?     | Yes — if inodes are exhausted (`df -i` shows 100%) even with free space in bytes                            |
| 10  | What is `/dev/null` used for?                                       | Discarding unwanted output: `command > /dev/null 2>&1`                                                      |
| 11  | What is tmpfs?                                                      | A filesystem stored in RAM, not disk — fast but lost on reboot (used for /tmp, /run)                        |
| 12  | Why use UUID instead of `/dev/sdX` in fstab?                        | Device names like `/dev/sdb` can change between reboots; UUIDs are permanent identifiers                    |

## 🔬 Practical Lab: Chapter 2 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: Tree Exploration
# ──────────────────────────────────────────────────────────────────
ls -l /
tree -L 1 /                          # Top-level tree
cat /etc/os-release
cat /etc/fstab
df -hT                               # All mounted filesystems + types

# ──────────────────────────────────────────────────────────────────
# LAB 2: Exploring /proc and /sys
# ──────────────────────────────────────────────────────────────────
echo $$                              # Your shell's PID
ls /proc/$$/
cat /proc/cpuinfo | grep "model name" | head -1
cat /proc/meminfo | head -3
cat /proc/uptime
ls /sys/class/net/
cat /sys/class/net/*/address 2>/dev/null   # MAC addresses of all NICs

# ──────────────────────────────────────────────────────────────────
# LAB 3: Inodes in Action
# ──────────────────────────────────────────────────────────────────
mkdir -p ~/lab2 && cd ~/lab2
echo "Hello Inode World" > file1.txt
ls -li file1.txt                     # Note the inode number
stat file1.txt                       # Full metadata

ln file1.txt hardlink1.txt           # Create hard link
ln -s file1.txt softlink1.txt        # Create soft link
ls -li                               # Compare inode numbers!

echo "Edited via hardlink" >> hardlink1.txt
cat file1.txt                        # See the change reflected!

rm file1.txt
cat hardlink1.txt                    # Still works
cat softlink1.txt                    # Broken! (if it errors, that's expected)
ls -l softlink1.txt                  # Shows broken symlink in red

# ──────────────────────────────────────────────────────────────────
# LAB 4: Disk and Mount Investigation
# ──────────────────────────────────────────────────────────────────
lsblk
lsblk -f
df -h
df -i
sudo blkid
mount | grep "^/dev"
findmnt /

# ──────────────────────────────────────────────────────────────────
# LAB 5: Find the Biggest Files/Folders on Your System
# ──────────────────────────────────────────────────────────────────
du -sh /var/log/* 2>/dev/null | sort -rh | head -5
du -ah ~/ 2>/dev/null | sort -rh | head -10
find / -xdev -size +100M 2>/dev/null
```

## 🧠 Mini Project: Filesystem Health Check Script

```bash
cat > ~/fs_healthcheck.sh << 'EOF'
#!/bin/bash
# ─────────────────────────────────────────────
# Chapter 2 Mini Project: Filesystem Health Check
# ─────────────────────────────────────────────

echo "========================================"
echo "   FILESYSTEM HEALTH CHECK REPORT"
echo "   $(date)"
echo "========================================"
echo ""

echo "─── DISK SPACE USAGE ──────────────────"
df -hT | grep -v tmpfs
echo ""

echo "─── INODE USAGE ───────────────────────"
df -ih | grep -v tmpfs
echo ""

echo "─── TOP 5 LARGEST DIRECTORIES IN /var ─"
du -sh /var/*/ 2>/dev/null | sort -rh | head -5
echo ""

echo "─── MOUNTED FILESYSTEMS ───────────────"
findmnt -D
echo ""

echo "─── BLOCK DEVICES ─────────────────────"
lsblk -f
echo ""

echo "─── ANY FILESYSTEM ABOVE 80% USAGE? ───"
df -h | awk '$5+0 > 80 {print "⚠️  WARNING: " $0}'
echo ""

echo "========================================"
echo "   END OF REPORT"
echo "========================================"
EOF

chmod +x ~/fs_healthcheck.sh
bash ~/fs_healthcheck.sh
```

## 🗺️ Where You Are in the Linux Roadmap

```
LINUX MASTERY ROADMAP — YOUR PROGRESS
═══════════════════════════════════════════════════════════════════

  ✅ Chapter 1:  Hardware, Boot, OS, Kernel, History, First Commands
  ✅ Chapter 2:  Linux Filesystem (FHS, /proc, /sys, /dev, inodes, links)
  ⬜ Chapter 3:  Users, Groups & Permissions
  ⬜ Chapter 4:  Text Processing (grep, sed, awk, cut, sort)
  ⬜ Chapter 5:  Package Management (apt, yum, dnf, pacman)
  ⬜ Chapter 6:  Shell Scripting (bash, variables, loops, functions)
  ⬜ Chapter 7:  Process Management (ps, top, signals, jobs)
  ⬜ Chapter 8:  Networking (TCP/IP, DNS, SSH, firewall)
  ⬜ Chapter 9:  System Administration (systemd, logging, cron)
  ⬜ Chapter 10: Linux Security (PAM, SELinux, encryption)
  ⬜ Chapter 11: Containers (Docker, namespaces, cgroups)
  ⬜ Chapter 12: Linux Kernel Development

═══════════════════════════════════════════════════════════════════
  YOU ARE HERE: ✅✅ — Two chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

## Next: [Chapter 3 — Users, Groups & Permissions](/chapter-3.md)
