# CHAPTER 3: USERS, GROUPS & PERMISSIONS

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 3
═══════════════════════════════════════════════════════════════
  PART A  →  Why Linux Is a Multi-User System
  PART B  →  Understanding Users (/etc/passwd, UID, root)
  PART C  →  Understanding Groups (/etc/group, GID)
  PART D  →  User Management Commands
  PART E  →  Group Management Commands
  PART F  →  File Permissions (rwx Explained Fully)
  PART G  →  chmod, chown, chgrp Mastery
  PART H  →  Special Permissions (SUID, SGID, Sticky Bit)
  PART I  →  umask — Default Permission Control
  PART J  →  ACLs — Beyond Basic Permissions
  PART K  →  sudo vs su — Becoming Root Safely
  PART L  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: WHY LINUX IS A MULTI-USER SYSTEM

## 👥 One Machine, Many People

Linux was designed from the UNIX era to let **multiple people use the same computer at the same time** — safely, without seeing each other's files or crashing each other's programs.

```
MULTI-USER CONCEPT
═══════════════════════════════════════════════════════════════════

                         ONE LINUX SERVER
                    ┌──────────────────────────┐
                    │                          │
   ahmed ──SSH──►   │   /home/ahmed  (private) │
   fatima ──SSH──►  │   /home/fatima (private) │
   admin ──SSH──►   │   /home/admin  (private) │
                    │                          │
                    │   /etc  (root only edits)│
                    │   /var/log (root reads)  │
                    └──────────────────────────┘

  Every user has:
  • Their own UID (User ID number)
  • Their own home directory
  • Their own permissions on every file
  • Isolation from other users by default

═══════════════════════════════════════════════════════════════════
```

This is WHY permissions exist: to make sharing one computer safe. A web server, a database, your personal scripts, and ten other users can all coexist on ONE machine because of the permission system you're about to master.

---

# PART B: UNDERSTANDING USERS

## 🆔 Every User Has a Unique Number: UID

The system doesn't actually care about your username — internally, it tracks you by a number called the **UID (User ID)**.

```
TYPES OF USERS BY UID RANGE
═══════════════════════════════════════════════════════════════
  UID 0           → root (the superuser — full power over everything)
  UID 1–999        → System/service accounts (created by the OS,
                      e.g. www-data, mysql, sshd) — NOT for humans
  UID 1000+        → Regular human user accounts (you!)
═══════════════════════════════════════════════════════════════
```

> **📌 Key Point:** Numbering may vary slightly by distro (some use 1–99 or 1–499 for system accounts), but the principle is universal: **UID 0 is always root**, low UIDs are always system accounts, and human users start higher up.

## 📄 `/etc/passwd` — The User Database

