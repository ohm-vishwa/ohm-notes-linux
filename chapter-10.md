# CHAPTER 10: LINUX SECURITY

### _PAM, SELinux, AppArmor, Encryption, and Hardening_

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 10
═══════════════════════════════════════════════════════════════
  PART A  →  Security Fundamentals — CIA Triad & Defense in Depth
  PART B  →  Authentication vs Authorization (Deep Dive)
  PART C  →  PAM — Pluggable Authentication Modules
  PART D  →  SELinux — Mandatory Access Control
  PART E  →  AppArmor — The Simpler Alternative
  PART F  →  Encryption — At Rest, In Transit, and GPG
  PART G  →  SSH Hardening
  PART H  →  Auditing & Intrusion Detection
  PART I  →  System Hardening Checklist
  PART J  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: SECURITY FUNDAMENTALS — CIA TRIAD & DEFENSE IN DEPTH

## 🛡️ The CIA Triad — The Foundation of All Security Thinking

```
THE CIA TRIAD
═══════════════════════════════════════════════════════════════════
  C — CONFIDENTIALITY    → Only authorized people can READ the data
                            (encryption, permissions, access control)

  I — INTEGRITY            → Data hasn't been TAMPERED WITH
                            (checksums, signatures, audit logs)

  A — AVAILABILITY          → Systems/data are accessible WHEN NEEDED
                            (backups, redundancy, DDoS protection)

  Every security control you'll learn maps to protecting ONE
  (or more) of these three properties.
═══════════════════════════════════════════════════════════════════
```

## 🧱 Defense in Depth — Layers, Not a Single Wall

```
DEFENSE IN DEPTH CONCEPT
═══════════════════════════════════════════════════════════════════

  Attacker tries to break in
       │
       ▼
  ┌───────────────────┐
  │ Layer 1: Firewall │  ← Blocks unwanted network traffic
  └────────┬──────────┘
           ▼
  ┌────────────────────────┐
  │ Layer 2: SSH Hardening │  ← Key-only auth, no root login
  └────────┬───────────────┘
           ▼
  ┌───────────────────────────┐
  │ Layer 3: Permissions/ACLs │ ← Even if they get in, limited access
  └────────┬──────────────────┘
           ▼
  ┌───────────────────────────┐
  │ Layer 4: SELinux/AppArmor │ ← Even as a user, processes are CONFINED
  └────────┬──────────────────┘
           ▼
  ┌─────────────────────┐
  │ Layer 5: Encryption │ ← Even if data is stolen, it's unreadable
  └────────┬────────────┘
           ▼
  ┌──────────────────────────────┐
  │ Layer 6: Auditing/Monitoring │ ← You DETECT the attempt and respond
  └──────────────────────────────┘

  No SINGLE layer is perfect — but an attacker must defeat
  ALL of them to succeed. That's defense in depth.

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Why isn't a firewall alone considered 'enough' security?"_ **Answer:** A firewall only controls network-level access; it does nothing once traffic is allowed through (e.g., a compromised application, a weak password, an insider threat). Defense in depth assumes any single layer can fail or be bypassed, so multiple independent layers (permissions, MAC systems, encryption, auditing) work together to limit damage.

---

# PART B: AUTHENTICATION VS AUTHORIZATION (DEEP DIVE)

## 🔑 Two Different Questions

```
AUTHENTICATION vs AUTHORIZATION
═══════════════════════════════════════════════════════════════════
  AUTHENTICATION                     AUTHORIZATION
  ─────────────────                  ─────────────────
  "WHO are you?"                      "What are you ALLOWED to do?"

  Proving identity                    Granting/restricting permissions
  (password, SSH key, fingerprint,    AFTER identity is confirmed
   2FA code)
                                       Examples: file permissions (Ch3),
  Examples: login prompt, sudo         sudoers rules, SELinux policies,
  password, SSH key challenge          group memberships
═══════════════════════════════════════════════════════════════════
```

> **📌 Key Point:** You can be successfully AUTHENTICATED (the system knows exactly who you are) but still NOT AUTHORIZED to do something (e.g., a regular user is authenticated but isn't authorized to edit `/etc/shadow`). These are always two separate checks.

## 🔐 Multi-Factor Authentication (MFA) on Linux

```bash
# Install Google Authenticator PAM module for SSH 2FA
sudo apt install libpam-google-authenticator
google-authenticator                    # Run as the user — generates QR code + secret

# Then configure PAM and sshd to require it (more in Part C!)
```

```
AUTHENTICATION FACTORS
═══════════════════════════════════════════════════════════════
  Something you KNOW    → password, PIN
  Something you HAVE    → SSH key, phone (TOTP app), hardware token
  Something you ARE      → fingerprint, face recognition

  MFA = combining 2 or more of these categories
  (a password + an SSH key is actually "2-factor" in spirit,
   though strict MFA usually refers to password + TOTP/hardware)
