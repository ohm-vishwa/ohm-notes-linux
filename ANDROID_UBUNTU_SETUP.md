# 🤖 Running Ubuntu on Android via Termux

## 📱 Don't Have a Computer? No Problem! Your Android Phone is Linux Too!

### 🎯 Quick Truth: Android **IS** Linux

Did you know? **Android is built on the Linux kernel!** Every Android phone runs a custom version of Linux under the hood. So if you have an Android phone, you already have a Linux system in your pocket!

If you don't have access to a traditional computer but want to learn Linux, your Android phone is the perfect gateway. With **Termux** (a powerful terminal emulator), you can:

- Access a full Linux environment
- Run Linux commands
- Install and run Linux tools
- Even run a lightweight Ubuntu environment!

This guide shows you how to turn your Android phone into a learning machine for Linux development.

---

## ✅ Prerequisites

| Requirement        | Details                                      |
| ------------------ | -------------------------------------------- |
| **Android Device** | Android 5.0 or higher                        |
| **Storage Space**  | 3-5 GB free space for Ubuntu environment     |
| **RAM**            | 2 GB minimum (4 GB+ recommended)             |
| **Internet**       | WiFi or mobile data for downloading packages |

---

## 🚀 Step-by-Step Installation Guide

### **Step 1: Install Termux**

1. Open **Google Play Store** on your Android phone
2. Search for **"Termux"**
3. Install the official Termux app (by Fredrik Fornwall)
   - ⚠️ Make sure it's the **blue icon** with the `>_` symbol
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

---

### **Step 6: Update Ubuntu**

Update the package manager and install essential tools:

```bash
# Update package lists
apt update

# Upgrade installed packages
apt upgrade -y

# Install useful development tools
apt install -y build-essential git curl wget nano vim
```

---

## 🎮 Common Commands You'll Use

### **Entering/Exiting Ubuntu**

```bash
# From Termux, enter Ubuntu
proot-distro login ubuntu

# Inside Ubuntu, exit back to Termux
exit
```

### **Checking Ubuntu Status**

```bash
# Check available distributions
proot-distro list

# Check if Ubuntu is installed
proot-distro status
```

### **Remove Ubuntu (if needed)**

```bash
# Uninstall Ubuntu completely
proot-distro remove ubuntu
```

---

## 💡 What You Can Do Now

Once inside Ubuntu on your Android phone, you have access to:

| Tool          | Usage                                 |
| ------------- | ------------------------------------- |
| **bash/sh**   | Write and run shell scripts           |
| **git**       | Clone and manage repositories         |
| **gcc/g++**   | Compile C/C++ programs                |
| **python**    | Run Python scripts                    |
| **node**      | Run Node.js applications              |
| **curl/wget** | Download files and make HTTP requests |
| **vim/nano**  | Edit text files                       |
| **man**       | Access manual pages for commands      |

### **Example: Run Your First Python Script**

Inside Ubuntu:

```bash
# Create a Python file
cat > hello.py << EOF
#!/usr/bin/env python3
print("Hello from Ubuntu on Android!")
EOF

# Run it
python3 hello.py
```

Output:

```
Hello from Ubuntu on Android!
```

---

## ⚡ Pro Tips & Tricks

### **1. Install a Code Editor**

```bash
# Inside Ubuntu
apt install -y nano
# or
apt install -y vim
```

### **2. Use SSH to Connect from Computer**

You can SSH into your Ubuntu environment from a computer:

```bash
# Inside Ubuntu, install SSH server
apt install -y openssh-server
sudo service ssh start

# Note your IP address
hostname -I
```

Then from your computer:

```bash
ssh root@<your-phone-ip>
```

### **3. Access Phone Storage from Ubuntu**

```bash
# Inside Ubuntu
cd /data/data/com.termux/files/home/storage/

# Your downloads folder
cd downloads

# Your pictures folder
cd pictures
```

### **4. Copy Files Between Termux and Ubuntu**

```bash
# In Termux (NOT in Ubuntu)
cp /data/data/com.termux/files/home/file.txt /data/data/com.termux/files/home/ubuntu-fs/root/file.txt
```

---

## 🐛 Troubleshooting

### **Issue: "proot-distro: command not found"**

```bash
# Solution: Install proot-distro first
pkg install -y proot-distro
```

### **Issue: "Installation failed" or "Download error"**

```bash
# Solution: Use a different download source or try again
proot-distro install ubuntu --from-chroot
```

### **Issue: Low Storage Space**

```bash
# Check available space
df -h

# Clean up Termux cache
pkg clean
```

### **Issue: Ubuntu Won't Start**

```bash
# Reinstall Ubuntu
proot-distro remove ubuntu
proot-distro install ubuntu
```

---

## 📚 Next Steps: Learning Linux

Now that you have Ubuntu running on your Android phone, you can:

1. **Learn Shell Commands** - Practice bash scripts using your favorite Linux notes
2. **Write Small Programs** - Try C, Python, or Node.js development
3. **Use Git** - Clone repositories and learn version control
4. **System Administration** - Practice with systemd, processes, and networking
5. **Connect to Remote Servers** - Use SSH to manage other systems

---

## 🔗 Useful Resources

- **Official Termux Docs**: https://termux.com
- **PRoot Distro GitHub**: https://github.com/termux/proot-distro
- **Ubuntu Man Pages**: `man <command>` inside Ubuntu
- **Linux Learning Path**: Check out the main Linux Notes README for structured learning

---

## 🎓 Quick Reference: First Commands to Try

```bash
# After logging into Ubuntu

# Print current working directory
pwd

# List files
ls -la

# Check current user
whoami

# Check Linux version
uname -a
cat /etc/os-release

# Create a file
echo "Hello" > test.txt

# Read a file
cat test.txt

# Create a directory
mkdir my_projects

# Navigate to it
cd my_projects

# Check available disk space
df -h
```

---

## 📝 Important Notes

⚠️ **Remember:**

- Ubuntu on Termux is **not** a full Ubuntu desktop experience (no GUI by default)
- It's a **headless Linux environment** - perfect for learning command-line and server concepts
- Root access is automatic in Termux (you don't need to use `sudo`)
- Keep your Android device plugged in during long operations

✅ **Best For:**

- Learning Linux commands and shell scripting
- Running server-side applications
- Development and coding
- Understanding how Linux works
- Running Linux tools and utilities

---

## 🎉 Success!

You now have a portable Linux environment in your pocket! Whether you're using a computer or Android phone, the Linux commands you learn are the same. Happy learning! 🚀
