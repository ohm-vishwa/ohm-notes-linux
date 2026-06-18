# CHAPTER 9: SYSTEM ADMINISTRATION

### _systemd, Logging, Scheduled Jobs, and Backup & Recovery_

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 9
═══════════════════════════════════════════════════════════════
  PART A  →  systemd — The Modern Init System
  PART B  →  systemd Units Deep Dive
  PART C  →  systemctl Mastery
  PART D  →  Creating Your Own systemd Service
  PART E  →  Logging with journald — journalctl Mastery
  PART F  →  Traditional Logging — rsyslog & logrotate
  PART G  →  Scheduling — cron, at, and systemd Timers
  PART H  →  Backup & Recovery Strategies
  PART I  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: systemd — THE MODERN INIT SYSTEM

## 🎬 Remember PID 1 From Chapter 1?

Back in Chapter 1, we learned that after the kernel boots, it starts **PID 1** — the very first process, the "mother of all processes." On virtually every modern Linux distribution, that process is **systemd**.

```
THE EVOLUTION OF INIT SYSTEMS
═══════════════════════════════════════════════════════════════════
  SysVinit (old)              →   systemd (modern, used almost everywhere now)
  ────────────────                ──────────────────────────────────────────
  Sequential, slow boot           Parallel startup — MUCH faster boot
  Shell scripts in /etc/init.d    Declarative unit FILES (.service, .timer...)
  No dependency management        Built-in dependency resolution
  Manual log file management       Centralized logging via journald
  No built-in scheduling           Built-in timers (replaces/extends cron)
═══════════════════════════════════════════════════════════════════
```

## 🧩 What Does systemd Actually Manage?

```
systemd's RESPONSIBILITIES
═══════════════════════════════════════════════════════════════
  1. SERVICES    → Start/stop/restart background daemons (nginx, sshd...)
  2. BOOT ORDER  → Decide what starts, in what order, in PARALLEL when safe
  3. LOGGING     → Collect ALL system/service logs via journald
  4. SCHEDULING  → Run jobs at specific times (timers)
  5. MOUNTING    → Mount filesystems automatically
  6. SOCKETS     → Socket-based activation (start a service ON DEMAND)
  7. TARGETS     → Group units into "runlevels" (multi-user, graphical...)
═══════════════════════════════════════════════════════════════
```

```bash
ps -p 1                          # Confirm systemd is PID 1
systemctl --version                # Check your systemd version
systemd-analyze                     # How long did boot take? (Chapter 1 callback!)
```

---

# PART B: systemd UNITS DEEP DIVE

## 📦 What Is a "Unit"?

A **unit** is anything systemd manages — a service, a mount point, a timer, a device, or a group of other units. Each unit is defined by a configuration file.

| Unit Type | Extension  | Purpose                                       |
| --------- | ---------- | --------------------------------------------- |
| Service   | `.service` | A background process/daemon (most common!)    |
| Socket    | `.socket`  | A network/IPC socket for on-demand activation |
| Target    | `.target`  | A group of units (like an old "runlevel")     |
| Timer     | `.timer`   | A scheduled job (replaces/extends cron)       |
| Mount     | `.mount`   | A filesystem mount point                      |
| Path      | `.path`    | Triggers based on filesystem changes          |

```bash
ls /etc/systemd/system/             # Custom/locally-installed unit files
ls /usr/lib/systemd/system/          # Unit files installed by packages
ls /lib/systemd/system/               # Same as above on some distros

systemctl list-units                  # All ACTIVE units right now
systemctl list-units --type=service    # Just services
systemctl list-unit-files               # ALL unit files (active or not)
```

## 📄 Anatomy of a `.service` Unit File

```bash
cat /usr/lib/systemd/system/nginx.service
```

**Sample content:**

```ini
[Unit]
Description=A high performance web server
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s quit
PIDFile=/run/nginx.pid

[Install]
WantedBy=multi-user.target
```