═══════════════════════════════════════════════════════════════
```

---

# PART C: PAM — PLUGGABLE AUTHENTICATION MODULES

## 🧩 What Is PAM?

PAM is a flexible framework that lets Linux decide HOW authentication happens — without each individual application (login, sudo, sshd) needing to implement its own password-checking logic.

```
PAM CONCEPT
═══════════════════════════════════════════════════════════════════

  Application (sshd, login, sudo, passwd...)
       │
       │  "Please authenticate this user"
       ▼
  ┌─────────────────────────────────────────────┐
  │              PAM FRAMEWORK                  │
  │                                             │
  │  Reads /etc/pam.d/<application-name>        │
  │  Decides WHICH modules to run, and HOW:     │
  │                                             │
  │  ┌──────────┐ ┌──────────┐ ┌────────────┐   │
  │  │ password │ │  2FA     │ │  account   │   │
  │  │ check    │ │  check   │ │  expiry    │   │
  │  │ module   │ │  module  │ │  check     │   │
  │  └──────────┘ └──────────┘ └────────────┘   │
  └─────────────────────────────────────────────┘
       │
       ▼
  ALLOW or DENY access

═══════════════════════════════════════════════════════════════════
```

## 📂 PAM Configuration Files

```bash
ls /etc/pam.d/                        # One config file per application!
cat /etc/pam.d/sshd                     # How SSH authenticates
cat /etc/pam.d/sudo                      # How sudo authenticates
cat /etc/pam.d/common-auth                 # Shared rules (Debian/Ubuntu style)
```

**Sample line from a PAM config:**

```
auth    required    pam_unix.so
```

```
PAM RULE STRUCTURE
═══════════════════════════════════════════════════════════════════
  auth    required    pam_unix.so
   │         │             │
   │         │             └─ The MODULE that does the actual check
   │         └─ CONTROL FLAG — what happens if this module fails
   └─ TYPE — which phase of auth this applies to

  TYPES:
    auth      → Verifies identity (password checking)
    account   → Checks account validity (expired? locked?)
    password  → Handles password CHANGES
    session   → Sets up/tears down the user's session (mounting, logging)

  CONTROL FLAGS:
    required    → Must succeed, but CONTINUES checking other rules
                   before reporting overall failure
    requisite   → Must succeed, STOPS IMMEDIATELY if it fails
    sufficient  → If THIS succeeds, no more checks needed — auth passes
    optional    → Doesn't affect the result unless it's the ONLY module
═══════════════════════════════════════════════════════════════════
```

## 🔒 Real-World PAM Use Cases

```bash
# 1. ENFORCE PASSWORD COMPLEXITY
sudo apt install libpam-pwquality
sudo nano /etc/pam.d/common-password
# Add/edit: password requisite pam_pwquality.so retry=3 minlen=12 ucredit=-1 lcredit=-1 dcredit=-1

# 2. LOCK ACCOUNT AFTER FAILED LOGIN ATTEMPTS
sudo nano /etc/pam.d/common-auth
# Add: auth required pam_tally2.so deny=5 unlock_time=900
# (Locks account for 900 seconds after 5 failed attempts)

# Check/reset failed login counts
sudo pam_tally2 --user ahmed
sudo pam_tally2 --user ahmed --reset

# 3. RESTRICT WHO CAN LOGIN VIA SSH USING PAM
sudo nano /etc/pam.d/sshd
# Add: auth required pam_listfile.so item=user sense=deny file=/etc/ssh/deniedusers onerr=succeed
```

> **⚠️ CRITICAL WARNING:** ALWAYS test PAM changes in a SEPARATE terminal session before closing your current one! A typo in a PAM config can lock EVERYONE out of the system, including root — sometimes requiring single-user/rescue mode to fix. Keep a root shell open while testing.

> **🎓 Interview Question:** _"What's the difference between the `required` and `requisite` PAM control flags?"_ **Answer:** Both must succeed for overall authentication to pass, but `required` continues evaluating the REST of the stack even after failing (so the attacker doesn't know WHICH check failed), while `requisite` stops immediately on failure, returning control right away — useful when continuing would be pointless or risky.

---

# PART D: SELinux — MANDATORY ACCESS CONTROL

## 🏛️ DAC vs MAC — A Critical Distinction

```
DAC vs MAC
═══════════════════════════════════════════════════════════════════
  DAC (Discretionary Access Control)   MAC (Mandatory Access Control)
  ────────────────────────────────      ──────────────────────────────
  This is REGULAR Linux permissions     This is SELinux / AppArmor
  (Chapter 3!) — chmod, chown

  The FILE OWNER decides who gets        The SYSTEM POLICY decides —
  access (their "discretion")            even the file owner CANNOT
                                          override it!

  If a process is compromised and        Even if compromised, the
  runs as root, it can access ANY        process is CONFINED to only
  file (root bypasses DAC entirely)      what its SELinux policy allows
                                          — root doesn't automatically
                                          bypass MAC!
