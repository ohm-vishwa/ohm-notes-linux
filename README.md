# Linux Notes

## 📚 Index

| #   | Chapter                                        | Topics                                                              |
| --- | ---------------------------------------------- | ------------------------------------------------------------------- |
| 1   | [From Hardware to Hello Linux](./chapter-1.md) | Computer Hardware, BIOS/UEFI, OS Basics, Linux Kernel, Boot Process |
| 2   | [The Linux Filesystem](./chapter-2.md)         | Filesystem Tree, Inodes, Links, Mounting, ext4, XFS, Btrfs          |
| 3   | [Users, Groups & Permissions](./chapter-3.md)  | User & Group Management, File Permissions, ACLs, Special Bits, sudo |
| 4   | [Text Processing](./chapter-4.md)              | Pipes, Redirection, grep, sed, awk, Text Tools & Pipelines          |
| 5   | [Package Management](./chapter-5.md)           | APT, YUM/DNF, pacman, dpkg, rpm, Building from Source               |
| 6   | [Shell Scripting](./chapter-6.md)              | Variables, Conditionals, Loops, Functions, Arrays, Automation       |
| 7   | [Process Management](./chapter-7.md)           | Processes, Signals, Job Control, Process Priority, Monitoring       |
| 8   | [Networking](./chapter-8.md)                   | TCP/IP, DNS, SSH, Firewalls, DHCP, Routing, VPN, Troubleshooting    |
| 9   | [System Administration](./chapter-9.md)        | systemd, Logging, journald, cron, Backup & Recovery                 |
| 10  | [Linux Security](./chapter-10.md)              | PAM, SELinux, AppArmor, Encryption, SSH Hardening, Auditing         |
| 11  | [Containers & Virtualization](./chapter-11.md) | Namespaces, cgroups, Docker, Kubernetes, Podman, KVM/QEMU           |
| 12  | [Linux Kernel Development](./chapter-12.md)    | Kernel Modules, Drivers, Compilation, Debugging, Contributing       |

### 📱 Don't Have a Computer? No Problem! Your Android Phone is Linux Too!

---

---

# 🤖 Running Ubuntu on Android via Termux

## 🚀 Step-by-Step Installation Guide

### **Step 1: Install Termux**

1. Open **Google Play Store** on your Android phone
2. Search for **"Termux"**
3. Install the official Termux app (by Fredrik Fornwall)
   - ⚠️ Make sure it's the **black icon** with the `>_` symbol
4. Open Termux and wait for initial setup to complete

**First-time setup commands:**

```bash
# Update package lists
pkg update

# Upgrade installed packages
pkg upgrade

# Install essential tools
pkg install -y wget curl git
```

---

### **Step 2: Set Up Storage Access**

Termux needs permission to access your phone's storage:

```bash
# Grant storage permission
termux-setup-storage
```

This opens a permission dialog. Tap **Allow** to grant storage access.

---

### **Step 3: Install PRoot (Required for Ubuntu)**

PRoot allows us to run Ubuntu in a chroot environment within Termux:

```bash
# Install PRoot
pkg install -y proot proot-distro

# Verify installation
proot-distro list
```

You should see a list of available distributions including Ubuntu.

---

### **Step 4: Install Ubuntu via PRoot**

Now install Ubuntu using proot-distro:

```bash
# Install Ubuntu (this downloads ~500 MB)
proot-distro install ubuntu

# Wait for installation to complete...
# (This may take 5-15 minutes depending on internet speed)
```

**Output should look like:**

```
⠙ Downloading rootfs...
⠋ Extracting rootfs...
✓ Installation finished
```

---

### **Step 5: Enter Ubuntu Environment**

Once installation is complete, you can now boot into Ubuntu:

```bash
# Login to Ubuntu
proot-distro login ubuntu
```

You're now in a full Ubuntu environment! You should see:

```bash
root@localhost:~#
```