```
SERVICE FILE STRUCTURE EXPLAINED
═══════════════════════════════════════════════════════════════════

  [Unit] section:
    Description=    → Human-readable name shown in logs/status
    After=           → Start AFTER this other unit (ordering, not strict dependency)
    Requires=        → HARD dependency — fail if this isn't running
    Wants=           → SOFT dependency — try to start it, but don't fail if it can't

  [Service] section:
    Type=             → simple (default), forking, oneshot, notify...
    ExecStart=        → The command to run when starting
    ExecStop=         → The command to run when stopping
    ExecReload=       → The command to run when reloading config
    Restart=          → on-failure, always, no... (auto-restart behavior!)
    User=             → Run the service as this specific user (not root!)

  [Install] section:
    WantedBy=          → Which TARGET should auto-start this on boot

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"What's the difference between `Requires=` and `Wants=` in a systemd unit?"_ **Answer:** `Requires=` creates a hard dependency — if the required unit fails to start, this unit ALSO fails. `Wants=` is a soft dependency — systemd tries to start the wanted unit too, but this unit will start regardless of whether the wanted one succeeds.

## 🎯 Targets — systemd's "Runlevels"

```
COMMON systemd TARGETS
═══════════════════════════════════════════════════════════════
  poweroff.target     → Shutting down
  rescue.target        → Single-user/maintenance mode
  multi-user.target    → Normal CLI boot (most servers!)
  graphical.target      → Multi-user + GUI/desktop environment
  reboot.target          → Restarting the system

  (Old SysVinit runlevel 3 ≈ multi-user.target)
  (Old SysVinit runlevel 5 ≈ graphical.target)
═══════════════════════════════════════════════════════════════
```

```bash
systemctl get-default                  # What target does this system boot into?
sudo systemctl set-default multi-user.target   # Boot to CLI only (no GUI) — common on servers!
sudo systemctl isolate multi-user.target          # Switch to a target RIGHT NOW (temporarily)
```

---

# PART C: systemctl MASTERY

## 🎛️ Controlling Services

```bash
sudo systemctl start nginx              # Start a service NOW
sudo systemctl stop nginx                # Stop a service NOW
sudo systemctl restart nginx              # Stop then start
sudo systemctl reload nginx               # Reload config WITHOUT dropping connections
sudo systemctl reload-or-restart nginx     # Reload if supported, else restart

systemctl status nginx                     # Is it running? Recent logs? PID?
systemctl is-active nginx                   # Just "active" or "inactive"
systemctl is-enabled nginx                   # Will it start automatically at boot?
systemctl is-failed nginx                     # Did it fail?
```

### Understanding `systemctl status` Output

```
systemctl status nginx OUTPUT EXPLAINED
═══════════════════════════════════════════════════════════════════

  ● nginx.service - A high performance web server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled)
     Active: active (running) since Thu 2026-06-18 09:00:12 UTC; 2h ago
   Main PID: 1234 (nginx)
      Tasks: 3 (limit: 4683)
     Memory: 4.2M
        CPU: 142ms
     CGroup: /system.slice/nginx.service
             ├─1234 nginx: master process /usr/sbin/nginx
             ├─1235 nginx: worker process
             └─1236 nginx: worker process

  ● (green) = running fine     ● (red) = failed     ○ (white) = inactive

  Loaded: ... enabled            → will AUTO-START on boot
  Active: active (running)        → currently RUNNING right now
  Main PID                          → the process ID to know for ps/kill/etc.

═══════════════════════════════════════════════════════════════════
```

## 🔌 Enabling Services (Autostart at Boot)

```
start/stop vs enable/disable — THE KEY DISTINCTION
═══════════════════════════════════════════════════════════════════
  start / stop          → Affects the service RIGHT NOW (this boot session)
  enable / disable       → Affects whether it AUTO-STARTS on FUTURE boots

  These are INDEPENDENT! A service can be:
  • started + enabled    → running now, AND will start on reboot
  • started + disabled    → running now, but WON'T start on reboot
  • stopped + enabled      → not running now, but WILL start on reboot
  • stopped + disabled      → not running, and won't auto-start

  💡 Best practice when deploying a new service:
     sudo systemctl enable --now nginx
     (This does BOTH: enable for future boots AND start it now!)
═══════════════════════════════════════════════════════════════════
```

```bash
sudo systemctl enable nginx              # Auto-start on future boots
sudo systemctl disable nginx              # Don't auto-start anymore
sudo systemctl enable --now nginx          # Enable AND start in one command
sudo systemctl disable --now nginx          # Disable AND stop in one command

sudo systemctl mask nginx                   # COMPLETELY block it from starting
                                              # (even manual "start" will fail!)