═══════════════════════════════════════════════════════════════════
```

> **📌 Key Point:** This is THE most important concept in this chapter. Regular permissions (DAC) can be bypassed by root. SELinux (MAC) adds a SECOND, independent layer that even root processes must obey — dramatically limiting the damage if a service like a web server gets compromised.

## 🎛️ SELinux Modes

```bash
getenforce                       # Check current mode
sestatus                          # Detailed status

sudo setenforce 1                   # Set to Enforcing (live, until reboot)
sudo setenforce 0                    # Set to Permissive (live, until reboot)

# PERMANENT change — edit the config file
sudo nano /etc/selinux/config
# SELINUX=enforcing | permissive | disabled
```

```
SELinux MODES
═══════════════════════════════════════════════════════════════
  Enforcing    → Policy is ACTIVELY enforced; violations BLOCKED + logged
  Permissive   → Policy violations are LOGGED but NOT blocked
                  (great for testing new policies before enforcing!)
  Disabled      → SELinux completely off (NOT recommended for production)
═══════════════════════════════════════════════════════════════
```

## 🏷️ SELinux Contexts (Labels)

Every file, process, and port has an SELinux **context** (a label) — and policies define what context can interact with what.

```bash
ls -Z /var/www/html/                 # See SELinux context on files
ps -eZ | grep nginx                    # See SELinux context on a running process
id -Z                                   # See YOUR current SELinux context
```

**Sample context:** `system_u:object_r:httpd_sys_content_t:s0`

```
SELinux CONTEXT BREAKDOWN
═══════════════════════════════════════════════════════════════════
  system_u : object_r : httpd_sys_content_t : s0
     │           │              │                │
     │           │              │                └─ Sensitivity level (MLS, advanced)
     │           │              └─ TYPE — the MOST important part for policy decisions
     │           └─ ROLE
     └─ USER (SELinux user, NOT the same as Linux username!)

  The TYPE (httpd_sys_content_t) is what matters most day-to-day:
  it tells SELinux "this is web content, only web server processes
  with a matching type should touch it."
═══════════════════════════════════════════════════════════════════
```

### Real-World SELinux Scenario: "Why Can't Apache Read My File?!"

```
THE CLASSIC SELinux GOTCHA
═══════════════════════════════════════════════════════════════════
  You move a file into /var/www/html/ using "mv" from your
  home directory. The PERMISSIONS look fine (644, owned correctly)...

  But Apache STILL gets "Permission Denied"! Why?

  ANSWER: The file kept the SELinux context from your HOME
  DIRECTORY (user_home_t), not the web content context
  (httpd_sys_content_t) that Apache's policy expects!

  FIX:
  sudo restorecon -v /var/www/html/myfile.html
  (Restores the CORRECT default context for that location)

  Or set it explicitly:
  sudo chcon -t httpd_sys_content_t /var/www/html/myfile.html

  💡 LESSON: Use "cp" (or restorecon afterward) instead of "mv"
  when moving files into SELinux-managed directories — cp
  often picks up the correct context, mv preserves the OLD one!
═══════════════════════════════════════════════════════════════════
```

```bash
# Fix SELinux context issues
sudo restorecon -v /path/to/file        # Restore DEFAULT context for that path
sudo restorecon -Rv /var/www/html/       # Recursive

sudo chcon -t httpd_sys_content_t /path/to/file    # Manually SET a specific context

# PERMANENTLY define a context for a path (survives restorecon/relabeling)
sudo semanage fcontext -a -t httpd_sys_content_t "/srv/myapp(/.*)?"
sudo restorecon -Rv /srv/myapp

# Manage SELinux BOOLEANS (toggle specific policy behaviors)
getsebool -a | grep httpd                 # See all httpd-related booleans
sudo setsebool -P httpd_can_network_connect on    # Allow Apache to make outbound connections
```

## 🔍 Diagnosing SELinux Denials

```bash
# Check the audit log for SELinux denials
sudo ausearch -m avc -ts recent

# Translate a denial into a human-readable explanation + suggested fix!
sudo apt install setroubleshoot          # (or dnf install setroubleshoot on RHEL)
sealert -a /var/log/audit/audit.log

# Quick check: did SELinux block something recently?
sudo grep "denied" /var/log/audit/audit.log | tail -10
```

> **🎓 Interview Question:** _"A web server can't write to a directory even though file permissions are 777. What's the likely cause, and how do you diagnose it?"_ **Answer:** SELinux is likely blocking it despite permissive DAC permissions, since SELinux (MAC) is checked independently. Diagnose with `sudo ausearch -m avc -ts recent` or `sealert`, then fix with `restorecon` (to reset to the correct default context) or `semanage fcontext` (to permanently define a new context) — NEVER simply disable SELinux as the fix.

---

# PART E: AppArmor — THE SIMPLER ALTERNATIVE

## 🧥 SELinux vs AppArmor

```
SELinux vs AppArmor
═══════════════════════════════════════════════════════════════════
  SELinux                             AppArmor
  ─────────                          ──────────
  Used by: RHEL, Fedora, CentOS       Used by: Ubuntu, Debian, SUSE
  LABEL-based (every file/process     PATH-based (rules reference
   gets a security context)            file PATHS directly — simpler!)
  More powerful, more granular         Easier to learn and write profiles
  Steeper learning curve                Faster to get started