Every user account on the system is listed here. Despite the scary name, it does **NOT** contain actual passwords anymore (that's `/etc/shadow`).

```bash
cat /etc/passwd
```

**Sample line:**

```
ahmed:x:1000:1000:Ahmed Khan,,,:/home/ahmed:/bin/bash
```

```
ANATOMY OF AN /etc/passwd LINE
═══════════════════════════════════════════════════════════════════
  ahmed : x : 1000 : 1000 : Ahmed Khan,,, : /home/ahmed : /bin/bash
    │     │    │      │         │              │              │
    │     │    │      │         │              │              └─ Login shell
    │     │    │      │         │              └─ Home directory
    │     │    │      │         └─ Comment field (full name, GECOS)
    │     │    │      └─ Primary GID (group ID)
    │     │    └─ UID (user ID)
    │     └─ Password placeholder ("x" = stored in /etc/shadow instead)
    └─ Username

═══════════════════════════════════════════════════════════════════
```

```bash
# View only usernames
cut -d: -f1 /etc/passwd

# Count total user accounts
wc -l /etc/passwd

# Find a specific user's entry
grep "^ahmed:" /etc/passwd

# See your own entry
grep "^$USER:" /etc/passwd
```

## 🔒 `/etc/shadow` — Where Encrypted Passwords Really Live

Only **root** can read this file — that's intentional security.

```bash
sudo cat /etc/shadow
```

**Sample line:**

```
ahmed:$6$randomsalt$encryptedhashhere:19500:0:99999:7:::
```

```
ANATOMY OF AN /etc/shadow LINE
═══════════════════════════════════════════════════════════════════
  ahmed : $6$salt$hash : 19500 : 0 : 99999 : 7 : : :
    │         │            │     │     │     │
    │         │            │     │     │     └─ Warning days before expiry
    │         │            │     │     └─ Max days password is valid
    │         │            │     └─ Min days before password can change
    │         │            └─ Last password change (days since 1970)
    │         └─ Encrypted password hash ($6$ = SHA-512)
    └─ Username

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Why is the password stored in `/etc/shadow` instead of `/etc/passwd`?"_ **Answer:** `/etc/passwd` must be world-readable (many tools need to look up usernames/UIDs), but exposing password hashes to every user would be a huge security risk. `/etc/shadow` is readable only by root, isolating sensitive hash data.

## 👑 The Root User — Superuser

```
ROOT vs REGULAR USER
═══════════════════════════════════════════════════════════════
  ROOT (UID 0)                    REGULAR USER (UID 1000+)
  ─────────────                   ─────────────────────────
  • Can read/write ANY file       • Restricted by permissions
  • Can kill ANY process          • Can only kill own processes
  • Can change ANY config          • Can only edit own files
  • Bypasses permission checks     • Subject to permission checks
  • DANGEROUS if misused           • Safer by design
═══════════════════════════════════════════════════════════════
```

### Real World: Inspecting Users

```bash
whoami                      # Current username
id                          # UID, GID, and groups
id ahmed                    # Info for a specific user
who                         # Who is logged in right now
w                           # Who is logged in + what they're doing
last                        # Login history
last -5                     # Last 5 logins
finger ahmed                # Detailed user info (if installed)
getent passwd ahmed         # Look up user (works with LDAP/NIS too!)
```

---

# PART C: UNDERSTANDING GROUPS

## 👨‍👩‍👧 Groups — Sharing Access Between Users

A **group** lets multiple users share the same permission level on files, without giving them all the SAME account.

```
PRIMARY GROUP vs SECONDARY GROUPS
═══════════════════════════════════════════════════════════════════

  User: ahmed
  ┌─────────────────────────────────────────────┐
  │  PRIMARY GROUP: ahmed (GID 1000)            │
  │  • Every new file ahmed creates             │
  │    automatically belongs to this group      │
  │  • Defined in /etc/passwd (4th field)       │
  └─────────────────────────────────────────────┘
  ┌──────────────────────────────────────────────┐
  │  SECONDARY GROUPS: sudo, docker, developers  │
  │  • Extra permissions from being a MEMBER     │
  │  • Defined in /etc/group                     │
  │  • A user can belong to MANY secondary groupS│
  └──────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════
```

## 📄 `/etc/group` — The Group Database

```bash
cat /etc/group
```

**Sample line:**

```
docker:x:999:ahmed,fatima
```

```
ANATOMY OF AN /etc/group LINE
═══════════════════════════════════════════════════════════════
  docker : x : 999 : ahmed,fatima
     │      │    │         │
     │      │    │         └─ Members (comma-separated usernames)
     │      │    └─ GID (group ID)
     │      └─ Password placeholder (rarely used today)
     └─ Group name
═══════════════════════════════════════════════════════════════
```

```bash
# See all groups
cat /etc/group

# See which groups YOU belong to
groups
groups ahmed              # Groups for a specific user
id -Gn                    # Group names for current user
id -Gn ahmed               # Group names for specific user

# Find which group a GID maps to
getent group 999
```

> **🎓 Interview Question:** _"What's the difference between primary and secondary groups?"_ **Answer:** A primary group is the default group assigned to files a user creates (one per user, set in `/etc/passwd`). Secondary groups grant ADDITIONAL access (e.g., being in the `docker` or `sudo` group) and a user can belong to many of them simultaneously.

---

# PART D: USER MANAGEMENT COMMANDS

## 🛠️ Creating, Modifying, Deleting Users

### `useradd` — Create a New User

```bash
sudo useradd ahmed                        # Basic user creation (no home dir by default on some distros!)
sudo useradd -m ahmed                     # -m: create home directory too
sudo useradd -m -s /bin/bash ahmed        # -s: set login shell
sudo useradd -m -c "Ahmed Khan" ahmed     # -c: add comment/full name
sudo useradd -m -G sudo,docker ahmed      # -G: add to secondary groups at creation
sudo useradd -m -u 1500 ahmed             # -u: specify exact UID
sudo useradd -r serviceacct               # -r: create a SYSTEM account (low UID, no login)
```

**Syntax:** `useradd [OPTIONS] username`

| Option | Meaning                                                  |
| ------ | -------------------------------------------------------- |
| `-m`   | Create home directory                                    |
| `-s`   | Set login shell (e.g., `/bin/bash`, `/usr/sbin/nologin`) |
| `-c`   | Comment field (usually full name)                        |
| `-G`   | Secondary groups (comma-separated)                       |
| `-g`   | Primary group                                            |
| `-u`   | Specific UID                                             |
| `-r`   | System account                                           |
| `-e`   | Expiry date (YYYY-MM-DD)                                 |

> **🎓 Common Mistake:** Forgetting `-m`! On many distros, `useradd` WITHOUT `-m` creates a user with NO home directory — leading to confusing "permission denied" or missing `.bashrc` issues. Always use `sudo useradd -m username` unless you specifically want a service account.

### `passwd` — Set or Change a Password

```bash
sudo passwd ahmed              # Set password for another user (as root)
passwd                         # Change YOUR OWN password
sudo passwd -l ahmed           # Lock the account (disable login)
sudo passwd -u ahmed           # Unlock the account
sudo passwd -e ahmed           # Force password change on next login
sudo passwd -S ahmed           # Show password status
sudo passwd -d ahmed           # Delete password (⚠️ no password = security risk!)
```

### `usermod` — Modify an Existing User

```bash
sudo usermod -aG docker ahmed       # ADD ahmed to docker group (-a = append, never forget this!)
sudo usermod -aG sudo,docker ahmed  # Add to multiple groups at once
sudo usermod -s /bin/zsh ahmed      # Change login shell
sudo usermod -c "New Full Name" ahmed   # Change comment field
sudo usermod -l newname oldname     # Rename a user
sudo usermod -L ahmed               # Lock account
sudo usermod -U ahmed               # Unlock account
sudo usermod -d /new/home -m ahmed  # Move home directory (and move files with -m)
```

> **⚠️ CRITICAL WARNING:** `usermod -G docker ahmed` (WITHOUT `-a`) **REPLACES ALL** of ahmed's secondary groups with just `docker`! Always use `-aG` (append) unless you intentionally want to wipe existing group memberships.

```
THE -a FLAG TRAP
═══════════════════════════════════════════════════════════════
  BEFORE: ahmed is in groups: sudo, developers, docker

  ❌ sudo usermod -G docker ahmed
     RESULT: ahmed is now ONLY in: docker
     (sudo and developers REMOVED! 😱)

  ✅ sudo usermod -aG docker ahmed
     RESULT: ahmed is now in: sudo, developers, docker
     (docker ADDED, nothing removed ✅)
═══════════════════════════════════════════════════════════════
```

### `userdel` — Delete a User

```bash
sudo userdel ahmed              # Delete user, but KEEP home directory
sudo userdel -r ahmed           # Delete user AND home directory + mail spool
sudo userdel -f ahmed           # Force deletion even if logged in
```

### Real-World Example: Onboarding a New Employee

```bash
# Step-by-step: create a new developer account
sudo useradd -m -s /bin/bash -c "Sara Ali" sara
sudo passwd sara
sudo usermod -aG sudo,docker,developers sara
sudo mkdir -p /home/sara/.ssh
sudo chmod 700 /home/sara/.ssh
sudo chown sara:sara /home/sara/.ssh
echo "ssh-rsa AAAA...(public key)..." | sudo tee /home/sara/.ssh/authorized_keys
sudo chmod 600 /home/sara/.ssh/authorized_keys
sudo chown sara:sara /home/sara/.ssh/authorized_keys
id sara                          # Verify everything!
```

---

# PART E: GROUP MANAGEMENT COMMANDS

```bash
# CREATE a group
sudo groupadd developers
sudo groupadd -g 2000 developers     # With specific GID

# MODIFY a group
sudo groupmod -n newname oldname     # Rename a group
sudo groupmod -g 2500 developers     # Change GID

# DELETE a group
sudo groupdel developers             # (fails if it's someone's primary group!)

# ADD/REMOVE users from a group
sudo gpasswd -a ahmed developers     # Add ahmed to developers
sudo gpasswd -d ahmed developers     # Remove ahmed from developers

# Alternative way to add a user to a group
sudo usermod -aG developers ahmed

# See members of a group
getent group developers
grep "^developers:" /etc/group
```

| Command      | Purpose                |
| ------------ | ---------------------- |
| `groupadd`   | Create a new group     |
| `groupmod`   | Modify group name/GID  |
| `groupdel`   | Delete a group         |
| `gpasswd -a` | Add user to group      |
| `gpasswd -d` | Remove user from group |

---

# PART F: FILE PERMISSIONS (rwx EXPLAINED FULLY)

## 🔐 The Three Permission Types

```
THE THREE PERMISSIONS
═══════════════════════════════════════════════════════════════
  r (read)     → View file content / list directory contents
  w (write)    → Modify file content / create-delete files in dir
  x (execute)  → Run file as a program / "enter" a directory (cd)
═══════════════════════════════════════════════════════════════
```

> **📌 Key Point for Directories:** `x` on a directory does NOT mean "execute" — it means **you can `cd` into it**. Without `x`, you cannot enter or access files inside, even if you have `r`!

## 👥 The Three Permission Groups (Who)

```
WHO GETS PERMISSIONS?
═══════════════════════════════════════════════════════════════
  OWNER (u)    → The single user who owns the file
  GROUP (g)    → Members of the file's group
  OTHERS (o)   → Everyone else on the system
═══════════════════════════════════════════════════════════════
```

## 🔍 Reading `ls -l` Permission Output

```
DECODING ls -l OUTPUT
═══════════════════════════════════════════════════════════════════

  -rwxr-xr--  1  ahmed  developers  4096  Jun 14 10:00  script.sh
  │└┬┘└┬┘└┬┘   │    │        │
  │ │  │  │    │    │        └─ Group owner
  │ │  │  │    │    └─ User owner
  │ │  │  │    └─ Number of hard links
  │ │  │  └─ OTHERS permissions  (r-- = read only)
  │ │  └─ GROUP permissions      (r-x = read + execute)
  │ └─ OWNER permissions          (rwx = read + write + execute)
  └─ File type (- = file, d = directory, l = symlink)

  FILE TYPE CHARACTERS:
  -  = regular file
  d  = directory
  l  = symbolic link
  c  = character device
  b  = block device
  s  = socket
  p  = named pipe

═══════════════════════════════════════════════════════════════════
```

## 🔢 Symbolic vs Numeric (Octal) Notation

```
SYMBOLIC vs NUMERIC PERMISSIONS
═══════════════════════════════════════════════════════════════════

  Each permission has a numeric value:
     r = 4        w = 2        x = 1        (none = 0)

  Add them up for each group (owner/group/others):

  rwx  = 4+2+1 = 7        rw-  = 4+2+0 = 6
  r-x  = 4+0+1 = 5        r--  = 4+0+0 = 4
  -wx  = 0+2+1 = 3        --x  = 0+0+1 = 1
  ---  = 0+0+0 = 0

  FULL EXAMPLE:
  rwxr-xr--
   │   │  │
  owner│ others
       group

  owner = rwx = 7
  group = r-x = 5
  others= r-- = 4

  RESULT: 754

═══════════════════════════════════════════════════════════════════
```

### Common Permission Combinations

| Numeric | Symbolic    | Meaning                                        | Common Use                        |
| ------- | ----------- | ---------------------------------------------- | --------------------------------- |
| `777`   | `rwxrwxrwx` | Everyone can do anything                       | ⚠️ Never use (huge security risk) |
| `755`   | `rwxr-xr-x` | Owner full, others read+execute                | Scripts, executable programs      |
| `644`   | `rw-r--r--` | Owner edits, others read only                  | Regular documents, configs        |
| `700`   | `rwx------` | Only owner has any access                      | Private scripts, SSH keys folder  |
| `600`   | `rw-------` | Only owner can read/write                      | Private files, SSH private keys   |
| `750`   | `rwxr-x---` | Owner full, group read+execute, others nothing | Shared team scripts               |
| `666`   | `rw-rw-rw-` | Everyone can read/write                        | ⚠️ Rarely appropriate             |

---

# PART G: chmod, chown, chgrp MASTERY

## 🔧 `chmod` — Change Mode (Permissions)

### Numeric Method

```bash
chmod 755 script.sh         # rwxr-xr-x
chmod 644 document.txt      # rw-r--r--
chmod 700 ~/.ssh            # rwx------ (private!)
chmod -R 755 /var/www/html  # -R = recursive (apply to all subfolders/files)
```

### Symbolic Method (More Flexible)

```bash
chmod u+x script.sh         # Add execute permission for owner (u)
chmod g-w file.txt          # Remove write permission for group (g)
chmod o-r secret.txt        # Remove read permission for others (o)
chmod a+r file.txt          # Add read for ALL (a = u+g+o)
chmod u+x,g+x script.sh     # Multiple changes at once
chmod u=rwx,g=rx,o=r file   # Set EXACT permissions (= overwrites)
chmod -x script.sh          # Remove execute for everyone
```

```
SYMBOLIC chmod SYNTAX
═══════════════════════════════════════════════════════════════
  WHO        OPERATION       PERMISSION
  u (user)   + (add)         r (read)
  g (group)  - (remove)      w (write)
  o (other)  = (set exact)   x (execute)
  a (all)

  Example: chmod g+w file.txt
           └─┬─┘ │└┬┘
            who  │ permission
                 operation (add)
═══════════════════════════════════════════════════════════════
```

### Real-World chmod Examples

```bash
chmod 600 ~/.ssh/id_rsa            # SSH private key — owner read/write only
chmod 644 ~/.ssh/id_rsa.pub        # SSH public key — readable by all
chmod 700 ~/.ssh                   # SSH folder itself — private
chmod +x deploy.sh                 # Make a script executable
chmod -R 755 /var/www/html/        # Web files — readable/executable by all
chmod -R go-w /etc/myapp/          # Remove write access for group+others
```

> **🎓 Interview Question:** _"You run a script and get 'Permission denied.' What do you check first?"_ **Answer:** Run `ls -l script.sh` to check if the execute bit (`x`) is set for your user. If missing, run `chmod +x script.sh`. Also verify you're running it correctly: `./script.sh` not just `script.sh` (unless it's in your `$PATH`).

## 👤 `chown` — Change Owner

```bash
sudo chown ahmed file.txt              # Change owner only
sudo chown ahmed:developers file.txt   # Change owner AND group
sudo chown :developers file.txt        # Change ONLY the group (note the colon)
sudo chown -R ahmed:ahmed /home/ahmed  # Recursive — fix ownership of entire folder
sudo chown --reference=other.txt file.txt  # Copy ownership FROM another file
```

**Syntax:** `chown [OPTIONS] [OWNER][:GROUP] FILE`

## 👥 `chgrp` — Change Group Only

```bash
sudo chgrp developers file.txt          # Change group ownership
sudo chgrp -R developers /shared/project/   # Recursive
```

> **📌 Note:** `chown user:group file` does the SAME job as running both `chown user file` and `chgrp group file` — it's just more convenient.

### Real-World Scenario: Fixing a Web Server's Permissions

```bash
# Website files should be owned by www-data, readable by all, writable by owner
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;   # Directories: 755
sudo find /var/www/html -type f -exec chmod 644 {} \;   # Files: 644
```

---

# PART H: SPECIAL PERMISSIONS (SUID, SGID, STICKY BIT)

## 🎭 Beyond Basic rwx — The Special Three

```
SPECIAL PERMISSIONS OVERVIEW
═══════════════════════════════════════════════════════════════════
  SUID (Set User ID)    → Run the program AS THE FILE OWNER
                            (not as the person running it!)
  SGID (Set Group ID)   → Run as the file's GROUP, OR new files in a
                            directory inherit the directory's group
  STICKY BIT            → In a shared directory, only the file's
                            OWNER (or root) can delete their own files
═══════════════════════════════════════════════════════════════════
```

## 🔑 SUID — The Classic Example: `passwd`

```bash
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 59976 ... /usr/bin/passwd
#     │
#     └─ "s" instead of "x" = SUID bit is SET
```

```
WHY passwd NEEDS SUID
═══════════════════════════════════════════════════════════════════

  Without SUID:                     With SUID:
  ──────────────                    ───────────
  ahmed runs passwd                  ahmed runs passwd
       │                                  │
       ▼                                  ▼
  Tries to edit /etc/shadow           Program TEMPORARILY runs
  (only root can write this!)         AS ROOT (because of SUID)
       │                                  │
       ▼                                  ▼
  PERMISSION DENIED ❌                Successfully updates
                                       /etc/shadow ✅
                                       (then drops back to ahmed)

═══════════════════════════════════════════════════════════════════
```

### Setting and Finding SUID

```bash
sudo chmod u+s program          # Set SUID (symbolic)
sudo chmod 4755 program         # Set SUID (numeric: 4 = SUID, then 755)

# FIND all SUID programs on the system (important security audit!)
find / -perm -4000 -type f 2>/dev/null
```

> **⚠️ SECURITY WARNING:** SUID binaries are a major attack target. If a SUID program owned by root has a bug, an attacker can exploit it to gain root access. Auditing SUID files regularly is a core security task — covered more in Chapter 10 (Security).

## 🔑 SGID — Shared Group Directories

```bash
sudo chmod g+s /shared/project       # Set SGID (symbolic)
sudo chmod 2775 /shared/project      # Set SGID (numeric: 2 = SGID)

# FIND all SGID files
find / -perm -2000 -type f 2>/dev/null
```

```
SGID ON A DIRECTORY — TEAM COLLABORATION TRICK
═══════════════════════════════════════════════════════════════════

  /shared/project   (group: developers, SGID SET)

  WITHOUT SGID:                     WITH SGID:
  ──────────────                    ──────────
  ahmed creates file.txt             ahmed creates file.txt
  → group = ahmed's primary group    → group = developers
    (developers can't access it!)      (AUTOMATICALLY inherited!)

  Great for team folders where      Every new file/folder automatically
  everyone needs access             belongs to the right team group

═══════════════════════════════════════════════════════════════════
```

## 🔑 Sticky Bit — Protecting Shared Folders Like `/tmp`

```bash
ls -ld /tmp
# drwxrwxrwt 10 root root 4096 Jun 14 10:00 /tmp
#           │
#           └─ "t" = Sticky bit is SET

sudo chmod +t /shared/dropbox        # Set sticky bit (symbolic)
sudo chmod 1777 /shared/dropbox      # Set sticky bit (numeric: 1 = sticky)
```

```
STICKY BIT IN ACTION
═══════════════════════════════════════════════════════════════════

  /tmp directory (permissions: 1777 — everyone can write!)

  WITHOUT sticky bit:                WITH sticky bit:
  ────────────────────               ─────────────────
  fatima can DELETE ahmed's          fatima CANNOT delete ahmed's
  files in /tmp (since she           files — only ahmed (or root)
  has write access to the dir)       can delete ahmed's own files!
  😱 Chaos in shared folders          😊 Safe shared folder

═══════════════════════════════════════════════════════════════════
```

## 🧮 Combining Special Permissions (Numeric)

```
4-DIGIT NUMERIC PERMISSIONS
═══════════════════════════════════════════════════════════════
  First digit = special permission sum:
     4 = SUID      2 = SGID      1 = Sticky bit

  Example: chmod 4755 file
           │   │
           │   └─ owner=rwx, group=r-x, others=r-x
           └───── SUID set

  Example: chmod 2775 directory
           │   │
           │   └─ owner=rwx, group=rwx, others=r-x
           └───── SGID set

  Example: chmod 1777 directory
           │   │
           │   └─ owner=rwx, group=rwx, others=rwx
           └───── Sticky bit set
═══════════════════════════════════════════════════════════════
```

| Symbol in `ls -l`                | Meaning                                                |
| -------------------------------- | ------------------------------------------------------ |
| `rws` (lowercase s, owner has x) | SUID set + execute                                     |
| `rwS` (uppercase S)              | SUID set but NO execute (unusual/likely misconfigured) |
| `rwxr-sr-x`                      | SGID set + execute                                     |
| `rwxrwxrwt` (lowercase t)        | Sticky bit set + execute on others                     |
| `rwxrwxrwT` (uppercase T)        | Sticky bit set but NO execute on others                |

---

# PART I: umask — DEFAULT PERMISSION CONTROL

## 🎯 What Determines Default Permissions on New Files?

When you create a new file, Linux doesn't just guess permissions — it calculates them using **umask** (User file-creation MASK).

```
HOW umask WORKS
═══════════════════════════════════════════════════════════════════

  Default MAX permissions:
    Files:        666 (rw-rw-rw-)  — files never get x by default
    Directories:  777 (rwxrwxrwx)

  Then SUBTRACT the umask value:

    Default umask is usually:  022

    FILE:        666
              -  022
              ────────
                 644   (rw-r--r--)   ← what you actually get!

    DIRECTORY:   777
              -  022
              ────────
                 755   (rwxr-xr-x)   ← what you actually get!

═══════════════════════════════════════════════════════════════════
```

```bash
umask                       # Show current umask value
umask -S                    # Show in symbolic form (u=rwx,g=rx,o=rx)
umask 027                   # Set a stricter umask (for this session only)

# Make umask permanent: add to ~/.bashrc or /etc/profile
echo "umask 027" >> ~/.bashrc
```

### Real-World Test

```bash
umask 022
touch testfile1.txt
mkdir testdir1
ls -l testfile1.txt testdir1
# testfile1.txt → rw-r--r-- (644)
# testdir1      → rwxr-xr-x (755)

umask 077
touch testfile2.txt
ls -l testfile2.txt
# testfile2.txt → rw------- (600)  ← much more private!
```

> **🎓 Interview Question:** _"Your company wants new files to default to private (only owner access). What umask should you set?"_ **Answer:** `umask 077` — this subtracts all group/other permissions, leaving files at `600` and directories at `700`.

---

# PART J: ACLs — BEYOND BASIC PERMISSIONS

## 🎯 The Limitation of Basic Permissions

Basic Linux permissions only let you set rules for ONE owner, ONE group, and "everyone else." But what if you need: _"ahmed gets read-write, fatima gets read-only, everyone else gets nothing"_ — on the SAME file?

**That's exactly what ACLs (Access Control Lists) solve.**

```
WHY ACLs EXIST
═══════════════════════════════════════════════════════════════════
  BASIC PERMISSIONS                  ACLs
  ───────────────────                ─────
  Only 3 categories:                 Unlimited specific rules:
  • Owner                            • ahmed: rw-
  • Group                            • fatima: r--
  • Others                           • developers group: rwx
                                      • marketing group: r--
  Can't give ONE specific            Can target SPECIFIC users/groups
  extra user special access          beyond just owner/group/other
═══════════════════════════════════════════════════════════════════
```

### Real World: Using ACLs

```bash
# CHECK if ACL is supported / view current ACLs
getfacl file.txt

# GRANT a specific user permission via ACL
setfacl -m u:fatima:rw file.txt        # Give fatima read+write
setfacl -m g:marketing:r file.txt      # Give marketing group read-only

# REMOVE a specific ACL entry
setfacl -x u:fatima file.txt

# REMOVE ALL ACL entries (revert to basic permissions)
setfacl -b file.txt

# SET DEFAULT ACLs on a directory (new files inherit these rules!)
setfacl -d -m u:fatima:rw /shared/project/

# Recursive ACL application
setfacl -R -m u:fatima:rw /shared/project/
```

**Sample `getfacl` output:**

```
# file: file.txt
# owner: ahmed
# group: ahmed
user::rw-
user:fatima:rw-
group::r--
mask::rw-
other::r--
```

```bash
# After setting an ACL, ls -l shows a "+" sign!
ls -l file.txt
# -rw-rw-r--+ 1 ahmed ahmed 1234 Jun 14 10:00 file.txt
#          │
#          └─ The "+" means this file has ACLs beyond basic permissions
```

---

# PART K: sudo vs su — BECOMING ROOT SAFELY

## ⚔️ Two Ways to Get Admin Power

```
sudo vs su
═══════════════════════════════════════════════════════════════════
  su (Switch User)                  sudo (Superuser DO)
  ──────────────────                ─────────────────────
  • Becomes a DIFFERENT user        • Runs ONE command as root
    (usually root) for the WHOLE     (or another user) — then returns
    session                          to your normal user
  • Needs the TARGET user's         • Needs YOUR OWN password
    password (root's password!)     • Every action is LOGGED
  • Less auditable                  • Much safer and traceable
  • Old-school UNIX way             • Modern best practice
═══════════════════════════════════════════════════════════════════
```

### Real World: Using sudo and su

```bash
# sudo — run a single command as root
sudo apt update
sudo systemctl restart nginx
sudo cat /etc/shadow

# Run a command as a SPECIFIC user (not just root)
sudo -u www-data whoami

# Get an interactive root SHELL via sudo (still logged/auditable)
sudo -i
sudo -s

# su — switch user entirely
su -                    # Become root (needs ROOT's password!)
su - ahmed              # Switch to user ahmed (needs ahmed's password)
su                       # Switch to root, but keep current environment (less clean)
exit                     # Return to your original user
```

## 📜 `/etc/sudoers` — Who Can Use sudo

```bash
sudo visudo              # ALWAYS use visudo to edit (checks syntax before saving!)
```

**Common sudoers entries:**

```
# Allow members of the 'sudo' group to run any command
%sudo   ALL=(ALL:ALL) ALL

# Allow ahmed to run ANY command as root, no password needed
ahmed   ALL=(ALL) NOPASSWD: ALL

# Allow fatima to ONLY restart nginx (least privilege!)
fatima  ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
```

> **⚠️ CRITICAL WARNING:** NEVER edit `/etc/sudoers` directly with a text editor like `nano` or `vim`! Always use `sudo visudo` — it validates syntax before saving. A broken sudoers file can lock EVERYONE out of sudo, including yourself!

```bash
# Check who can use sudo
sudo -l                    # List YOUR sudo privileges
getent group sudo          # See members of the sudo group (Debian/Ubuntu)
getent group wheel         # See members of the wheel group (RHEL/CentOS)
```

> **🎓 Interview Question:** _"What's the difference between `sudo su -` and `su -`?"_ **Answer:** `su -` requires you to know root's actual password. `sudo su -` requires only YOUR password (assuming you're in the sudoers file), then uses your sudo privilege to switch to root — this is why many cloud images disable direct root login entirely and rely on `sudo`.

---

# PART L: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 3 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Users:
     • UID 0 = root, UID 1-999 = system accounts, UID 1000+ = humans
     • /etc/passwd = user info (public), /etc/shadow = passwords (root only)

  ✅ Groups:
     • Primary group = default group for new files (1 per user)
     • Secondary groups = extra access (sudo, docker, etc.) — many allowed
     • /etc/group = group database

  ✅ User/Group Management:
     useradd -m -s -G    usermod -aG (NEVER forget the -a!)
     userdel -r          groupadd / groupmod / groupdel
     passwd               gpasswd -a / -d

  ✅ Permissions (rwx):
     • r=4, w=2, x=1 — add up per owner/group/others
     • chmod (numeric or symbolic), chown, chgrp
     • x on a directory = permission to "enter" it (cd)

  ✅ Special Permissions:
     SUID (4) = run as file owner   |  SGID (2) = run as file group /
     inherit group on new files     |  Sticky bit (1) = only owner can
                                        delete own files in shared folder

  ✅ umask:
     • Subtracts from default max permissions (666 files, 777 dirs)
     • umask 022 → 644 files, 755 dirs (typical default)

  ✅ ACLs:
     • getfacl / setfacl — grant specific users/groups beyond basic rwx
     • "+" after permissions in ls -l means ACLs are present

  ✅ sudo vs su:
     • sudo = run one command as root, uses YOUR password, logged
     • su = switch user entirely, needs TARGET's password
     • Always edit sudoers with `visudo`, never directly!

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 3 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

USER MANAGEMENT                GROUP MANAGEMENT               PERMISSIONS
──────────────────────         ─────────────────────         ───────────────────
useradd -m -s sh user  Create  groupadd name      Create      chmod 755 f    Numeric
passwd user             Set pw groupmod -n new old Rename     chmod u+x f    Symbolic
usermod -aG grp user    Add grp groupdel name      Delete      chown user f   Owner
usermod -L/-U user      Lock/Unlk gpasswd -a u g   Add to grp  chown u:g f    Owner+Grp
userdel -r user         Delete  gpasswd -d u g     Remove      chgrp grp f    Group only

IDENTITY                       SPECIAL PERMS                  ACLs
──────────────────────         ─────────────────────         ───────────────────
whoami          My name        chmod u+s file  SUID           getfacl file   View ACL
id              UID/GID/groups chmod g+s dir   SGID           setfacl -m     Add rule
groups          My groups      chmod +t dir    Sticky         setfacl -x     Remove rule
who / w         Logged in users find / -perm -4000  Find SUID setfacl -b     Clear ACLs

ROOT ACCESS                    UMASK
──────────────────────         ─────────────────────
sudo cmd        Run as root    umask           Show current
sudo -u user    Run as user    umask 022       Set value
sudo -i / -s    Root shell     umask -S        Symbolic view
su - user       Switch user    visudo          Edit sudoers safely

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 3 Interview Questions

| #   | Question                                                       | Key Answer Points                                                                                           |
| --- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| 1   | What's the difference between `/etc/passwd` and `/etc/shadow`? | passwd = public user info; shadow = encrypted passwords, root-only readable                                 |
| 2   | What UID does root always have?                                | 0                                                                                                           |
| 3   | What's the difference between primary and secondary groups?    | Primary = default group for new files (one); secondary = extra access (many)                                |
| 4   | Why must you use `-a` with `usermod -G`?                       | Without `-a`, it REPLACES all secondary groups instead of adding one                                        |
| 5   | What does `x` mean on a directory?                             | Permission to enter/cd into the directory, not "execute"                                                    |
| 6   | Convert `rwxr-xr--` to numeric.                                | 754                                                                                                         |
| 7   | What is SUID used for?                                         | Lets a program run with the FILE OWNER's privileges, e.g. `passwd` running as root temporarily              |
| 8   | What does the sticky bit do?                                   | In a shared writable directory, only the file owner (or root) can delete their own files                    |
| 9   | What is umask?                                                 | Value subtracted from default max permissions (666 files / 777 dirs) when new files are created             |
| 10  | What's the difference between `sudo` and `su`?                 | sudo runs one command with YOUR password (logged); su switches user entirely, needing the TARGET's password |
| 11  | How do you safely edit sudo permissions?                       | Always use `sudo visudo`, which validates syntax before saving                                              |
| 12  | What does a `+` after permissions in `ls -l` mean?             | The file has ACLs (Access Control List) entries beyond basic owner/group/other rules                        |
| 13  | How do you find all SUID files on a system?                    | `find / -perm -4000 -type f 2>/dev/null`                                                                    |

## 🔬 Practical Lab: Chapter 3 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: User Investigation
# ──────────────────────────────────────────────────────────────────
whoami
id
groups
cat /etc/passwd | tail -5
grep "^$USER:" /etc/passwd
sudo grep "^$USER:" /etc/shadow

# ──────────────────────────────────────────────────────────────────
# LAB 2: Create Users and Groups (practice account management)
# ──────────────────────────────────────────────────────────────────
sudo groupadd labteam
sudo useradd -m -s /bin/bash -c "Lab User One" labuser1
sudo passwd labuser1
sudo usermod -aG labteam labuser1
id labuser1
getent group labteam

# Clean up after the lab:
sudo userdel -r labuser1
sudo groupdel labteam

# ──────────────────────────────────────────────────────────────────
# LAB 3: Permissions Practice
# ──────────────────────────────────────────────────────────────────
mkdir -p ~/lab3 && cd ~/lab3
touch secret.txt shared.txt script.sh

chmod 600 secret.txt
chmod 644 shared.txt
chmod 755 script.sh
ls -l
# Convert each to symbolic form yourself before checking with ls -l!

chmod u+x,g-r shared.txt
ls -l shared.txt

# ──────────────────────────────────────────────────────────────────
# LAB 4: Special Permissions
# ──────────────────────────────────────────────────────────────────
ls -l /usr/bin/passwd            # Find the SUID bit on passwd
ls -ld /tmp                       # Find the sticky bit on /tmp
find / -perm -4000 -type f 2>/dev/null | head -10   # List SUID files

mkdir ~/lab3/teamfolder
chmod 2775 ~/lab3/teamfolder       # Set SGID
ls -ld ~/lab3/teamfolder

# ──────────────────────────────────────────────────────────────────
# LAB 5: umask and ACLs
# ──────────────────────────────────────────────────────────────────
umask
touch ~/lab3/defaultfile.txt
ls -l ~/lab3/defaultfile.txt

umask 077
touch ~/lab3/privatefile.txt
ls -l ~/lab3/privatefile.txt

# ACLs (skip if filesystem doesn't support, e.g. some containers)
touch ~/lab3/acltest.txt
getfacl ~/lab3/acltest.txt
setfacl -m u:nobody:r ~/lab3/acltest.txt
getfacl ~/lab3/acltest.txt
ls -l ~/lab3/acltest.txt          # Look for the "+" sign!
```

## 🧠 Mini Project: User Audit Script

```bash
cat > ~/user_audit.sh << 'EOF'
#!/bin/bash
# ─────────────────────────────────────────────
# Chapter 3 Mini Project: User & Permission Audit
# ─────────────────────────────────────────────

echo "========================================"
echo "   USER & PERMISSION AUDIT REPORT"
echo "   $(date)"
echo "========================================"
echo ""

echo "─── ALL HUMAN USERS (UID >= 1000) ─────"
awk -F: '$3 >= 1000 && $3 < 65534 {print $1 " (UID:" $3 ")"}' /etc/passwd
echo ""

echo "─── USERS WITH SUDO ACCESS ─────────────"
getent group sudo 2>/dev/null
getent group wheel 2>/dev/null
echo ""

echo "─── ACCOUNTS WITH NO PASSWORD SET ──────"
sudo awk -F: '($2 == "" ) {print $1 " has NO PASSWORD!"}' /etc/shadow
echo ""

echo "─── SUID BINARIES ON THE SYSTEM ────────"
find / -perm -4000 -type f 2>/dev/null
echo ""

echo "─── SGID BINARIES ON THE SYSTEM ────────"
find / -perm -2000 -type f 2>/dev/null
echo ""

echo "─── WORLD-WRITABLE FILES (RISKY!) ──────"
find / -xdev -perm -0002 -type f 2>/dev/null | head -10
echo ""

echo "─── CURRENTLY LOGGED IN USERS ──────────"
who
echo ""

echo "========================================"
echo "   END OF AUDIT"
echo "========================================"
EOF

chmod +x ~/user_audit.sh
bash ~/user_audit.sh
```

## 🗺️ Where You Are in the Linux Roadmap

```
LINUX MASTERY ROADMAP — YOUR PROGRESS
═══════════════════════════════════════════════════════════════════

  ✅ Chapter 1:  Hardware, Boot, OS, Kernel, History, First Commands
  ✅ Chapter 2:  Linux Filesystem (FHS, /proc, /sys, /dev, inodes, links)
  ✅ Chapter 3:  Users, Groups & Permissions (chmod, chown, SUID, ACLs)
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
  YOU ARE HERE: ✅✅✅ — Three chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

Next: [Chapter 4 — Text Processing: grep, sed, awk, and the Power of the Pipe](/chapter-4.md)

---