sudo systemctl unmask nginx                  # Remove the mask
```

> **🎓 Interview Question:** _"What's the difference between `systemctl disable` and `systemctl mask`?"_ **Answer:** `disable` just removes the symlink that triggers auto-start at boot — you can still manually `start` it anytime. `mask` creates a symlink to `/dev/null`, completely PREVENTING the service from being started at all, even manually, until unmasked — useful for actively blocking a problematic or insecure service.

```bash
systemctl list-dependencies nginx           # What does nginx depend on?
systemctl list-dependencies nginx --reverse  # What DEPENDS ON nginx?

sudo systemctl daemon-reload                  # Reload unit files after editing them!
                                                # (ALWAYS run this after changing a .service file)
```

---

# PART D: CREATING YOUR OWN systemd SERVICE

## 🛠️ Real-World Example: Running a Custom Script as a Service

```bash
# Step 1: Write the actual script
cat > /usr/local/bin/myapp.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date): MyApp is running" >> /var/log/myapp.log
    sleep 10
done
EOF
sudo chmod +x /usr/local/bin/myapp.sh

# Step 2: Create the unit file
sudo tee /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Custom Background Application
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myapp.sh
Restart=on-failure
RestartSec=5
User=ahmed

[Install]
WantedBy=multi-user.target
EOF

# Step 3: Reload, enable, and start
sudo systemctl daemon-reload
sudo systemctl enable --now myapp.service

# Step 4: Verify
systemctl status myapp.service
journalctl -u myapp.service -f          # Watch its logs live!
```

```
WHY Restart=on-failure MATTERS
═══════════════════════════════════════════════════════════════
  Without it:                        With it:
  ─────────────                      ──────────
  If your app crashes, it STAYS      systemd automatically RESTARTS it
  dead until someone manually         after RestartSec seconds — your
  notices and restarts it             service self-heals!

  This is HOW production services stay up 24/7 without
  a human watching them every minute.
═══════════════════════════════════════════════════════════════
```

---

# PART E: LOGGING WITH journald — journalctl MASTERY

## 📓 journald — The Centralized, Modern Logging System

Every message any systemd-managed service prints goes into a single, structured, searchable database called the **journal**.

```bash
journalctl                          # View ALL logs (oldest first)
journalctl -r                        # REVERSE order (newest first — often more useful!)
journalctl -f                         # FOLLOW live, like tail -f
journalctl -n 50                       # Last 50 lines only
journalctl -e                           # Jump to the END

# FILTER by service/unit
journalctl -u nginx                      # Logs for ONE specific service
journalctl -u nginx -f                    # Follow that service's logs live

# FILTER by time
journalctl --since "1 hour ago"
journalctl --since "2026-06-18 09:00:00"
journalctl --since today
journalctl --since yesterday --until today

# FILTER by boot
journalctl -b                              # Logs from CURRENT boot only
journalctl -b -1                            # Logs from PREVIOUS boot
journalctl --list-boots                      # See all recorded boots

# FILTER by priority/severity
journalctl -p err                            # Only ERROR level and above
journalctl -p warning                         # Only WARNING level and above

# COMBINE filters
journalctl -u nginx --since today -p err
```

```
JOURNALCTL PRIORITY LEVELS
═══════════════════════════════════════════════════════════════
  0 emerg     → System is unusable
  1 alert      → Action must be taken immediately
  2 crit        → Critical condition
  3 err          → Error condition
  4 warning       → Warning condition
  5 notice         → Normal but significant
  6 info            → Informational
  7 debug            → Debug-level messages

  journalctl -p err   → shows levels 0-3 (err AND MORE SEVERE)
═══════════════════════════════════════════════════════════════
```

## 💾 Making journald Logs Persistent

```
journald'S DEFAULT BEHAVIOR
═══════════════════════════════════════════════════════════════════
  By DEFAULT on many distros, journald logs are stored in
  VOLATILE memory (/run/log/journal) and LOST ON REBOOT!

  To make them PERSISTENT (survive reboots — important for
  real servers!):
═══════════════════════════════════════════════════════════════════
```

```bash
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald

# Or edit the config directly:
sudo nano /etc/systemd/journald.conf
# Set: Storage=persistent