═══════════════════════════════════════════════════════════════════
```

```bash
sudo aa-status                       # Check AppArmor status and loaded profiles
sudo systemctl status apparmor         # Is the service running?

ls /etc/apparmor.d/                    # Profile files, one per application

# Put a profile into COMPLAIN mode (log only, don't block — for testing)
sudo aa-complain /etc/apparmor.d/usr.sbin.nginx

# Put a profile into ENFORCE mode (actively block violations)
sudo aa-enforce /etc/apparmor.d/usr.sbin.nginx

# Generate a NEW profile for an application interactively
sudo aa-genprof /usr/sbin/myapp
```

**Sample AppArmor profile snippet:**

```
/usr/sbin/nginx {
  /var/www/html/** r,
  /var/log/nginx/*.log w,
  network inet stream,
}
```

```
READING AN AppArmor PROFILE
═══════════════════════════════════════════════════════════════
  /var/www/html/** r,        → Can READ anything under this path
  /var/log/nginx/*.log w,     → Can WRITE to log files specifically
  network inet stream,         → Can use TCP networking

  Much more READABLE than SELinux's label system — this is
  WHY Ubuntu/Debian chose AppArmor for easier adoption!
═══════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Why might a distro choose AppArmor over SELinux, or vice versa?"_ **Answer:** AppArmor's path-based profiles are simpler to read, write, and maintain, making it attractive for ease-of-use-focused distros like Ubuntu. SELinux's label-based system is more granular and powerful (can express more complex policies independent of file paths) but has a steeper learning curve, which is why security-focused enterprise distros like RHEL adopted it as the standard.

---

# PART F: ENCRYPTION — AT REST, IN TRANSIT, AND GPG

## 🔐 Encryption at Rest — Protecting Stored Data

```bash
# LUKS — Linux Unified Key Setup, the standard for full-disk/partition encryption
sudo cryptsetup luksFormat /dev/sdb1          # Encrypt a partition (DESTROYS existing data!)
sudo cryptsetup luksOpen /dev/sdb1 my_encrypted_volume    # Unlock it (asks for passphrase)
sudo mkfs.ext4 /dev/mapper/my_encrypted_volume              # Format the UNLOCKED volume
sudo mount /dev/mapper/my_encrypted_volume /mnt/secure        # Mount it normally

sudo cryptsetup luksClose my_encrypted_volume                  # Lock it again when done

cryptsetup luksDump /dev/sdb1                  # See encryption header info
```

```
LUKS ENCRYPTION FLOW
═══════════════════════════════════════════════════════════════════

  /dev/sdb1 (raw encrypted partition — looks like random noise)
       │
       │  luksOpen + correct passphrase
       ▼
  /dev/mapper/my_encrypted_volume (DECRYPTED, usable like a normal disk)
       │
       │  mount
       ▼
  /mnt/secure (you can read/write files NORMALLY here)

  Without the passphrase, /dev/sdb1's contents are
  computationally infeasible to read — even with physical
  access to the drive!

═══════════════════════════════════════════════════════════════════
```

## 🔒 Encryption in Transit — TLS/SSL

```bash
# Generate a self-signed certificate (for testing — NOT for production public sites!)
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365

# Check a remote site's certificate details
openssl s_client -connect google.com:443 -servername google.com

# View certificate expiration date
echo | openssl s_client -connect google.com:443 2>/dev/null | openssl x509 -noout -dates

# Let's Encrypt (free, automated, production-grade certificates)
sudo apt install certbot
sudo certbot --nginx -d example.com           # Automatically obtain + configure HTTPS!
sudo certbot renew --dry-run                    # Test that auto-renewal works
```

```
WHY TLS MATTERS — A QUICK RECAP
═══════════════════════════════════════════════════════════════
  HTTP   → Plain text — anyone on the network path can READ it
  HTTPS  → Encrypted via TLS — only the intended endpoints
            can read the actual content, even if intercepted

  This is WHY every modern website uses HTTPS — it's a
  Confidentiality AND Integrity control from the CIA triad!
═══════════════════════════════════════════════════════════════
```

## 🔑 GPG — Encrypting and Signing Files/Messages

```bash
# Generate your own GPG key pair
gpg --full-generate-key

# List your keys
gpg --list-keys
gpg --list-secret-keys

# ENCRYPT a file for a specific recipient (using THEIR public key)
gpg --encrypt --recipient "ahmed@example.com" secret.txt
# Creates secret.txt.gpg — only the recipient's PRIVATE key can decrypt it!

# DECRYPT a file (using YOUR private key)
gpg --decrypt secret.txt.gpg > secret_decrypted.txt

# SIGN a file (proves it really came from you, and wasn't tampered with)
gpg --sign document.txt

# VERIFY a signature
gpg --verify document.txt.sig document.txt

# Export your PUBLIC key to share with others
gpg --export --armor "ahmed@example.com" > ahmed_public.asc

# Import someone else's public key
gpg --import their_public.asc
```

```
GPG ENCRYPTION FLOW (Asymmetric/Public-Key Crypto)
═══════════════════════════════════════════════════════════════════

  You want to send Fatima a SECRET file:

  1. Get FATIMA'S PUBLIC key (she shared it openly — that's fine!)
  2. Encrypt the file USING her public key
  3. Send the encrypted file ANYWHERE (even insecurely — doesn't matter!)
  4. ONLY Fatima's PRIVATE key (which she never shares) can decrypt it

  Anyone can have her PUBLIC key. Only SHE has the PRIVATE key
  that can actually unlock data encrypted for her.

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"What's the difference between symmetric and asymmetric encryption, and where does each get used?"_ **Answer:** Symmetric encryption uses ONE shared key for both encryption and decryption (fast, used for bulk data like disk encryption/LUKS). Asymmetric encryption uses a PUBLIC/PRIVATE key pair — anyone can encrypt with the public key, but only the private key holder can decrypt (slower, used for key exchange, GPG, TLS handshakes, and digital signatures).

---

# PART G: SSH HARDENING

## 🔒 The SSH Daemon Config — `/etc/ssh/sshd_config`

```bash
sudo nano /etc/ssh/sshd_config
```

**Critical hardening settings:**

```
# 1. DISABLE root login entirely — force admins to login as a regular
#    user and use sudo (so actions are individually attributable!)
PermitRootLogin no

# 2. DISABLE password authentication — force SSH KEYS only
PasswordAuthentication no
PubkeyAuthentication yes

# 3. CHANGE the default port (reduces automated bot scanning noise —
#    NOT a real security boundary on its own, but reduces log spam)
Port 2222

# 4. LIMIT which users can SSH in at all
AllowUsers ahmed fatima deploy

# 5. LIMIT login attempts before disconnecting
MaxAuthTries 3

# 6. DISABLE empty passwords
PermitEmptyPasswords no

# 7. SET an idle timeout (disconnect inactive sessions)
ClientAliveInterval 300
ClientAliveCountMax 2

# 8. DISABLE X11 forwarding if not needed (reduces attack surface)
X11Forwarding no
```

```bash
# ALWAYS test config syntax before restarting sshd!
sudo sshd -t

# Apply changes
sudo systemctl restart sshd
```

> **⚠️ CRITICAL WARNING:** Just like with PAM and firewalls — NEVER close your current SSH session until you've verified the NEW configuration works by opening a SECOND connection first! If `PasswordAuthentication no` is set but you haven't properly set up SSH keys, you can permanently lock yourself out.

```
SSH HARDENING IMPACT SUMMARY
═══════════════════════════════════════════════════════════════════
  PermitRootLogin no          → Attackers can't even TRY root directly;
                                  forces individual accountability via sudo
  PasswordAuthentication no    → Eliminates brute-force password attacks
                                  entirely (no password to guess!)
  AllowUsers list               → Even with a stolen key, unlisted
                                  accounts can't connect
  Fail2ban (next section!)      → Automatically blocks IPs that DO try
                                  brute-forcing
═══════════════════════════════════════════════════════════════════
```

## 🚫 fail2ban — Automatic Brute-Force Protection

```bash
sudo apt install fail2ban
sudo systemctl enable --now fail2ban

sudo nano /etc/fail2ban/jail.local        # Custom config (don't edit jail.conf directly!)
```

**Sample `jail.local` SSH section:**

```ini
[sshd]
enabled = true
port = 22
maxretry = 3
bantime = 3600
findtime = 600
```

```bash
sudo fail2ban-client status                  # See active jails
sudo fail2ban-client status sshd               # See sshd-specific stats (banned IPs!)
sudo fail2ban-client set sshd unbanip 203.0.113.50   # Manually unban an IP
```

```
fail2ban CONCEPT
═══════════════════════════════════════════════════════════════
  fail2ban watches your logs (e.g. /var/log/auth.log)
       │
       │  Detects "Failed password" 3 times within 600 seconds
       ▼
  Automatically adds a FIREWALL RULE blocking that IP
  for 3600 seconds (1 hour)
       │
       ▼
  Attacker's brute-force script is now USELESS —
  blocked before it can try many passwords!
═══════════════════════════════════════════════════════════════
```

---

# PART H: AUDITING & INTRUSION DETECTION

## 📋 `auditd` — The Linux Audit Framework

```bash
sudo apt install auditd
sudo systemctl enable --now auditd

# Add a rule: watch for any changes to a sensitive file
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
#                              │      │
#                              │      └─ key/label for this rule (for searching later)
#                              └─ permissions to watch: w=write, a=attribute change

# Search the audit log
sudo ausearch -k passwd_changes
sudo ausearch -m USER_LOGIN              # All login events
sudo aureport --auth                       # Summary report of authentication events

# Make a rule PERMANENT (survives reboot)
echo "-w /etc/passwd -p wa -k passwd_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo systemctl restart auditd
```

## 🔎 File Integrity Monitoring

```bash
# AIDE — Advanced Intrusion Detection Environment
sudo apt install aide
sudo aideinit                              # Build the initial "known good" database
sudo aide --check                            # Compare current state to the database —
                                              # flags ANY unexpected file changes!
```

```
FILE INTEGRITY MONITORING CONCEPT
═══════════════════════════════════════════════════════════════
  Day 1: Build a database of checksums for every important
         system file (their "fingerprint" when known-good)

  Day 30: Run a check — AIDE recalculates checksums and
          compares them to Day 1's database

  If /bin/ls or /etc/passwd's checksum CHANGED unexpectedly
  → 🚨 Strong sign of tampering/compromise — investigate immediately!
═══════════════════════════════════════════════════════════════
```

## 🕵️ General Security Auditing Commands

```bash
# Find all SUID/SGID binaries (Chapter 3 callback — audit these regularly!)
find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null

# Find world-writable files (potential security risk)
find / -xdev -perm -0002 -type f 2>/dev/null

# Check for accounts with NO password set
sudo awk -F: '($2 == "") {print $1}' /etc/shadow

# Check for unauthorized accounts with UID 0 (should ONLY be root!)
awk -F: '$3 == 0 {print $1}' /etc/passwd

# Check what's listening on the network RIGHT NOW (Chapter 8 callback)
sudo ss -tulnp

# Review recent login history
last -20
lastb -20            # Failed login attempts specifically!
```

> **🎓 Interview Question:** _"How would you check if a Linux system has been compromised with a backdoor account?"_ **Answer:** Check `/etc/passwd` for unexpected accounts with UID 0 (should only be root), review `last`/`lastb` for unusual login activity, check `~/.ssh/authorized_keys` for unauthorized keys, audit cron jobs (`crontab -l` for all users) for unexpected scheduled tasks, and compare SUID binaries and file checksums (via AIDE) against a known-good baseline.

---

# PART I: SYSTEM HARDENING CHECKLIST

## ✅ A Practical Hardening Checklist (Combining Everything So Far!)

```
LINUX SERVER HARDENING CHECKLIST
═══════════════════════════════════════════════════════════════════

  USERS & AUTH (Chapter 3 + 10)
  ☐ Disable root SSH login (PermitRootLogin no)
  ☐ Use SSH keys only (PasswordAuthentication no)
  ☐ Enforce strong password policy (PAM pwquality)
  ☐ Remove/lock unused accounts
  ☐ Audit sudoers regularly (sudo -l, cat /etc/sudoers)

  NETWORK (Chapter 8)
  ☐ Enable firewall, default DENY incoming
  ☐ Only open ports you actually need
  ☐ Install fail2ban for brute-force protection
  ☐ Disable unused network services

  FILESYSTEM (Chapter 2 + 3)
  ☐ Audit SUID/SGID binaries regularly
  ☐ No world-writable files outside /tmp
  ☐ Encrypt sensitive partitions (LUKS)
  ☐ Set proper permissions on sensitive configs (600/640)

  ACCESS CONTROL (Chapter 10)
  ☐ SELinux/AppArmor in Enforcing mode (not Disabled!)
  ☐ Regularly review SELinux/AppArmor denial logs

  UPDATES (Chapter 5)
  ☐ Keep packages updated (security patches!)
  ☐ Subscribe to security mailing lists for your distro
  ☐ Consider unattended-upgrades for critical patches

  MONITORING (Chapter 9 + 10)
  ☐ Centralized, PERSISTENT logging (journald/rsyslog)
  ☐ auditd rules on sensitive files
  ☐ Regular review of auth logs / fail2ban bans
  ☐ File integrity monitoring (AIDE) baseline established

  BACKUPS (Chapter 9)
  ☐ 3-2-1 backup rule in place
  ☐ Backups tested (can you ACTUALLY restore from them?)

═══════════════════════════════════════════════════════════════════
```

---

# PART J: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 10 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Fundamentals:
     CIA triad: Confidentiality, Integrity, Availability
     Defense in depth: multiple independent layers, no single point of failure

  ✅ Authentication vs Authorization:
     Authentication = WHO you are   Authorization = WHAT you can do
     PAM = the framework controlling HOW authentication happens system-wide

  ✅ PAM:
     /etc/pam.d/<app>   auth/account/password/session types
     required/requisite/sufficient/optional control flags

  ✅ SELinux (MAC):
     DAC (regular perms, root bypasses) vs MAC (policy-enforced, even root obeys)
     Enforcing/Permissive/Disabled   Contexts (labels)   restorecon/chcon fixes

  ✅ AppArmor:
     Simpler, path-based alternative to SELinux (Ubuntu/Debian default)

  ✅ Encryption:
     LUKS = at-rest (disk/partition)   TLS = in-transit (HTTPS)
     GPG = asymmetric (public/private key pairs) for files/messages/signing

  ✅ SSH Hardening:
     No root login, keys only, AllowUsers, fail2ban for brute-force defense

  ✅ Auditing:
     auditd (watch specific files/events)   AIDE (file integrity baseline)
     Regular review of SUID files, UID 0 accounts, login history

  ✅ Hardening Checklist:
     Security spans EVERY chapter — it's a lens, not a single tool

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 10 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

PAM                              SELinux                         AppArmor
──────────────────────         ─────────────────────         ───────────────────
/etc/pam.d/<app>   Config       getenforce         Check mode  aa-status          Status
pam_unix.so        Pwd check    setenforce 0/1      Set mode    aa-complain prof   Log only
pam_tally2 --user  Failed logins ls -Z file          See context aa-enforce prof    Block mode
                                restorecon -v f      Fix context aa-genprof app     New profile
                                chcon -t type f       Set context

ENCRYPTION                       SSH HARDENING                   AUDITING
──────────────────────         ─────────────────────         ───────────────────
cryptsetup luksFormat  Encrypt  PermitRootLogin no  sshd_config auditctl -w f -p wa Watch file
cryptsetup luksOpen     Unlock  PasswordAuthentication no       ausearch -k tag    Search logs
gpg --encrypt -r user   Encrypt sudo sshd -t        Test config aureport --auth    Auth report
gpg --decrypt           Decrypt fail2ban-client status         aide --check       Integrity check
openssl s_client        Check TLS

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 10 Interview Questions

| #   | Question                                                                           | Key Answer Points                                                                                                                             |
| --- | ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | What is the CIA triad?                                                             | Confidentiality, Integrity, Availability — the 3 core properties security controls aim to protect                                             |
| 2   | Authentication vs authorization?                                                   | Authentication confirms WHO you are; authorization controls WHAT you're allowed to do                                                         |
| 3   | What is PAM?                                                                       | A pluggable framework that handles authentication logic for applications (login, sudo, sshd) via configurable modules                         |
| 4   | DAC vs MAC — what's the key difference?                                            | DAC (regular permissions) can be bypassed by root; MAC (SELinux/AppArmor) is enforced independently, even root processes must obey it         |
| 5   | Why would a file have correct chmod permissions but still get "Permission Denied"? | SELinux context mismatch — fix with `restorecon` or `chcon`, never just disable SELinux                                                       |
| 6   | SELinux's three modes?                                                             | Enforcing (blocks+logs violations), Permissive (logs only), Disabled (off entirely)                                                           |
| 7   | SELinux vs AppArmor?                                                               | SELinux is label-based, more granular, used by RHEL/Fedora; AppArmor is path-based, simpler, used by Ubuntu/Debian                            |
| 8   | Symmetric vs asymmetric encryption?                                                | Symmetric uses one shared key (fast, e.g. LUKS); asymmetric uses public/private key pairs (e.g. GPG, TLS handshakes)                          |
| 9   | Top 3 SSH hardening settings?                                                      | PermitRootLogin no, PasswordAuthentication no, AllowUsers (restrict to specific accounts)                                                     |
| 10  | How does fail2ban work?                                                            | Monitors logs for repeated failed login attempts and automatically creates firewall rules to block offending IPs temporarily                  |
| 11  | What does auditd let you do that regular logs don't?                               | Watch SPECIFIC files/syscalls for specific actions (read/write/attribute change) with fine-grained, searchable, tamper-resistant audit trails |
| 12  | What is file integrity monitoring (e.g. AIDE)?                                     | Maintains a baseline of file checksums and detects unexpected changes, which can indicate compromise/tampering                                |

## 🔬 Practical Lab: Chapter 10 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: PAM Investigation
# ──────────────────────────────────────────────────────────────────
ls /etc/pam.d/
cat /etc/pam.d/sshd
cat /etc/pam.d/sudo
cat /etc/pam.d/common-auth 2>/dev/null || cat /etc/pam.d/system-auth

# ──────────────────────────────────────────────────────────────────
# LAB 2: SELinux/AppArmor Investigation (run whichever applies to YOUR distro)
# ──────────────────────────────────────────────────────────────────
getenforce 2>/dev/null && sestatus
ls -Z /var/www/html/ 2>/dev/null
sudo aa-status 2>/dev/null
ls /etc/apparmor.d/ 2>/dev/null

# ──────────────────────────────────────────────────────────────────
# LAB 3: Basic GPG Encryption Practice
# ──────────────────────────────────────────────────────────────────
echo "This is a secret test message" > secret.txt
gpg --symmetric --cipher-algo AES256 secret.txt    # Password-based (simpler for testing)
ls secret.txt.gpg
rm secret.txt
gpg --decrypt secret.txt.gpg > recovered.txt
cat recovered.txt

# ──────────────────────────────────────────────────────────────────
# LAB 4: SSH Config Audit (READ ONLY — don't restart sshd unless on a test VM!)
# ──────────────────────────────────────────────────────────────────
sudo grep -E "^(PermitRootLogin|PasswordAuthentication|Port|MaxAuthTries)" /etc/ssh/sshd_config
sudo sshd -t        # Verify current config has no syntax errors

# ──────────────────────────────────────────────────────────────────
# LAB 5: Security Self-Audit (run these on YOUR OWN system!)
# ──────────────────────────────────────────────────────────────────
find / -perm -4000 -type f 2>/dev/null              # SUID binaries
awk -F: '$3 == 0 {print $1}' /etc/passwd              # Should ONLY show "root"
sudo awk -F: '($2 == "") {print $1}' /etc/shadow       # Accounts with no password
last -10                                                # Recent logins
sudo ss -tulnp                                           # What's listening?
```

## 🧠 Mini Project: Security Audit Script

```bash
cat > ~/security_audit.sh << 'EOF'
#!/bin/bash
set -uo pipefail

echo "=========================================="
echo "   LINUX SECURITY AUDIT REPORT"
echo "   $(date)"
echo "=========================================="
echo ""

echo "─── MAC SYSTEM STATUS ──────────────────"
if command -v getenforce &>/dev/null; then
    echo "SELinux mode: $(getenforce)"
elif command -v aa-status &>/dev/null; then
    sudo aa-status --enabled && echo "AppArmor: enabled" || echo "AppArmor: NOT enabled!"
else
    echo "⚠️  No MAC system (SELinux/AppArmor) detected!"
fi
echo ""

echo "─── ACCOUNTS WITH UID 0 (should be ONLY root!) ──"
awk -F: '$3 == 0 {print $1}' /etc/passwd
echo ""

echo "─── ACCOUNTS WITH NO PASSWORD ──────────"
sudo awk -F: '($2 == "") {print $1 " ⚠️ NO PASSWORD"}' /etc/shadow 2>/dev/null
echo ""

echo "─── SUID BINARIES ──────────────────────"
find / -perm -4000 -type f 2>/dev/null | wc -l
echo "(run 'find / -perm -4000 -type f' to see the full list)"
echo ""

echo "─── WORLD-WRITABLE FILES (excluding /tmp) ──"
find / -xdev -perm -0002 -type f 2>/dev/null | grep -v "^/tmp" | head -10
echo ""

echo "─── SSH CONFIG CHECK ───────────────────"
sudo grep -E "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null || echo "PermitRootLogin not explicitly set (check default!)"
sudo grep -E "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null || echo "PasswordAuthentication not explicitly set"
echo ""

echo "─── FAIL2BAN STATUS ────────────────────"
sudo fail2ban-client status 2>/dev/null || echo "fail2ban not installed/running"
echo ""

echo "─── FIREWALL STATUS ────────────────────"
sudo ufw status 2>/dev/null || sudo firewall-cmd --state 2>/dev/null || echo "No supported firewall tool found"
echo ""

echo "─── RECENT FAILED LOGIN ATTEMPTS ───────"
sudo lastb -5 2>/dev/null || echo "No failed login data available"
echo ""

echo "=========================================="
echo "   END OF AUDIT"
echo "=========================================="
EOF

chmod +x ~/security_audit.sh
bash ~/security_audit.sh
```

## 🗺️ Where You Are in the Linux Roadmap

```
LINUX MASTERY ROADMAP — YOUR PROGRESS
═══════════════════════════════════════════════════════════════════

  ✅ Chapter 1:  Hardware, Boot, OS, Kernel, History, First Commands
  ✅ Chapter 2:  Linux Filesystem (FHS, /proc, /sys, /dev, inodes, links)
  ✅ Chapter 3:  Users, Groups & Permissions (chmod, chown, SUID, ACLs)
  ✅ Chapter 4:  Text Processing (grep, sed, awk, cut, sort, pipelines)
  ✅ Chapter 5:  Package Management (apt, dnf, pacman, dpkg, rpm)
  ✅ Chapter 6:  Shell Scripting (bash, variables, loops, functions, arrays)
  ✅ Chapter 7:  Process Management (ps, top, signals, jobs, nice)
  ✅ Chapter 8:  Networking (TCP/IP, DNS, SSH, firewalls, troubleshooting)
  ✅ Chapter 9:  System Administration (systemd, journald, cron, backup)
  ✅ Chapter 10: Linux Security (PAM, SELinux, AppArmor, encryption, hardening)
  ⬜ Chapter 11: Containers (Docker, namespaces, cgroups)
  ⬜ Chapter 12: Linux Kernel Development

═══════════════════════════════════════════════════════════════════
  YOU ARE HERE: ✅✅✅✅✅✅✅✅✅✅ — Ten chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

Next: [Chapter 11 — Containers: Docker, Namespaces, cgroups, and Kubernetes Basics](/chapter-11.md)

---
