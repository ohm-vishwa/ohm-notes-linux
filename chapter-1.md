# CHAPTER 1: FROM HARDWARE TO HELLO LINUX

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 1
═══════════════════════════════════════════════════════════════
  PART A  →  Computer Hardware (CPU, RAM, Storage, Motherboard)
  PART B  →  BIOS/UEFI and the Boot Process
  PART C  →  What is an Operating System?
  PART D  →  What is the Linux Kernel?
  PART E  →  Linux History, GNU Project, Open Source
  PART F  →  Linux Architecture (Bottom to Top)
  PART G  →  Your First Linux Commands
  PART H  →  Chapter Summary + Cheat Sheet
═══════════════════════════════════════════════════════════════
```

---

# PART A: COMPUTER HARDWARE — THE FOUNDATION

## 🧠 What Is a Computer?

A computer is a machine that:

1. **Takes input** (keyboard, mouse, network)
2. **Processes data** (CPU does the work)
3. **Stores results** (RAM = temporary, Disk = permanent)
4. **Gives output** (screen, speaker, printer)

That's it. Everything else is just detail on top of this idea.

---

## 🖥️ The Motherboard — The City of Your Computer

Think of the motherboard as a **city**. Every component (CPU, RAM, storage) is a building in that city, connected by roads (called **buses**).

```txt
┌─────────────────────────────────────────────────────────────────┐
│                        MOTHERBOARD                              │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────────────┐   │
│  │   CPU    │◄──►│   RAM    │    │      PCIe SLOTS          │   │
│  │(The Brain│    │(Memory)  │    │  [GPU] [NIC] [SSD]       │   │
│  │          │    │          │    └──────────────────────────┘   │
│  └────┬─────┘    └────┬─────┘                                   │
│       │               │                                         │
│  ─────┴───────────────┴──────── SYSTEM BUS ─────────────────    │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                   │
│  │  BIOS/   │    │  SATA    │    │   USB    │                   │
│  │  UEFI    │    │  Ports   │    │  Ports   │                   │
│  │  Chip    │    │ (Drives) │    │          │                   │
│  └──────────┘    └──────────┘    └──────────┘                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ The CPU — The Brain

**CPU = Central Processing Unit**

The CPU is the brain of your computer. It reads instructions from memory and executes them — billions of times per second.

### What does a CPU do?

```
CPU Work Cycle (called the "Fetch-Decode-Execute" cycle)
══════════════════════════════════════════════════════════

  Step 1: FETCH     → Go to RAM and pick up the next instruction
  Step 2: DECODE    → Figure out what that instruction means
  Step 3: EXECUTE   → Actually do it (add, compare, move data)
  Step 4: REPEAT    → Do this 3,000,000,000 times per second (3 GHz)

══════════════════════════════════════════════════════════
```

### CPU Key Terms

| Term             | What It Means                             | Simple Analogy                     |
| ---------------- | ----------------------------------------- | ---------------------------------- |
| **Core**         | One independent processor inside the chip | One worker in a factory            |
| **Thread**       | Virtual worker within a core              | One worker doing 2 tasks at once   |
| **Clock Speed**  | How fast cycles run (GHz)                 | How fast the worker moves          |
| **Cache**        | Super-fast tiny memory inside CPU         | Worker's desk (vs warehouse = RAM) |
| **Architecture** | CPU design (x86_64, ARM, RISC-V)          | Blueprint of the factory           |

### Real World: Check CPU in Linux

```bash
# See your CPU details
lscpu

# Quick one-liner
cat /proc/cpuinfo | grep "model name" | head -1

# How many CPU cores do you have?
nproc

# See real-time CPU usage
top
htop      # (install it: sudo apt install htop)
```

**Sample Output of `lscpu`:**

```
Architecture:            x86_64
CPU(s):                  8
Thread(s) per core:      2
Core(s) per socket:      4
CPU MHz:                 3600.000
CPU max MHz:             4800.0000
Cache L1d:               128 KiB
Cache L2:                1 MiB
Cache L3:                8 MiB
```

> **🎓 Interview Question:** _"What is the difference between a CPU core and a thread?"_ **Answer:** A core is a physical processing unit. A thread (via Hyper-Threading/SMT) allows one core to handle two streams of instructions simultaneously, appearing as two logical CPUs to the OS.

---

## 💾 RAM — Temporary Memory

**RAM = Random Access Memory**

RAM is your computer's **workspace**. When you open Firefox, the program is **copied from disk into RAM** so the CPU can access it fast.

```
Why RAM Matters:
════════════════════════════════════════════════════════
  DISK (SSD):  Fast, but still 10,000x slower than RAM
  RAM:         Super fast — CPU can read it in nanoseconds
  CPU Cache:   Even faster — but only a few MB

  Think of it like this:
  ┌────────┐     ┌───────┐     ┌───────────┐
  │  DISK  │────►│  RAM  │────►│CPU Cache  │────► CPU
  │ (TB)   │     │ (GB)  │     │ (MB/KB)   │
  │ Slow   │     │ Fast  │     │ Very Fast │
  └────────┘     └───────┘     └───────────┘
════════════════════════════════════════════════════════
```

### Real World: Check RAM in Linux

```bash
# See total RAM and usage
free -h

# Detailed memory info
cat /proc/meminfo

# See RAM in real time
watch -n 1 free -h

# Which processes are using the most RAM?
ps aux --sort=-%mem | head -10
```

**Sample Output of `free -h`:**

```
              total        used        free      shared  buff/cache   available
Mem:           15Gi        4.2Gi       8.1Gi      512Mi       2.6Gi      10.2Gi
Swap:         2.0Gi          0B       2.0Gi
```

---

## 💿 Storage — Where Data Lives Forever

Storage keeps data even when power is off. There are two main types:

```
STORAGE TYPES COMPARISON
══════════════════════════════════════════════════════════════════
  HDD (Hard Disk Drive)          SSD (Solid State Drive)
  ─────────────────────          ──────────────────────
  • Has spinning magnetic disks  • No moving parts (flash chips)
  • Slower (100-200 MB/s)        • Much faster (500-7000 MB/s)
  • Cheaper per GB               • More expensive per GB
  • Louder, more fragile         • Silent, durable
  • Good for bulk storage        • Good for OS + applications

  NVMe SSD (even faster!)
  ─────────────────────────
  • Connects via PCIe (not SATA)
  • Speed: up to 7000 MB/s
  • Used in modern laptops/desktops
══════════════════════════════════════════════════════════════════
```

### Real World: Check Storage in Linux

```bash
# See all disks and partitions
lsblk

# See disk space usage (human-readable)
df -h

# See disk usage of a directory
du -sh /home

# See detailed disk info
sudo fdisk -l

# Check disk health (S.M.A.R.T.)
sudo smartctl -a /dev/sda
```

**Sample Output of `lsblk`:**

```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   500G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
├─sda2   8:2    0     1G  0 part /boot
└─sda3   8:3    0 498.5G  0 part /
```

---

## 🔌 Other Important Hardware Components

| Component          | Job                                           | Linux Command to Check    |
| ------------------ | --------------------------------------------- | ------------------------- |
| **GPU**            | Display graphics, AI/ML computation           | `lspci                    |
| **NIC**            | Network Interface Card — connects to internet | `ip link show`            |
| **PSU**            | Power Supply Unit — gives power to everything | (check hardware manually) |
| **USB Controller** | Manages USB devices                           | `lsusb`                   |
| **Sound Card**     | Audio processing                              | `aplay -l`                |

### The `lspci` Command — See All Hardware

```bash
# List all PCI hardware
lspci

# More detailed output
lspci -v

# Filter: just see network cards
lspci | grep -i network

# Filter: just see GPU
lspci | grep -i vga

# See USB devices
lsusb

# See ALL hardware (needs root)
sudo lshw
sudo lshw -short    # compact version
```

---

# PART B: BIOS/UEFI AND THE BOOT PROCESS

## 🔧 BIOS/UEFI — The First Software Your Computer Runs

When you press the power button, the CPU doesn't know where Linux is. The very first software that runs is stored on a small chip on the motherboard.

```
BIOS vs UEFI
════════════════════════════════════════════════════════
  BIOS (Basic Input/Output System)
  ─────────────────────────────────
  • Old technology (1970s–2000s)
  • 16-bit, limited features
  • Supports drives up to 2TB only
  • Text-only interface

  UEFI (Unified Extensible Firmware Interface)
  ─────────────────────────────────────────────
  • Modern replacement for BIOS
  • 64-bit, full features
  • Supports drives larger than 2TB
  • Graphical interface
  • Secure Boot support
  • Faster boot times
════════════════════════════════════════════════════════
```

## 🚀 The Complete Boot Process — Step by Step

This is one of the most important things to understand as a Linux admin. When you press power:

```
THE LINUX BOOT PROCESS
═══════════════════════════════════════════════════════════════════

  PRESS POWER BUTTON
         │
         ▼
  ┌─────────────────────────────────────────────────────────┐
  │  STEP 1: BIOS/UEFI                                      │
  │  • CPU wakes up and runs BIOS/UEFI from ROM chip        │
  │  • BIOS runs POST (Power-On Self Test)                  │
  │  • Checks CPU, RAM, keyboard, storage                   │
  │  • Finds the bootable disk                              │
  └─────────────────────┬───────────────────────────────────┘
                        │
                        ▼
  ┌─────────────────────────────────────────────────────────┐
  │  STEP 2: BOOTLOADER (GRUB2)                             │
  │  • BIOS hands control to GRUB                           │
  │  • GRUB shows boot menu (which OS / kernel version)     │
  │  • GRUB loads the Linux kernel into RAM                 │
  │  • GRUB loads initramfs (temporary mini-filesystem)     │
  └─────────────────────┬───────────────────────────────────┘
                        │
                        ▼
  ┌─────────────────────────────────────────────────────────┐
  │  STEP 3: LINUX KERNEL                                   │
  │  • Kernel decompresses itself                           │
  │  • Detects all hardware                                 │
  │  • Mounts the real root filesystem                      │
  │  • Starts the first process: PID 1                      │
  └─────────────────────┬───────────────────────────────────┘
                        │
                        ▼
  ┌─────────────────────────────────────────────────────────┐
  │  STEP 4: systemd (PID 1 — The Mother of All Processes)  │
  │  • Starts all system services                           │
  │  • Mounts all filesystems                               │
  │  • Starts networking, login screens, etc.               │
  └─────────────────────┬───────────────────────────────────┘
                        │
                        ▼
  ┌─────────────────────────────────────────────────────────┐
  │  STEP 5: LOGIN                                          │
  │  • Terminal login (TTY) or Desktop (Display Manager)    │
  │  • You type your username and password                  │
  │  • Shell starts (bash/zsh)                              │
  └─────────────────────────────────────────────────────────┘
                        │
                        ▼
         YOU ARE NOW IN LINUX! 🎉

═══════════════════════════════════════════════════════════════════
```

### Real World: Inspect Boot in Linux

```bash
# See boot messages from kernel
dmesg | less
dmesg | head -30          # First 30 lines
dmesg | grep -i error     # Any errors during boot?
dmesg | grep -i usb       # USB detection at boot

# See systemd boot log
journalctl -b             # Full boot log
journalctl -b -p err      # Only errors from this boot
journalctl -b -1          # Previous boot's log

# See how long boot took
systemd-analyze
systemd-analyze blame     # What service took longest?
systemd-analyze critical-chain

# See GRUB configuration
cat /etc/default/grub
ls /boot/grub/
```

**Sample `systemd-analyze` output:**

```
Startup finished in 3.142s (firmware) + 2.531s (loader) + 1.683s (kernel) + 8.432s (userspace) = 15.789s
graphical.target reached after 8.423s in userspace.
```

---

# PART C: WHAT IS AN OPERATING SYSTEM?

## 🏗️ The OS — The Manager Between You and Hardware

An Operating System (OS) is software that:

```
WITHOUT AN OS                    WITH AN OS
═══════════════════════════════════════════════════════
  Your app would need to         OS handles everything:
  know exact memory addresses,
  exact disk sectors,            ┌─────────────────────┐
  exact CPU instructions,        │  Your Application   │
  exact network protocols...     └─────────┬───────────┘
                                           │ (system calls)
  IMPOSSIBLE for every app       ┌─────────▼───────────┐
  to do this!                    │  Operating System   │
                                 │  (Linux Kernel)     │
                                 └─────────┬───────────┘
                                           │
                                 ┌─────────▼───────────┐
                                 │     Hardware        │
                                 │  CPU, RAM, Disk     │
                                 └─────────────────────┘
═══════════════════════════════════════════════════════
```

### What Does the OS Manage?

| OS Job                 | What It Does                         | Example                                |
| ---------------------- | ------------------------------------ | -------------------------------------- |
| **Process Management** | Creates/stops programs, shares CPU   | Running Firefox + Spotify at same time |
| **Memory Management**  | Gives RAM to programs, takes it back | Each app gets its own memory space     |
| **File System**        | Organizes files on disk              | `/home/user/file.txt`                  |
| **Device Drivers**     | Talks to hardware                    | Prints to printer, reads USB           |
| **Networking**         | TCP/IP, sockets, WiFi                | Loading a webpage                      |
| **Security**           | Users, permissions, login            | Only root can edit `/etc/passwd`       |
| **Scheduling**         | Decides which program runs on CPU    | Multitasking                           |

---

# PART D: THE LINUX KERNEL

## 🫀 The Kernel — The Heart of Linux

The **kernel** is the core of the OS. Everything else (shell, apps, desktop) is built on top of it.

```
LINUX SYSTEM LAYERS
═══════════════════════════════════════════════════════════════════
                                                          OUTERMOST
  ┌─────────────────────────────────────────────────────────────┐
  │           USER APPLICATIONS                                 │
  │    (Firefox, VLC, bash, Python, vim, gcc...)                │
  └─────────────────────┬───────────────────────────────────────┘
                        │  uses
  ┌─────────────────────▼───────────────────────────────────────┐
  │           STANDARD LIBRARIES                                │
  │    (glibc — the C standard library)                         │
  │    printf(), malloc(), fopen(), socket()...                 │
  └─────────────────────┬───────────────────────────────────────┘
                        │  makes
  ┌─────────────────────▼───────────────────────────────────────┐
  │           SYSTEM CALLS (syscalls)                           │
  │    The bridge between user space and kernel space           │
  │    read(), write(), open(), fork(), exec(), mmap()...       │
  └─────────────────────┬───────────────────────────────────────┘
                        │  enters
  ┌─────────────────────▼───────────────────────────────────────┐
  │           LINUX KERNEL (Kernel Space)                       │
  │                                                             │
  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐    │
  │  │ Process  │ │ Memory   │ │ File     │ │  Network     │    │
  │  │ Manager  │ │ Manager  │ │ System   │ │  Stack       │    │
  │  └──────────┘ └──────────┘ └──────────┘ └──────────────┘    │
  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐    │
  │  │ Device   │ │Security  │ │ IPC      │ │  Scheduler   │    │
  │  │ Drivers  │ │ (SELinux)│ │          │ │              │    │
  │  └──────────┘ └──────────┘ └──────────┘ └──────────────┘    │
  └─────────────────────┬───────────────────────────────────────┘
                        │  controls
  ┌─────────────────────▼───────────────────────────────────────┐
  │           HARDWARE                                          │
  │    CPU  │  RAM  │  Disk  │  NIC  │  GPU  │  USB             │
  └─────────────────────────────────────────────────────────────┘
                                                          INNERMOST
═══════════════════════════════════════════════════════════════════
```

### Real World: Inspect the Kernel

```bash
# What kernel version are you running?
uname -r

# Full kernel info
uname -a

# Detailed OS info
cat /etc/os-release

# See loaded kernel modules
lsmod

# See kernel messages in real time
sudo dmesg -w

# Kernel version and build date
uname -v

# See system information summary
hostnamectl
```

**Sample `uname -a` output:**

```
Linux ubuntu-server 6.5.0-35-generic #35-Ubuntu SMP PREEMPT_DYNAMIC x86_64 GNU/Linux
```

Let's break this down:

```
Linux           → OS name
ubuntu-server   → hostname (computer's name)
6.5.0-35        → kernel version (major.minor.patch)
generic         → kernel flavor
x86_64          → CPU architecture (64-bit Intel/AMD)
GNU/Linux       → It's GNU tools + Linux kernel
```

---

## 🔐 User Space vs Kernel Space

This is a CRITICAL concept that shows up in interviews constantly.

```
USER SPACE vs KERNEL SPACE
═══════════════════════════════════════════════════════════════════

  ┌─────────────────────────────────────────────────────────────┐
  │                    USER SPACE                               │
  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
  │  │  bash    │  │ firefox  │  │ python   │  │  mysql   │     │
  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
  │                                                             │
  │  • Programs run here with RESTRICTED access                 │
  │  • Cannot directly touch hardware                           │
  │  • If it crashes → only that program dies                   │
  │  • Each process has its own protected memory space          │
  │                                                             │
  │  Protection Ring 3 (least privilege)                        │
  └──────────────────────┬──────────────────────────────────────┘
                         │   SYSTEM CALL INTERFACE
                         │   (The controlled gateway)
  ┌──────────────────────▼──────────────────────────────────────┐
  │                    KERNEL SPACE                             │
  │                                                             │
  │  • Kernel runs here with FULL access to everything          │
  │  • Can touch CPU registers, RAM, hardware directly          │
  │  • If it crashes → entire system crashes (kernel panic)     │
  │  • Trusted code only!                                       │
  │                                                             │
  │  Protection Ring 0 (highest privilege)                      │
  └─────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"What happens when a user program wants to read a file?"_
>
> **Answer:** The program calls `fopen()` (C library) → which calls `open()` syscall → CPU switches from Ring 3 to Ring 0 → kernel opens the file → returns result back to user space → CPU switches back to Ring 3. This crossing of the boundary happens millions of times per second.

---

# PART E: LINUX HISTORY, GNU, AND OPEN SOURCE

## 📜 The Story of Linux — A Complete Timeline

```
LINUX HISTORY TIMELINE
═══════════════════════════════════════════════════════════════════

  1969  │ UNIX created at Bell Labs (Ken Thompson, Dennis Ritchie)
        │ The grandfather of all modern operating systems
        │
  1983  │ Richard Stallman starts the GNU Project
        │ Goal: Create a FREE Unix-like OS
        │ GNU = "GNU's Not Unix" (recursive acronym!)
        │
  1985  │ GNU Manifesto published — the philosophy of free software
        │
  1987  │ MINIX created by Andrew Tanenbaum (educational OS)
        │ This inspires a young Finnish student...
        │
  1991  │ ⭐ LINUS TORVALDS, age 21, posts this message:
        │   "I'm doing a (free) operating system (just a hobby,
        │    won't be big and professional like gnu)"
        │ Linux kernel 0.01 released!
        │
  1992  │ Linux becomes free software (GPL license)
        │ Combined with GNU tools → GNU/Linux is born!
        │
  1994  │ Linux kernel 1.0 released (176,250 lines of code)
        │
  1996  │ Tux the penguin becomes Linux mascot 🐧
        │ (Linus was bitten by a penguin in Australia!)
        │
  2000s │ Linux dominates servers worldwide
        │ IBM, Red Hat, Google, Amazon all bet on Linux
        │
  2003  │ Fedora, RHEL created by Red Hat
        │
  2004  │ Ubuntu launched — Linux for the masses!
        │
  2008  │ Android (based on Linux kernel) launches
        │
  2011  │ Linux kernel reaches 15 million lines of code
        │
  2016  │ Microsoft loves Linux (bash on Windows!)
        │
  Today │ Linux runs:
        │  • 100% of Top 500 supercomputers
        │  • ~96% of web servers
        │  • All Android phones (3.6 billion devices)
        │  • All major cloud platforms (AWS, GCP, Azure)
        │  • The International Space Station!
        │

═══════════════════════════════════════════════════════════════════
```

---

## 🆓 GNU Project and Free Software Philosophy

**Richard Stallman** founded the GNU Project with a powerful idea:

> _"Software should be free — not free as in free beer, but free as in freedom."_

### The Four Freedoms (GNU Philosophy)

```
THE FOUR SOFTWARE FREEDOMS
═══════════════════════════════════════════════════════════
  Freedom 0:  The freedom to RUN the program for any purpose
  Freedom 1:  The freedom to STUDY and change the program
  Freedom 2:  The freedom to REDISTRIBUTE copies
  Freedom 3:  The freedom to DISTRIBUTE your modified versions
═══════════════════════════════════════════════════════════
```

### What GNU Gave Us

| GNU Tool           | What It Is         | Still Used Today           |
| ------------------ | ------------------ | -------------------------- |
| **GCC**            | C/C++ Compiler     | Yes, millions of programs  |
| **bash**           | The Shell          | Yes, default in most Linux |
| **glibc**          | C Library          | Yes, in every Linux system |
| **coreutils**      | ls, cp, mv, cat... | Yes, every day!            |
| **grep, sed, awk** | Text processing    | Yes, absolutely            |
| **Make**           | Build system       | Yes, for compiling code    |

> **📌 Key Point:** Linux is just the **kernel**. When people say "Linux," they usually mean the **GNU/Linux** operating system — GNU tools + Linux kernel working together.

---

## 📦 Open Source vs Free Software

```
OPEN SOURCE vs FREE SOFTWARE
══════════════════════════════════════════════════════════════
  FREE SOFTWARE (GNU/FSF)         OPEN SOURCE (OSI)
  ─────────────────────           ──────────────────
  • Focus: Freedom/Ethics         • Focus: Practical benefits
  • License: GPL (copyleft)       • License: Many options
  • "Software must stay free"     • "Open code = better code"
  • Richard Stallman leads        • Linus Torvalds agrees here

  BOTH AGREE: Source code should be publicly available!
══════════════════════════════════════════════════════════════
```

### Linux License: GPL v2

The Linux kernel uses the **GPL v2 (GNU General Public License v2)**. This means:

- Anyone can use Linux for free
- Anyone can see the source code
- Anyone who modifies and distributes Linux MUST share their changes
- You cannot make Linux proprietary/closed-source

---

# PART F: LINUX ARCHITECTURE — BOTTOM TO TOP

## 🏛️ The Complete Linux Architecture

Let's build the complete picture layer by layer:

```
COMPLETE LINUX ARCHITECTURE (Bottom to Top)
═══════════════════════════════════════════════════════════════════════════

LAYER 8 ┌──────────────────────────────────────────────────────────────┐
        │             DESKTOP ENVIRONMENT / DISPLAY                    │
        │     GNOME, KDE Plasma, XFCE, i3, Wayland, X11                │
        │  (What you see and click — the visual layer)                 │
        └──────────────────────────────────────────────────────────────┘
LAYER 7 ┌──────────────────────────────────────────────────────────────┐
        │             USER APPLICATIONS                                │
        │  Firefox, LibreOffice, VLC, GIMP, VS Code, vim, gcc          │
        └──────────────────────────────────────────────────────────────┘
LAYER 6 ┌──────────────────────────────────────────────────────────────┐
        │             SHELL                                            │
        │  bash, zsh, fish, sh                                         │
        │  (Command interpreter — translates your commands)            │
        └──────────────────────────────────────────────────────────────┘
LAYER 5 ┌──────────────────────────────────────────────────────────────┐
        │             SYSTEM LIBRARIES                                 │
        │  glibc (C library), libm, libpthread, OpenSSL                │
        │  (Provide ready-made functions for programs)                 │
        └──────────────────────────────────────────────────────────────┘
LAYER 4 ┌──────────────────────────────────────────────────────────────┐
        │             SYSTEM CALL INTERFACE                            │
        │  open(), read(), write(), fork(), exec(), socket()           │
        │  (The ONLY legal way for programs to talk to kernel)         │
        └──────────────────────────────────────────────────────────────┘
LAYER 3 ┌──────────────────────────────────────────────────────────────┐
        │             LINUX KERNEL                                     │
        │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐    │
        │  │Process │ │Memory  │ │  VFS   │ │Network │ │ Security │    │
        │  │Manager │ │Manager │ │ (Files)│ │ Stack  │ │(SELinux) │    │
        │  └────────┘ └────────┘ └────────┘ └────────┘ └──────────┘    │
        └──────────────────────────────────────────────────────────────┘
LAYER 2 ┌──────────────────────────────────────────────────────────────┐
        │             BOOTLOADER                                       │
        │  GRUB2 (Grand Unified Bootloader version 2)                  │
        │  (Loads the kernel from disk into RAM)                       │
        └──────────────────────────────────────────────────────────────┘
LAYER 1 ┌──────────────────────────────────────────────────────────────┐
        │             FIRMWARE                                         │
        │  BIOS / UEFI                                                 │
        │  (The first software — lives in ROM chip on motherboard)     │
        └──────────────────────────────────────────────────────────────┘
LAYER 0 ┌──────────────────────────────────────────────────────────────┐
        │             HARDWARE                                         │
        │  CPU  │  RAM  │  Disk  │  NIC  │  GPU  │  USB  │  Monitor    │
        └──────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════
```

### Services and Daemons

A **daemon** is a program that runs in the background (you never see it), doing important work.

```bash
# See all running services
systemctl list-units --type=service

# See status of a service
systemctl status ssh
systemctl status nginx
systemctl status NetworkManager

# Common daemons and what they do:
#   sshd      → SSH server (remote login)
#   cron      → Job scheduler (runs commands at set times)
#   nginx     → Web server
#   systemd   → PID 1, the master service manager
#   NetworkManager → Handles WiFi/Ethernet connections
#   rsyslog   → System logging

# Check which process is PID 1
cat /proc/1/cmdline | tr '\0' ' '
ps -p 1
```

---

# PART G: YOUR FIRST LINUX COMMANDS

## 🖥️ The Terminal — Your New Best Friend

The terminal is where you type commands. It gives you **superpowers** over the computer.

```
ANATOMY OF A LINUX COMMAND
═══════════════════════════════════════════════════════════════════

  $ ls -la /home/username

  │  │     │  └──── ARGUMENT: what to act on (the target)
  │  │     └─────── OPTIONS/FLAGS: modify behavior (-l = long, -a = all)
  │  └───────────── COMMAND: the program to run
  └──────────────── PROMPT: $ means you're a regular user
                            # means you're root (admin)

═══════════════════════════════════════════════════════════════════
```

## 📋 Essential First Commands — Every Linux User Must Know

### 1. `pwd` — Where Am I?

```bash
pwd
# Output: /home/yourname

# What it means: Print Working Directory
# Working directory = the folder you're currently "in"
```

### 2. `ls` — List Files

```bash
ls                    # Basic list of current directory
ls -l                 # Long format (details)
ls -a                 # Show hidden files (starting with .)
ls -la                # Long format + hidden files
ls -lh                # Human-readable file sizes
ls -lt                # Sort by time (newest first)
ls -lS                # Sort by size (largest first)
ls /etc               # List a specific directory
ls -la /home          # List /home with all details
```

**Understanding `ls -la` output:**

```
total 48
drwxr-xr-x  5 ahmed ahmed 4096 Jun 14 10:23 .
drwxr-xr-x 18 root  root  4096 Jun 13 09:00 ..
-rw-r--r--  1 ahmed ahmed  220 Jun 13 09:00 .bash_logout
-rw-r--r--  1 ahmed ahmed 3526 Jun 13 09:00 .bashrc
drwxr-xr-x  2 ahmed ahmed 4096 Jun 14 10:23 Documents
-rw-r--r--  1 ahmed ahmed 1234 Jun 14 09:15 notes.txt

│ │        │  │     │     │    │              └── Filename
│ │        │  │     │     │    └──────────────── Date modified
│ │        │  │     │     └───────────────────── File size (bytes)
│ │        │  │     └─────────────────────────── Group owner
│ │        │  └───────────────────────────────── User owner
│ │        └──────────────────────────────────── Number of hard links
│ └───────────────────────────────────────────── Permissions (rwxr-xr-x)
└─────────────────────────────────────────────── File type (d=dir, -=file, l=link)
```

### 3. `cd` — Change Directory

```bash
cd /home              # Go to /home directory
cd ~                  # Go to your home directory
cd                    # Also goes home (same as cd ~)
cd ..                 # Go up one level (parent directory)
cd ../..              # Go up two levels
cd -                  # Go to previous directory (like "back button")
cd /var/log           # Go to absolute path
cd Documents          # Go to relative path (Documents inside current dir)
```

**Absolute vs Relative Path — Explained Simply:**

```
ABSOLUTE PATH: starts from / (root)
  /home/ahmed/Documents/file.txt
  Always works regardless of where you are!

RELATIVE PATH: starts from current directory
  Documents/file.txt   (only works if you're in /home/ahmed/)
  ../notes.txt         (go up one level, then find notes.txt)
```

### 4. `cat` — Read Files

```bash
cat file.txt              # Display file contents
cat /etc/os-release       # Show Linux version info
cat /proc/cpuinfo         # CPU info (from kernel)
cat /proc/meminfo         # Memory info (from kernel)
cat -n file.txt           # Show with line numbers
cat file1.txt file2.txt   # Display multiple files in order

# ⚠️ Don't use cat on binary files or huge files!
# For big files, use: less, head, or tail
```

### 5. `head` and `tail` — See Parts of Files

```bash
head file.txt             # First 10 lines (default)
head -n 20 file.txt       # First 20 lines
head -n 5 /etc/passwd     # First 5 lines of passwd file

tail file.txt             # Last 10 lines
tail -n 20 file.txt       # Last 20 lines
tail -f /var/log/syslog   # LIVE view — updates as file grows!
                          # ← Amazing for monitoring logs!
tail -f /var/log/auth.log # Watch login attempts live
```

### 6. `echo` — Print Text

```bash
echo "Hello, Linux!"             # Print text to screen
echo $HOME                       # Print a variable
echo $USER                       # Print current username
echo $SHELL                      # Print current shell
echo "Hello" > file.txt          # Write to file (overwrite)
echo "World" >> file.txt         # Append to file (add at end)
echo -n "No newline"             # Print without newline
echo -e "Line1\nLine2"           # Enable special characters (\n = newline)
```

### 7. `whoami`, `id`, `hostname`

```bash
whoami                    # Print current username
id                        # Print user ID and group info
id ahmed                  # Info about specific user
hostname                  # Computer's name
hostname -I               # IP address of this machine
date                      # Current date and time
uptime                    # How long has the system been running?
uptime -p                 # Pretty format: "up 2 days, 3 hours"
cal                       # Calendar for current month
```

**Sample `id` output:**

```
uid=1000(ahmed) gid=1000(ahmed) groups=1000(ahmed),4(adm),24(cdrom),27(sudo),1001(docker)
```

This tells you:

- Your User ID is **1000**
- Your primary Group ID is **1000**
- You're also in groups: **adm**, **cdrom**, **sudo**, **docker**
- Being in **sudo** group = you can run commands as root!

### 8. `man` — The Manual (Your Best Friend)

```bash
man ls                    # Manual page for ls command
man cat                   # Manual for cat
man man                   # Manual for man itself!

# Inside man page:
# Press q to quit
# Press / to search (then type keyword, press Enter)
# Press n to go to next match
# Press Space to scroll down page by page

man -k keyword            # Search for commands by keyword
man -k "copy files"       # Find commands related to copying files

# Quick help (shorter than man)
ls --help
cat --help
```

### 9. `mkdir`, `touch`, `cp`, `mv`, `rm`

```bash
# CREATE DIRECTORY
mkdir myfolder                     # Create a directory
mkdir -p path/to/deep/folder       # Create all intermediate dirs
mkdir -p project/{src,docs,tests}  # Create multiple dirs at once

# CREATE EMPTY FILE
touch newfile.txt                  # Create empty file / update timestamp
touch file1.txt file2.txt          # Create multiple files

# COPY
cp source.txt destination.txt      # Copy file
cp -r source_dir/ dest_dir/        # Copy directory (recursive)
cp -v file.txt /tmp/               # Verbose (show what's being copied)
cp -i file.txt /tmp/               # Interactive (ask before overwrite)
cp -p file.txt backup.txt          # Preserve permissions/timestamps

# MOVE / RENAME
mv oldname.txt newname.txt         # Rename a file
mv file.txt /tmp/                  # Move to another location
mv -v file.txt /tmp/               # Verbose
mv -i file.txt /tmp/               # Ask before overwrite

# REMOVE (BE CAREFUL!)
rm file.txt                        # Delete file
rm -r directory/                   # Delete directory recursively
rm -f file.txt                     # Force (no error if missing)
rm -rf directory/                  # Force delete everything ← ⚠️ DANGEROUS
rm -i file.txt                     # Interactive (asks for confirmation)
```

> **⚠️ WARNING (Critical for beginners!):** `rm -rf /` will **destroy your entire system** in seconds. Linux will NOT ask "Are you sure?" It just does it. Always double-check before running `rm -rf`.

### 10. System Information Commands

```bash
# SYSTEM INFO
uname -a                  # Kernel version + architecture
hostnamectl               # System hostname + OS info
lsb_release -a            # Linux distribution info
cat /etc/os-release       # OS info in detail

# HARDWARE INFO
lscpu                     # CPU details
free -h                   # RAM usage
df -h                     # Disk usage (all filesystems)
lsblk                     # Block devices (disks/partitions)
lspci                     # PCI devices
lsusb                     # USB devices

# PROCESS INFO
ps aux                    # All running processes
top                       # Real-time process monitor
htop                      # Better top (install separately)

# NETWORK INFO
ip addr                   # IP addresses
ip route                  # Routing table
ss -tulnp                 # Open ports and listening services
ping google.com           # Test connectivity
```

## 🔍 The `file` and `which` Commands

```bash
# What TYPE of file is this?
file notes.txt            # ASCII text
file /bin/bash            # ELF 64-bit executable
file image.jpg            # JPEG image
file archive.tar.gz       # gzip compressed data

# WHERE is a command installed?
which bash                # /usr/bin/bash
which python3             # /usr/bin/python3
which ls                  # /usr/bin/ls

# FIND a file on the system
find / -name "hosts" 2>/dev/null              # Find file named hosts
find /home -name "*.txt"                      # All .txt files in /home
find /var/log -name "*.log" -mtime -1        # Log files modified in last day
find / -size +100M 2>/dev/null               # Files larger than 100MB
```

## 🔢 Counting and Searching: `wc` and `grep`

```bash
# WORD COUNT
wc file.txt               # Lines, words, characters
wc -l file.txt            # Only line count
wc -w file.txt            # Only word count
wc -c file.txt            # Only byte count

# SEARCH INSIDE FILES
grep "error" /var/log/syslog          # Find "error" in file
grep -i "error" logfile.txt           # Case-insensitive search
grep -r "TODO" /home/ahmed/           # Recursive search (all files)
grep -n "function" script.sh          # Show line numbers
grep -v "comment" file.txt            # Show lines that DON'T match
grep -c "error" logfile.txt           # Count matching lines
grep --color "warning" /var/log/*     # Highlight matches in color
```

---

# PART H: CHAPTER SUMMARY + CHEAT SHEET

## 📝 Chapter Summary

```
CHAPTER 1 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Hardware:
     • CPU = brain (fetch-decode-execute cycle)
     • RAM = temporary workspace (lost on power off)
     • Storage = permanent home (survives power off)
     • Motherboard = connects everything

  ✅ Boot Process (in order!):
     Power → BIOS/UEFI → GRUB → Kernel → systemd → Login Shell

  ✅ Operating System:
     • Manages hardware resources
     • Provides abstraction layer for apps
     • Handles processes, memory, files, network, security

  ✅ Linux Kernel:
     • The heart of GNU/Linux
     • Runs in Ring 0 (full hardware access)
     • User apps run in Ring 3 (restricted)
     • Communication: system calls

  ✅ Linux History:
     • 1969: UNIX born at Bell Labs
     • 1983: GNU Project (Stallman)
     • 1991: Linux kernel (Torvalds, age 21)
     • Today: runs everything!

  ✅ Architecture Layers:
     Hardware → BIOS → GRUB → Kernel → syscalls → libc → Shell → Apps

  ✅ First Commands Mastered:
     pwd, ls, cd, cat, head, tail, echo, whoami, id
     mkdir, touch, cp, mv, rm, man, grep, find, file

═══════════════════════════════════════════════════════════════════
```

---

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 1 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

NAVIGATION                    FILE OPERATIONS               SYSTEM INFO
──────────────────────        ─────────────────────         ───────────────────
pwd          Where am I?      mkdir dir     Make folder     uname -a    Kernel
cd ~         Go home          touch file    Create file     lscpu       CPU
cd ..        Go up            cp a b        Copy file       free -h     RAM
cd -         Go back          mv a b        Move/rename     df -h       Disk
ls           List files       rm file       Delete file     lsblk       Disks
ls -la       List (detailed)  rm -rf dir    Delete dir⚠️   lspci       PCI HW

FILE VIEWING                  SEARCHING                     PROCESSES
──────────────────────        ─────────────────────         ───────────────────
cat file     Show file        grep "txt" f  Search in file  ps aux      All procs
head file    First 10 lines   grep -r "x" / Recursive       top         Monitor
tail file    Last 10 lines    find / -name  Find file       htop        Better top
tail -f log  Live log view    which cmd     Where is it?    kill PID    Kill proc
less file    Scroll through   file foo      File type?      pkill name  Kill by name

HELP                          IDENTITY                      NETWORK
──────────────────────        ─────────────────────         ───────────────────
man command  Manual page      whoami        My username     ip addr     IP address
cmd --help   Quick help       id            User + groups   ping host   Test ping
man -k word  Search manuals   hostname      Computer name   ss -tulnp   Open ports

═══════════════════════════════════════════════════════════════════════════════
```

---

## ❓ Chapter 1 Interview Questions

These are real questions asked in Linux admin and DevOps interviews:

| #   | Question                            | Key Answer Points                                               |
| --- | ----------------------------------- | --------------------------------------------------------------- |
| 1   | What is the Linux kernel?           | Core OS, manages hardware, runs in kernel space (Ring 0)        |
| 2   | What is the boot process?           | BIOS → GRUB → Kernel → systemd → Login                          |
| 3   | Difference between BIOS and UEFI?   | UEFI is modern, 64-bit, faster, supports >2TB, Secure Boot      |
| 4   | What is user space vs kernel space? | Ring 0 (kernel) vs Ring 3 (apps), syscalls bridge them          |
| 5   | What is PID 1?                      | systemd — the first process, parent of all processes            |
| 6   | What is RAM?                        | Temporary volatile memory; lost on power off                    |
| 7   | What is a system call?              | Controlled interface between user space and kernel              |
| 8   | Who created Linux?                  | Linus Torvalds (1991), Finnish CS student                       |
| 9   | What license is Linux under?        | GPL v2 (GNU General Public License v2)                          |
| 10  | What is GNU?                        | Stallman's free software project; provides tools like gcc, bash |
| 11  | What does `uname -r` show?          | Current Linux kernel version                                    |
| 12  | What does `lscpu` show?             | CPU architecture, cores, threads, cache, speed                  |

---

## 🔬 Practical Lab: Chapter 1 Exercises

Complete these on your Linux machine (or a VM/container):

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: Hardware Discovery
# ──────────────────────────────────────────────────────────────────
lscpu                           # How many cores? What speed?
free -h                         # How much RAM?
df -h                           # How much disk space?
lsblk                           # What disks are there?
lspci                           # What PCI hardware?

# ──────────────────────────────────────────────────────────────────
# LAB 2: Boot Investigation
# ──────────────────────────────────────────────────────────────────
uname -r                        # What kernel are you running?
uname -a                        # Full system info
systemd-analyze                 # How fast did your system boot?
systemd-analyze blame           # What slowed boot down?
cat /proc/1/cmdline             # What is PID 1?
dmesg | head -20                # First kernel messages at boot
journalctl -b | head -30        # Boot log from systemd

# ──────────────────────────────────────────────────────────────────
# LAB 3: File Navigation
# ──────────────────────────────────────────────────────────────────
pwd                             # Where are you?
ls -la                          # List current directory
cd /etc && ls | head -20        # Go to /etc, list first 20 items
cat /etc/os-release             # What Linux distro are you on?
cd ~ && pwd                     # Go home and confirm
mkdir -p ~/lab1/subdir/deep     # Create nested directories
touch ~/lab1/test.txt           # Create a file
echo "Hello Linux!" > ~/lab1/test.txt
cat ~/lab1/test.txt             # Read the file
cp ~/lab1/test.txt ~/lab1/backup.txt  # Copy it
ls -l ~/lab1/                   # See both files
rm ~/lab1/backup.txt            # Delete the copy

# ──────────────────────────────────────────────────────────────────
# LAB 4: System Investigation
# ──────────────────────────────────────────────────────────────────
whoami                          # Your username
id                              # Your UID, GID, groups
hostname                        # Machine name
cat /proc/cpuinfo | grep "model name" | head -1   # CPU model
cat /proc/meminfo | grep "MemTotal"               # Total RAM
cat /proc/version               # Kernel version + compiler
ls /boot                        # See bootloader and kernel files
ls /proc | head -20             # See process directories
ls /sys/class                   # See device classes

# ──────────────────────────────────────────────────────────────────
# LAB 5: Searching and Finding
# ──────────────────────────────────────────────────────────────────
grep -r "localhost" /etc/ 2>/dev/null | head -5   # Find localhost mentions
find /var/log -name "*.log" | head -10            # Find log files
find /home -type f -name "*.txt" 2>/dev/null      # Find txt files
which bash                      # Where is bash?
which python3                   # Where is python3?
file /bin/bash                  # What type of file is bash?
file /etc/hosts                 # What type is hosts file?
```

---

## 🧠 Mini Project: System Report Script

Create your first shell script that generates a system report:

```bash
# Create the script
cat > ~/system_report.sh << 'EOF'
#!/bin/bash
# ─────────────────────────────────────────────
# My First Linux Script: System Report
# Chapter 1 Mini Project
# ─────────────────────────────────────────────

echo "======================================"
echo "     LINUX SYSTEM REPORT"
echo "     $(date)"
echo "======================================"
echo ""

echo "📍 HOSTNAME:    $(hostname)"
echo "👤 CURRENT USER: $(whoami)"
echo "🐧 OS:          $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
echo "🔧 KERNEL:      $(uname -r)"
echo "⚙️  CPU:         $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "🔢 CPU CORES:   $(nproc)"
echo ""

echo "─── MEMORY ───────────────────────────"
free -h
echo ""

echo "─── DISK USAGE ───────────────────────"
df -h | grep -v tmpfs
echo ""

echo "─── TOP 5 PROCESSES (by CPU) ─────────"
ps aux --sort=-%cpu | head -6
echo ""

echo "─── SYSTEM UPTIME ────────────────────"
uptime -p
echo ""

echo "─── NETWORK INTERFACES ───────────────"
ip addr | grep "inet " | awk '{print $2, $NF}'
echo ""

echo "======================================"
echo "     END OF REPORT"
echo "======================================"
EOF

# Make it executable
chmod +x ~/system_report.sh

# Run it!
bash ~/system_report.sh
```

---

## 🗺️ Where You Are in the Linux Roadmap

```
LINUX MASTERY ROADMAP — YOUR PROGRESS
═══════════════════════════════════════════════════════════════════

  ✅ Chapter 1:  Hardware, Boot, OS, Kernel, History, First Commands
  ⬜ Chapter 2:  Linux Filesystem (FHS, /proc, /sys, /dev, inodes)
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
  YOU ARE HERE: ✅ — Keep going! 💪
═══════════════════════════════════════════════════════════════════
```

---

## Next: [Chapter 2 — The Linux Filesystem](/chapter-2.md)