# Control how much disk space the journal can use
journalctl --disk-usage                       # See current usage
sudo journalctl --vacuum-size=500M             # Shrink to 500MB max
sudo journalctl --vacuum-time=2weeks            # Delete anything older than 2 weeks
```

> **🎓 Interview Question:** _"A server rebooted overnight after a crash, and now `journalctl -b -1` shows nothing useful. What's likely misconfigured?"_ **Answer:** journald is probably using volatile (memory-only) storage instead of persistent disk storage. The fix is setting `Storage=persistent` in `/etc/systemd/journald.conf` and ensuring `/var/log/journal` exists, so logs survive across reboots.

---

# PART F: TRADITIONAL LOGGING — rsyslog & logrotate

## 📜 rsyslog — The Classic Syslog Daemon

Even with journald, many systems still use (or also use) **rsyslog** to write traditional plain-text logs to `/var/log/`.

```bash
cat /etc/rsyslog.conf                 # Main configuration
ls /etc/rsyslog.d/                     # Additional config snippets

tail -f /var/log/syslog                # Live general system log (Debian/Ubuntu)
tail -f /var/log/messages               # Live general system log (RHEL/Fedora)
tail -f /var/log/auth.log                # Live authentication/sudo log (Debian/Ubuntu)
tail -f /var/log/secure                   # Live authentication log (RHEL/Fedora)

sudo systemctl status rsyslog              # Is it running?
```

```
journald vs rsyslog
═══════════════════════════════════════════════════════════════════
  journald                           rsyslog
  ──────────                         ─────────
  Binary, structured, indexed        Plain TEXT files
  Built into systemd                  Separate, traditional daemon
  Query with journalctl                Query with grep/cat/tail
  Can FORWARD to rsyslog too           Can receive FROM journald

  Many modern systems run BOTH —
  journald for rich querying, rsyslog
  for simple, portable plain-text logs
  that other tools can easily parse
═══════════════════════════════════════════════════════════════════
```

## 🔄 logrotate — Preventing Logs From Eating Your Disk

Remember Chapter 2's lesson about `/var/log` filling up disks? **logrotate** is the tool that automatically prevents that.

```bash
cat /etc/logrotate.conf                  # Main config
ls /etc/logrotate.d/                      # Per-application configs (nginx, apache, etc.)
cat /etc/logrotate.d/nginx                  # Example: how nginx's logs get rotated

sudo logrotate -f /etc/logrotate.conf       # FORCE a rotation right now (testing)
sudo logrotate -d /etc/logrotate.conf        # DRY RUN — show what WOULD happen
```

**Sample logrotate config:**

```
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 myapp myapp
}
```

```
READING A logrotate CONFIG
═══════════════════════════════════════════════════════════════
  daily            → Rotate logs once per day
  rotate 7         → Keep 7 old copies, then delete the oldest
  compress         → Gzip old logs to save space
  delaycompress    → Don't compress the MOST RECENT old log
                      (some apps still want to write briefly after rotation)
  missingok        → Don't error if the log file doesn't exist
  notifempty       → Don't rotate if the log file is EMPTY
  create 0640 ...  → Create a new empty log file with these permissions/owner
═══════════════════════════════════════════════════════════════
```

---

# PART G: SCHEDULING — cron, at, AND systemd TIMERS

## ⏰ cron — The Classic Task Scheduler

```bash
crontab -e                       # Edit YOUR personal crontab
crontab -l                        # List YOUR current cron jobs
crontab -r                         # REMOVE all your cron jobs (be careful!)
sudo crontab -e -u ahmed             # Edit ANOTHER user's crontab (as root)

sudo cat /etc/crontab                 # System-wide crontab
ls /etc/cron.d/                        # System-wide job snippets
ls /etc/cron.daily/ /etc/cron.weekly/   # Pre-made daily/weekly job folders
```

## 🕐 Crontab Syntax — The 5-Field Time Format

```
CRONTAB SYNTAX DIAGRAM
═══════════════════════════════════════════════════════════════════

  *     *     *     *     *     command_to_run
  │     │     │     │     │
  │     │     │     │     └─ Day of week  (0-7, 0 AND 7 = Sunday)
  │     │     │     └─────── Month         (1-12)
  │     │     └───────────── Day of month  (1-31)
  │     └─────────────────── Hour           (0-23)
  └───────────────────────── Minute          (0-59)

  "*" means "every" / "any value" in that field

═══════════════════════════════════════════════════════════════════
```

### Crontab Examples

```bash
# Run every minute
* * * * * /home/ahmed/scripts/check.sh

# Run every day at 2:30 AM
30 2 * * * /home/ahmed/scripts/backup.sh

# Run every Monday at 9:00 AM
0 9 * * 1 /home/ahmed/scripts/weekly_report.sh

# Run every 15 minutes
*/15 * * * * /home/ahmed/scripts/poll.sh

# Run on the 1st of every month at midnight
0 0 1 * * /home/ahmed/scripts/monthly_cleanup.sh

# Run every weekday (Mon-Fri) at 6 PM
0 18 * * 1-5 /home/ahmed/scripts/end_of_day.sh

# Run at 3 AM, every 2 hours
0 */2 * * * /home/ahmed/scripts/check_health.sh

# Special shortcuts (some cron implementations support these!)
@reboot /home/ahmed/scripts/startup.sh        # Run once at boot
@daily /home/ahmed/scripts/daily_job.sh         # Same as "0 0 * * *"
@hourly /home/ahmed/scripts/hourly_job.sh        # Same as "0 * * * *"
```

```
CRON TIME PATTERN CHEAT SHEET
═══════════════════════════════════════════════════════════════
  *           any value
  5            exactly 5
  1-5          range: 1 through 5
  1,3,5         list: 1 AND 3 AND 5
  */5            every 5 units (e.g. */5 in minutes = every 5 minutes)
  1-10/2          range with step: 1,3,5,7,9
═══════════════════════════════════════════════════════════════
```

> **⚠️ CRITICAL WARNING:** Cron jobs run with a MINIMAL environment — no `$PATH` from your interactive shell, no aliases, often a different working directory! Always use FULL paths to commands and scripts inside cron jobs (`/usr/bin/python3` not just `python3`), and redirect output to a log file for debugging: `* * * * * /home/ahmed/script.sh >> /home/ahmed/script.log 2>&1`.

```
WHY CRON JOBS "WORK MANUALLY BUT FAIL IN CRON" — THE #1 BEGINNER MYSTERY
═══════════════════════════════════════════════════════════════════
  You run:        ./script.sh    → Works perfectly!
  Cron runs it:    ./script.sh    → FAILS silently!

  WHY: Your interactive shell loads ~/.bashrc, sets up PATH,
  aliases, etc. Cron's environment is BARE — almost none of
  that exists. The script's "python3" or "node" command might
  not even be FOUND because PATH is different/minimal.

  FIX: Use absolute paths everywhere, or explicitly source
  the environment at the top of your script.
═══════════════════════════════════════════════════════════════════
```

## ⏱️ `at` — Run a Job ONE Time in the Future

```bash
sudo apt install at              # Install if needed
echo "tar -czf backup.tar.gz /home/ahmed" | at 23:00      # Run once tonight at 11 PM
at now + 30 minutes               # Schedule something 30 min from now (interactive)
atq                                 # List pending "at" jobs
atrm 3                              # Remove job #3 from the queue
```

```
cron vs at
═══════════════════════════════════════════════════════════════
  cron   → RECURRING jobs (every day, every hour, etc.)
  at     → ONE-TIME jobs (just once, at a specific future moment)
═══════════════════════════════════════════════════════════════
```

## ⏲️ systemd Timers — The Modern Alternative to cron

```bash
# A timer ALWAYS pairs with a matching .service unit

sudo tee /etc/systemd/system/backup.service << 'EOF'
[Unit]
Description=Daily Backup Job

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
EOF

sudo tee /etc/systemd/system/backup.timer << 'EOF'
[Unit]
Description=Run backup.service daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer

systemctl list-timers                       # See ALL active timers and next run time
systemctl status backup.timer                 # Check this specific timer
journalctl -u backup.service                    # See the job's actual output/logs!
```

```
cron vs systemd TIMERS
═══════════════════════════════════════════════════════════════════
  cron                                systemd timers
  ──────                              ────────────────
  Simple, universal, well-known       More powerful: dependencies,
                                        resource limits, better logging
  Logs go wherever YOU redirect        Logs automatically captured
   them manually                       by journald — query with journalctl!
  No built-in "catch up" if the        Persistent=true CATCHES UP missed
   system was OFF at run time           runs if the system was off!
  Quick for simple one-liners          More setup, but more robust —
                                        preferred in modern production systems
═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"When would you choose a systemd timer over a traditional cron job?"_ **Answer:** systemd timers integrate with journald for automatic logging, support `Persistent=true` to catch up on missed runs after downtime, can express complex dependencies on other units, and offer finer resource control (CPU/memory limits via systemd's cgroup integration) — making them preferable for production-grade scheduled tasks, while cron remains simpler for quick personal scripts.

---

# PART H: BACKUP & RECOVERY STRATEGIES

## 💾 The 3-2-1 Backup Rule

```
THE 3-2-1 BACKUP RULE
═══════════════════════════════════════════════════════════════
  3   → Keep at least 3 COPIES of your data
  2   → Store them on 2 DIFFERENT types of media
  1   → Keep at least 1 copy OFF-SITE (different physical location)

  Example: Your live server data (copy 1) + a local backup
  disk (copy 2) + a cloud backup like S3/Backblaze (copy 3, off-site)
═══════════════════════════════════════════════════════════════
```

## 📦 `tar` — The Classic Archiving Tool

```bash
tar -czf backup.tar.gz /home/ahmed/Documents     # CREATE a compressed archive
#     │││
#     ││└─ f = filename follows
#     │└── z = gzip compression
#     └─── c = create

tar -xzf backup.tar.gz                              # EXTRACT it
tar -xzf backup.tar.gz -C /restore/location/         # Extract to a SPECIFIC location
tar -tzf backup.tar.gz                                # LIST contents WITHOUT extracting
tar -czf backup.tar.gz --exclude='*.log' /home/ahmed   # Exclude certain files

# Incremental backups (only changed files since last backup!)
tar -czf full_backup.tar.gz -g snapshot.snar /home/ahmed
tar -czf incremental.tar.gz -g snapshot.snar /home/ahmed   # Only NEW/CHANGED files
```

## 🔄 `rsync` for Backups (Revisited from Chapter 8)

```bash
# Mirror a directory to a backup location (only copies CHANGES — fast!)
rsync -avz --delete /home/ahmed/ /mnt/backup_drive/ahmed_backup/

# Backup to a remote server over SSH
rsync -avz -e ssh /home/ahmed/ user@backupserver:/backups/ahmed/

# Incremental backups using --link-dest (hard links = space-efficient snapshots!)
rsync -av --link-dest=/backups/2026-06-17 /home/ahmed/ /backups/2026-06-18/
```

## 💽 `dd` — Low-Level Disk/Image Cloning

```bash
# ⚠️ EXTREMELY POWERFUL AND DANGEROUS — double/triple-check device names!

# Clone an ENTIRE disk to an image file
sudo dd if=/dev/sda of=/mnt/backup/disk_image.img bs=4M status=progress

# Restore that image back to a disk
sudo dd if=/mnt/backup/disk_image.img of=/dev/sda bs=4M status=progress

# Create a bootable USB from an ISO
sudo dd if=ubuntu.iso of=/dev/sdb bs=4M status=progress
```

> **⚠️ CRITICAL WARNING:** `dd` stands for "disk destroyer" in sysadmin folklore for good reason — `if=` is INPUT, `of=` is OUTPUT. Swap them by mistake, or target the wrong device, and you will IRREVERSIBLY ERASE the wrong disk in seconds with ZERO confirmation prompt. ALWAYS triple-check device names with `lsblk` before running any `dd` command.

## 🚑 Basic Recovery Concepts

```bash
# Boot into RESCUE mode if the system won't start normally
# (typically selected from the GRUB menu, or via systemctl)
sudo systemctl rescue              # Switch to rescue mode from a working system

# Check filesystem integrity (usually done from a LIVE USB if root is broken)
sudo fsck /dev/sda1                  # NEVER run fsck on a MOUNTED filesystem!

# Restore from a tar backup
tar -xzf backup.tar.gz -C /

# Restore from an rsync backup
rsync -avz /mnt/backup_drive/ahmed_backup/ /home/ahmed/

# Check what's actually consuming space before a "disk full" disaster
du -sh /var/* 2>/dev/null | sort -rh | head -10
```

---

# PART I: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 9 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ systemd:
     PID 1, manages services/boot/logging/scheduling
     Units: .service, .timer, .target, .socket, .mount

  ✅ systemctl:
     start/stop/restart/reload = NOW   enable/disable = at FUTURE boot
     enable --now = both at once   mask = block completely
     ALWAYS daemon-reload after editing unit files!

  ✅ Custom Services:
     [Unit]/[Service]/[Install] sections   Restart=on-failure for self-healing

  ✅ journald:
     journalctl -u service -f (live)   --since/--until (time filters)
     -p err (severity filter)   Storage=persistent for surviving reboots

  ✅ rsyslog/logrotate:
     Plain-text logs in /var/log   logrotate prevents disk-filling logs
     (Chapter 2 callback: this is WHY /var/log doesn't grow forever!)

  ✅ Scheduling:
     cron = recurring (5-field time syntax)   at = one-time future job
     systemd timers = modern alternative with logging + catch-up support
     ALWAYS use absolute paths in cron — minimal environment!

  ✅ Backup & Recovery:
     3-2-1 rule: 3 copies, 2 media types, 1 off-site
     tar (archives)   rsync (efficient sync)   dd (low-level disk clone — DANGEROUS)

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 9 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

systemctl                       journalctl                      cron/timers
──────────────────────         ─────────────────────         ───────────────────
systemctl start/stop x  Now     journalctl -u x        Unit logs   crontab -e       Edit jobs
systemctl enable/disable x Boot journalctl -f            Live tail  crontab -l       List jobs
systemctl enable --now x Both   journalctl --since today Time filt  */5 * * * *      Every 5min
systemctl status x      Info    journalctl -p err        Severity   0 2 * * * cmd    Daily 2AM
systemctl mask x        Block   journalctl -b -1         Prev boot  at now+1hour     One-time
systemctl daemon-reload Reload  journalctl --vacuum-time=2weeks     systemctl list-timers  All timers

BACKUP & RECOVERY               LOG ROTATION                    UNIT FILE SECTIONS
──────────────────────         ─────────────────────         ───────────────────
tar -czf b.tar.gz dir   Create  cat /etc/logrotate.conf  Config [Unit]      Description, After
tar -xzf b.tar.gz       Extract logrotate -f conf  Force rotate  [Service]   ExecStart, Restart
rsync -avz src dest     Sync    logrotate -d conf  Dry run        [Install]   WantedBy
dd if=x of=y bs=4M      Clone   ls /etc/logrotate.d/  Per-app

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 9 Interview Questions

| #   | Question                                                      | Key Answer Points                                                                                                                              |
| --- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | What replaced SysVinit and why?                               | systemd — offers parallel boot, dependency management, centralized logging, and built-in scheduling                                            |
| 2   | Difference between `systemctl start` and `systemctl enable`?  | start affects NOW; enable affects whether it auto-starts on FUTURE boots — independent settings                                                |
| 3   | What does `systemctl mask` do that `disable` doesn't?         | mask completely prevents the unit from starting even manually (symlinks to /dev/null); disable just removes auto-start at boot                 |
| 4   | What must you run after editing a .service file?              | `sudo systemctl daemon-reload`, otherwise systemd uses its cached/old version                                                                  |
| 5   | How do you make a service auto-restart if it crashes?         | Set `Restart=on-failure` (and optionally `RestartSec=`) in the `[Service]` section                                                             |
| 6   | Why might `journalctl -b -1` show nothing after a crash?      | journald may be using volatile (memory-only) storage instead of persistent disk storage                                                        |
| 7   | Why does a script that works manually fail when run via cron? | Cron runs with a minimal environment (different/missing PATH, no aliases) — always use absolute paths in cron jobs                             |
| 8   | What's the difference between cron and `at`?                  | cron runs RECURRING jobs on a schedule; at runs a job exactly ONCE at a specified future time                                                  |
| 9   | Why would you choose a systemd timer over cron?               | Built-in logging via journald, `Persistent=true` to catch up on missed runs, dependency/resource control                                       |
| 10  | What does `logrotate`'s `delaycompress` option do?            | Delays compressing the most recently rotated log by one cycle, since some apps briefly continue writing to it after rotation                   |
| 11  | Explain the 3-2-1 backup rule.                                | 3 copies of data, on 2 different media types, with 1 copy stored off-site                                                                      |
| 12  | Why is `dd` considered dangerous?                             | It overwrites raw disk data with zero confirmation; swapping `if=`/`of=` or targeting the wrong device can irreversibly destroy data instantly |

## 🔬 Practical Lab: Chapter 9 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: Exploring systemd Units
# ──────────────────────────────────────────────────────────────────
systemctl list-units --type=service | head -20
systemctl status sshd 2>/dev/null || systemctl status ssh
systemctl is-enabled cron 2>/dev/null || systemctl is-enabled crond
systemctl get-default
systemd-analyze blame | head -10

# ──────────────────────────────────────────────────────────────────
# LAB 2: journalctl Investigation
# ──────────────────────────────────────────────────────────────────
journalctl -n 20
journalctl --since "1 hour ago" | tail -20
journalctl -p err --since today
journalctl --disk-usage
journalctl --list-boots

# ──────────────────────────────────────────────────────────────────
# LAB 3: Build and Run a Custom systemd Service
# ──────────────────────────────────────────────────────────────────
cat > /tmp/heartbeat.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date): heartbeat" >> /tmp/heartbeat.log
    sleep 5
done
EOF
chmod +x /tmp/heartbeat.sh

sudo tee /etc/systemd/system/heartbeat.service << 'EOF'
[Unit]
Description=Heartbeat Test Service

[Service]
Type=simple
ExecStart=/tmp/heartbeat.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now heartbeat.service
sleep 12
systemctl status heartbeat.service
journalctl -u heartbeat.service -n 10
tail -5 /tmp/heartbeat.log

# Clean up after the lab!
sudo systemctl disable --now heartbeat.service
sudo rm /etc/systemd/system/heartbeat.service
sudo systemctl daemon-reload

# ──────────────────────────────────────────────────────────────────
# LAB 4: Crontab Practice
# ──────────────────────────────────────────────────────────────────
crontab -l
echo '* * * * * echo "$(date): cron test" >> /tmp/cron_test.log' | crontab -
sleep 65
cat /tmp/cron_test.log
crontab -r          # Clean up: remove the test job

# ──────────────────────────────────────────────────────────────────
# LAB 5: Backup Practice
# ──────────────────────────────────────────────────────────────────
mkdir -p ~/lab9_data
echo "Important data" > ~/lab9_data/file1.txt
echo "More data" > ~/lab9_data/file2.txt

tar -czf ~/lab9_backup.tar.gz -C ~ lab9_data
tar -tzf ~/lab9_backup.tar.gz                  # List contents
mkdir -p ~/lab9_restore
tar -xzf ~/lab9_backup.tar.gz -C ~/lab9_restore
diff -r ~/lab9_data ~/lab9_restore/lab9_data && echo "✅ Backup verified identical!"
```

## 🧠 Mini Project: Automated Backup with systemd Timer

```bash
cat > /tmp/setup_auto_backup.sh << 'EOF'
#!/bin/bash
set -euo pipefail

BACKUP_SCRIPT="/usr/local/bin/auto_backup.sh"
SOURCE_DIR="$HOME/Documents"
BACKUP_DEST="$HOME/backups"

# Step 1: Create the backup script
sudo tee "$BACKUP_SCRIPT" > /dev/null << SCRIPT
#!/bin/bash
mkdir -p "$BACKUP_DEST"
DATE=\$(date +%Y-%m-%d_%H-%M-%S)
tar -czf "$BACKUP_DEST/backup_\${DATE}.tar.gz" "$SOURCE_DIR"
find "$BACKUP_DEST" -name "backup_*.tar.gz" -mtime +7 -delete
echo "\$(date): Backup completed: backup_\${DATE}.tar.gz"
SCRIPT
sudo chmod +x "$BACKUP_SCRIPT"

# Step 2: Create the systemd service
sudo tee /etc/systemd/system/autobackup.service > /dev/null << EOF2
[Unit]
Description=Automated Documents Backup

[Service]
Type=oneshot
ExecStart=$BACKUP_SCRIPT
EOF2

# Step 3: Create the systemd timer (daily at 2 AM, catches up if missed!)
sudo tee /etc/systemd/system/autobackup.timer > /dev/null << EOF3
[Unit]
Description=Run autobackup.service daily

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF3

# Step 4: Enable everything
sudo systemctl daemon-reload
sudo systemctl enable --now autobackup.timer

echo "✅ Automated backup configured!"
echo "Check status with: systemctl list-timers"
echo "Run manually anytime with: sudo systemctl start autobackup.service"
EOF

chmod +x /tmp/setup_auto_backup.sh
# Run it: bash /tmp/setup_auto_backup.sh
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
  ⬜ Chapter 10: Linux Security (PAM, SELinux, encryption)
  ⬜ Chapter 11: Containers (Docker, namespaces, cgroups)
  ⬜ Chapter 12: Linux Kernel Development

═══════════════════════════════════════════════════════════════════
  YOU ARE HERE: ✅✅✅✅✅✅✅✅✅ — Nine chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

Next: [Chapter 10 — Linux Security: PAM, SELinux, AppArmor, Encryption, and Hardening](/chapter-10.md)

---
