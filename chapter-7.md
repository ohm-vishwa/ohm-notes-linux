# CHAPTER 7: PROCESS MANAGEMENT

### _ps, top, Signals, and Job Control_

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 7
═══════════════════════════════════════════════════════════════
  PART A  →  What Is a Process? (Deep Dive)
  PART B  →  Process States & Lifecycle
  PART C  →  Viewing Processes — ps, top, htop
  PART D  →  Process Hierarchy — Parents, Children, fork/exec
  PART E  →  Signals — Communicating With Processes
  PART F  →  Job Control — fg, bg, nohup, disown
  PART G  →  Process Priority — nice and renice
  PART H  →  Advanced Monitoring Tools
  PART I  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: WHAT IS A PROCESS? (DEEP DIVE)

## 🏃 Process — A Program in Action

A **program** is a file sitting on disk doing nothing (like `/usr/bin/firefox`). A **process** is that program LOADED INTO MEMORY and ACTIVELY RUNNING, with its own resources.

```
PROGRAM vs PROCESS
═══════════════════════════════════════════════════════════════════
  PROGRAM                            PROCESS
  ─────────                          ─────────
  Static file on disk                Living, running instance
  /usr/bin/firefox                   Firefox actually open right now,
                                       using RAM, CPU time, file handles
  ONE program file                   Can have MULTIPLE processes
                                       (open Firefox twice = 2 PIDs running
                                        the SAME program)
═══════════════════════════════════════════════════════════════════
```

## 🎒 What Does Every Process Carry With It?

```
ANATOMY OF A PROCESS
═══════════════════════════════════════════════════════════════════

  ┌─────────────────────────────────────────────────────────┐
  │  PROCESS (PID 4521)                                     │
  │                                                         │
  │  PID  → Process ID (unique number)                      │
  │  PPID → Parent Process ID (who created it)              │
  │  UID  → Which user owns this process                    │
  │  STATE → Running, Sleeping, Stopped, Zombie...          │
  │  PRIORITY/NICE → How much CPU time it deserves          │
  │                                                         │
  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
  │  │ MEMORY SPACE│  │ FILE        │  │  CPU REGISTERS  │  │
  │  │ (its own,   │  │ DESCRIPTORS │  │  & PROGRAM      │  │
  │  │  isolated!) │  │ (open files)│  │  COUNTER        │  │
  │  └─────────────┘  └─────────────┘  └─────────────────┘  │
  └─────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════
```

```bash
echo $$                       # Your current shell's PID
ps -p $$                       # Show details about it
cat /proc/$$/status | head -5  # Even more details, straight from the kernel
```

## 🧬 fork() and exec() — How New Processes Are Born

```
THE fork() + exec() PATTERN
═══════════════════════════════════════════════════════════════════

  Step 1: fork()
  ───────────────
  Parent process CLONES itself completely
  (same memory, same code, same everything — just a new PID)

       Parent (PID 100)
            │
            │ fork()
            ▼
       Child (PID 101)  ← exact copy of parent, but a NEW process

  Step 2: exec()
  ───────────────
  The CHILD replaces its own memory with a DIFFERENT program

       Child (PID 101, was a copy of bash)
            │
            │ exec("/usr/bin/firefox")
            ▼
       Child (PID 101, is now ACTUALLY running firefox!)

  This TWO-STEP dance is how your shell launches every command
  you type — fork a copy of itself, then exec the real program
  inside that copy.

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"How does a shell create a new process to run a command like `ls`?"_ **Answer:** The shell calls `fork()` to create a child process (an exact copy of itself), then the child calls `exec()` to replace its own memory image with the `ls` program. The parent shell waits (or doesn't, for background jobs) for the child to finish.

---

# PART B: PROCESS STATES & LIFECYCLE

## 🔄 The Process State Machine

```
PROCESS STATE DIAGRAM
═══════════════════════════════════════════════════════════════════

                    ┌──────────────┐
          created   │              │   gets CPU time
        ───────────►│  RUNNABLE/   │◄───────────────┐
                    │  READY (R)   │                │
                    │              │                │
                    └──────┬───────┘                │
                           │ scheduled              │
                           ▼                        │
                    ┌──────────────┐                │
                    │   RUNNING    │                │
                    │   (on CPU)   │────────────────┘
                    └──────┬───────┘   CPU time slice ends
                           │
                needs I/O  │  finishes
                (disk/net) │  normally
                           ▼
                    ┌──────────────┐         ┌──────────────┐
                    │  SLEEPING/   │ I/O done│   TERMINATED │
                    │  WAITING (S) │────────►│   (exits)    │
                    └──────────────┘         └──────┬───────┘
                                                      │ parent hasn't
                                                      │ read exit status
                                                      ▼
                                               ┌──────────────┐
                                               │   ZOMBIE (Z) │
                                               └──────────────┘

═══════════════════════════════════════════════════════════════════
```

## 📋 Process State Codes (seen in `ps`/`top`)

| Code | State                 | Meaning                                                             |
| ---- | --------------------- | ------------------------------------------------------------------- |
| `R`  | Running               | Actively executing on the CPU (or ready to)                         |
| `S`  | Sleeping              | Waiting for an event (like disk I/O) — interruptible                |
| `D`  | Uninterruptible Sleep | Waiting on I/O that cannot be interrupted (rare, usually disk)      |
| `T`  | Stopped               | Paused, usually by a signal (Ctrl+Z)                                |
| `Z`  | Zombie                | Finished executing, but parent hasn't collected its exit status yet |
| `I`  | Idle                  | Kernel thread sleeping with nothing to do                           |

## 👻 What Is a Zombie Process?

```
ZOMBIE PROCESS EXPLAINED
═══════════════════════════════════════════════════════════════════

  Child process finishes running and "dies"
       │
       ▼
  Its exit status sits in a small "obituary slot" in the
  process table, WAITING for the parent to read it (via wait())
       │
       ▼
  If parent NEVER reads it → child becomes a ZOMBIE
  (technically dead, but still occupying an entry in the
   process table until cleaned up)

  Zombies use almost ZERO resources (just a process table
  slot) and CANNOT be killed with kill -9 (they're already dead!)

  Fix: kill the PARENT process, which causes the zombie's
  PPID to become 1 (systemd/init), which properly "reaps" it.

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Can you kill a zombie process with `kill -9`?"_ **Answer:** No — a zombie is already dead; it has no running code left to signal. You can only remove it by getting its PARENT to call `wait()` on it (cleaning it up), often by restarting or killing the parent process itself.

---

# PART C: VIEWING PROCESSES — ps, top, htop

## 📋 `ps` — Process Snapshot

**Syntax:** `ps [OPTIONS]`

```bash
ps                          # Show YOUR processes in THIS terminal only
ps aux                       # Show ALL processes, all users, detailed (most common!)
ps -ef                       # Same idea, different format (System V style)
ps aux | grep firefox         # Find a specific process
ps -u ahmed                  # Show only processes owned by user ahmed
ps --forest                  # Show process TREE (parent-child relationships)
ps aux --sort=-%cpu          # Sort by CPU usage (highest first)
ps aux --sort=-%mem          # Sort by memory usage (highest first)
ps -o pid,ppid,cmd,%cpu,%mem # Custom columns
```

### Understanding `ps aux` Output

```
ps aux COLUMN BREAKDOWN
═══════════════════════════════════════════════════════════════════

  USER   PID  %CPU  %MEM   VSZ    RSS   TTY   STAT  START  TIME  COMMAND
  ahmed  4521  2.3   1.5  812400 124032  pts/0  S     10:23  0:05  firefox

  USER     → who owns this process
  PID      → unique process ID
  %CPU     → percentage of CPU currently being used
  %MEM     → percentage of RAM currently being used
  VSZ      → Virtual memory size (total addressable, includes unused)
  RSS      → Resident Set Size (ACTUAL physical RAM currently used)
  TTY      → which terminal it's attached to (? = none, e.g. background daemon)
  STAT     → process state (R, S, Z, T... see Part B)
  START    → when the process started
  TIME     → total CPU TIME consumed (not wall-clock time!)
  COMMAND  → the command that launched it

═══════════════════════════════════════════════════════════════════
```

> **🎓 Common Mistake:** Confusing `TIME` with `START`. `START` is the WALL-CLOCK time the process began; `TIME` is the cumulative CPU time it has actually USED — a process running for 3 hours but mostly idle might show `TIME` of just `0:02`.

## 📊 `top` — Live, Real-Time Process Monitor

```bash
top                  # Launch interactive live monitor

# Inside top, useful keypresses:
#   q          → quit
#   k          → kill a process (will prompt for PID)
#   r          → renice a process (change priority)
#   M          → sort by memory usage
#   P          → sort by CPU usage (default)
#   1          → toggle showing each CPU core separately
#   u          → filter by username
#   c          → toggle full command path display

top -u ahmed          # Show only ahmed's processes
top -n 1               # Run ONE iteration then exit (good for scripts!)
top -b -n 1 > snapshot.txt   # -b = batch mode (no interactivity), save to file
```

### Understanding `top`'s Header

```
top HEADER BREAKDOWN
═══════════════════════════════════════════════════════════════════

  top - 14:32:01 up 3 days,  4:12,  2 users,  load average: 0.45, 0.38, 0.31
  Tasks: 215 total,   1 running, 213 sleeping,   0 stopped,   1 zombie
  %Cpu(s):  5.2 us,  2.1 sy,  0.0 ni, 92.0 id,  0.5 wa,  0.0 hi,  0.2 si
  MiB Mem :  16039.1 total,   4521.3 free,   6234.5 used,   5283.3 buff/cache

  load average: 0.45, 0.38, 0.31
       │            │     │
       │            │     └─ Average load over last 15 minutes
       │            └─ Average load over last 5 minutes
       └─ Average load over last 1 minute
       (a value of 1.00 per CPU core = fully utilized;
        on a 4-core machine, 4.00 = fully loaded)

  %Cpu(s): us=user processes, sy=system/kernel, ni=niced (low priority),
           id=idle, wa=waiting for I/O, hi/si=hardware/software interrupts

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Your server shows load average 8.0 on a 4-core machine. What does this mean?"_ **Answer:** Load average represents the average number of processes wanting CPU time (running + waiting). On a 4-core machine, a load of 4.0 means full utilization with no queue; 8.0 means processes are queuing up — the system is OVERLOADED, roughly 2x what it can handle, leading to slowdowns.

## 🎨 `htop` — The Friendlier, Colorful Alternative

```bash
sudo apt install htop      # Install (Debian/Ubuntu)
sudo dnf install htop      # Install (RHEL/Fedora)
htop                        # Launch

# htop advantages over top:
#   • Color-coded bars for CPU/Memory
#   • Mouse support — click to select/kill processes!
#   • Easier tree view (F5)
#   • Scrollable list (no truncation)
#   • Built-in search (F3) and filter (F4)
```

---

# PART D: PROCESS HIERARCHY — PARENTS, CHILDREN, fork/exec

## 🌳 Every Process Has a Parent (Except PID 1)

```
PROCESS TREE EXAMPLE
═══════════════════════════════════════════════════════════════════

  systemd (PID 1)                    ← The ancestor of EVERYTHING
      │
      ├── sshd (PID 850)
      │     └── sshd: ahmed [priv] (PID 4200)
      │           └── bash (PID 4201)               ← your login shell
      │                 ├── vim notes.txt (PID 4250) ← you ran vim
      │                 └── firefox (PID 4300)        ← you ran firefox
      │                       ├── firefox (PID 4301)  ← tab renderer process
      │                       └── firefox (PID 4302)  ← another tab process
      │
      ├── nginx (PID 900)
      │     ├── nginx: worker (PID 901)
      │     └── nginx: worker (PID 902)
      │
      └── cron (PID 500)
            └── backup.sh (PID 6001)   ← scheduled job running NOW

═══════════════════════════════════════════════════════════════════
```

```bash
ps --forest                    # See the tree structure
pstree                          # Dedicated tree-view tool (cleaner!)
pstree -p                       # Include PIDs in the tree
pstree -p ahmed                  # Just one user's process tree

ps -ef | grep 4201               # Find a specific process by PID
ps -o ppid= -p 4250               # Find the PARENT PID of process 4250
```

## 👻 What Happens When a Parent Dies First?

```
ORPHAN PROCESSES
═══════════════════════════════════════════════════════════════════

  Parent (PID 500) dies suddenly, but Child (PID 600) is still running
       │
       ▼
  Child becomes an ORPHAN
       │
       ▼
  systemd (PID 1) immediately "adopts" it —
  child's PPID is automatically reassigned to 1
       │
       ▼
  Orphan continues running normally, just with a new "parent"
  (this is actually safe and intentional behavior!)

═══════════════════════════════════════════════════════════════════
```

---

# PART E: SIGNALS — COMMUNICATING WITH PROCESSES

## 📡 What Is a Signal?

A **signal** is a simple, predefined message sent to a process to tell it to do something — pause, stop, reload, or even crash deliberately.

```
SIGNALS — THE PROCESS "PHONE CALL" SYSTEM
═══════════════════════════════════════════════════════════════════
  Think of a signal like calling a process and saying ONE word:
  "STOP", "PAUSE", "RELOAD", or "DIE" — the process decides
  HOW to react (within limits the kernel allows).
═══════════════════════════════════════════════════════════════════
```

## 📜 The Most Important Signals

| Signal    | Number | Meaning                                                    | Can Be Caught/Ignored?              |
| --------- | ------ | ---------------------------------------------------------- | ----------------------------------- |
| `SIGHUP`  | 1      | Hang up — often used to tell a daemon to RELOAD its config | Yes                                 |
| `SIGINT`  | 2      | Interrupt — sent when you press Ctrl+C                     | Yes                                 |
| `SIGQUIT` | 3      | Quit with core dump                                        | Yes                                 |
| `SIGKILL` | 9      | FORCE KILL — immediately terminates, NO chance to clean up | ❌ NO — cannot be caught or ignored |
| `SIGTERM` | 15     | Polite request to terminate — DEFAULT signal of `kill`     | Yes                                 |
| `SIGSTOP` | 19     | Pause the process (like Ctrl+Z)                            | ❌ NO — cannot be caught or ignored |
| `SIGCONT` | 18     | Resume a stopped process                                   | Yes                                 |
| `SIGTSTP` | 20     | Terminal stop — sent when you press Ctrl+Z                 | Yes                                 |

```
SIGTERM vs SIGKILL — THE CRITICAL DIFFERENCE
═══════════════════════════════════════════════════════════════════

  SIGTERM (15)                       SIGKILL (9)
  ──────────────                     ─────────────
  "Please shut down gracefully"      "DIE IMMEDIATELY, no questions"

  Process CAN:                       Process CANNOT:
  • Save unsaved data                • Save anything
  • Close open files properly        • Clean up file handles
  • Release locks cleanly            • Release resources gracefully
  • Notify other processes           • Do ANYTHING at all

  ALWAYS try SIGTERM first!          Only use SIGKILL as a LAST RESORT
                                       (e.g. a truly frozen, unresponsive process)

═══════════════════════════════════════════════════════════════════
```

> **⚠️ WARNING:** Always try `kill PID` (SIGTERM) before `kill -9 PID` (SIGKILL)! SIGKILL gives the process ZERO chance to save data or close files cleanly, which can corrupt files or leave resources (like database locks) in a bad state.

## 🔫 `kill`, `killall`, `pkill` — Sending Signals

```bash
kill PID                       # Send default signal (SIGTERM/15) — polite request
kill -9 PID                    # Send SIGKILL — forceful, last resort
kill -SIGTERM PID               # Same as plain "kill PID" — explicit form
kill -SIGHUP PID                # Tell a daemon to reload its config
kill -l                          # LIST all available signal names/numbers

killall firefox                  # Kill ALL processes named "firefox" (by NAME, not PID!)
killall -9 firefox                # Force kill all firefox processes

pkill -f "python script.py"      # Kill by matching the FULL command line text
pkill -u ahmed                    # Kill ALL processes owned by user ahmed
pkill -9 -f "stuck_script"        # Force kill by command line pattern
```

| Command   | Targets By                             | Use Case                              |
| --------- | -------------------------------------- | ------------------------------------- |
| `kill`    | PID (number)                           | You already know the exact process ID |
| `killall` | Process NAME                           | "Kill every Firefox window"           |
| `pkill`   | Pattern matching (name, user, command) | More flexible, scriptable targeting   |

### Real-World Signal Examples

```bash
# Find a stuck process and kill it gracefully, then forcefully if needed
ps aux | grep myapp
kill 4521                       # Try polite shutdown first
sleep 5
kill -0 4521 2>/dev/null && kill -9 4521   # Still alive? Force kill it.

# Tell nginx to reload its config WITHOUT dropping connections
sudo kill -HUP $(cat /var/run/nginx.pid)
sudo systemctl reload nginx     # (modern equivalent, covered in Chapter 9)

# Pause and resume a process (like a video game pause button!)
kill -STOP 4521                  # Freeze it
kill -CONT 4521                  # Resume it
```

> **🎓 Interview Question:** _"What's the difference between `kill`, `killall`, and `pkill`?"_ **Answer:** `kill` targets a specific PID. `killall` targets ALL processes matching an exact process NAME. `pkill` is the most flexible — it can match by name, user, or full command-line pattern using regex, making it powerful for scripting but also riskier if your pattern accidentally matches the wrong processes.

## 🛡️ Trapping Signals in Bash Scripts

```bash
#!/bin/bash
# Catch Ctrl+C and clean up before exiting

cleanup() {
    echo ""
    echo "Caught SIGINT! Cleaning up temp files..."
    rm -f /tmp/myapp_*.tmp
    exit 0
}

trap cleanup SIGINT SIGTERM

echo "Running... press Ctrl+C to test graceful shutdown"
while true; do
    sleep 1
done
```

---

# PART F: JOB CONTROL — fg, bg, nohup, disown

## 🎛️ Running Commands in the Background

```bash
sleep 100 &                    # The "&" runs it in the BACKGROUND immediately
echo "I can keep typing other commands now!"

jobs                             # List background jobs in THIS shell session
jobs -l                          # Include PIDs

fg                                # Bring the most recent background job to FOREGROUND
fg %1                             # Bring job number 1 to foreground specifically
bg                                # Resume a STOPPED job, but keep it in the BACKGROUND
bg %1                             # Resume job 1 in the background
```

```
FOREGROUND vs BACKGROUND
═══════════════════════════════════════════════════════════════════
  FOREGROUND                         BACKGROUND
  ─────────────                      ─────────────
  Takes over your terminal —          Runs "behind the scenes" —
  you can't type other commands       you get your prompt back
  until it finishes                    immediately, command keeps running

  command                              command &
═══════════════════════════════════════════════════════════════════
```

## ⏸️ Suspending and Resuming Jobs

```bash
# While a foreground command is running:
# Press Ctrl+Z to SUSPEND (pause) it and return to your prompt

vim notes.txt
# (press Ctrl+Z)
# [1]+  Stopped    vim notes.txt
# You're back at the prompt! The vim session is FROZEN, not closed.

jobs                  # See it listed as "Stopped"
fg                     # Resume it in the foreground — exactly where you left off!
```

## 🔌 `nohup` — Surviving Terminal Disconnection

```
THE PROBLEM nohup SOLVES
═══════════════════════════════════════════════════════════════════
  Without nohup:                     With nohup:
  ──────────────                     ────────────
  You SSH into a server, start a     The process IGNORES the SIGHUP
  long script, then close your        signal sent when your terminal
  terminal/SSH session                closes — it KEEPS RUNNING even
                                       after you disconnect!
  The shell sends SIGHUP to all
  its child processes →
  YOUR SCRIPT DIES TOO! 😱
═══════════════════════════════════════════════════════════════════
```

```bash
nohup long_running_script.sh &          # Run it immune to terminal closing
nohup long_running_script.sh > output.log 2>&1 &   # Also redirect its output

# Check it later, even after reconnecting:
cat nohup.out                            # Default output file if you didn't redirect
```

## 🔗 `disown` — Detaching a Job From Your Shell

```bash
long_command &
disown                          # Removes it from the shell's job table
                                  # (it survives terminal closing, similar to nohup,
                                  #  but applied to an ALREADY-running background job)

disown -a                       # Disown ALL background jobs
disown %1                       # Disown a specific job number
```

```
nohup vs disown
═══════════════════════════════════════════════════════════════════
  nohup            → Set up immunity BEFORE starting the command
  disown           → Detach a job that's ALREADY running in the background

  Modern alternative for both: use a terminal multiplexer
  like "tmux" or "screen" — the session itself keeps running
  on the server, and you can RECONNECT to it later (covered
  more in later DevOps chapters)
═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"You SSH into a server, run a script without `nohup`, then your connection drops. What happens to the script?"_ **Answer:** When the SSH session ends, the shell sends SIGHUP to its child processes, which typically terminates them too — unless the process was started with `nohup`, run inside `disown`ed background job, or launched inside a persistent session tool like `tmux`/`screen`.

---

# PART G: PROCESS PRIORITY — nice AND renice

## ⚖️ How Linux Decides Who Gets the CPU

Every process has a **nice value** ranging from **-20 (highest priority) to +19 (lowest priority)**. Despite the name, a "nicer" process is LESS demanding — it's being "nice" to other processes by stepping back.

```
NICE VALUE SCALE
═══════════════════════════════════════════════════════════════════
   -20                      0                        +19
    │                       │                          │
  HIGHEST PRIORITY     DEFAULT PRIORITY          LOWEST PRIORITY
  (most CPU time,       (normal processes)        (most "nice" —
   needs root to set)                               yields CPU to others)

  💡 Memory trick: a LOW nice number = NOT nice = wants MORE CPU
              a HIGH nice number = VERY nice = willing to WAIT
═══════════════════════════════════════════════════════════════════
```

```bash
nice                            # Show your default nice value (usually 0)
nice -n 10 ./heavy_script.sh    # Start a NEW process with LOWER priority
nice -n -5 ./important_task.sh  # Start with HIGHER priority (needs sudo for negative!)

renice -n 15 -p 4521              # Change priority of an ALREADY-RUNNING process
sudo renice -n -10 -p 4521         # Negative values require root

ps -o pid,ni,comm -p 4521          # Check a process's current nice value
top                                 # The "NI" column shows nice values live
```

### Real-World Example

```bash
# Running a heavy backup job WITHOUT slowing down the live web server
nice -n 19 tar -czf backup.tar.gz /var/www/

# An important real-time task that should win over everything else
sudo nice -n -15 ./critical_realtime_process
```

> **🎓 Interview Question:** _"What's the difference between `nice` and `renice`?"_ **Answer:** `nice` sets the priority of a NEW process AS YOU START IT. `renice` changes the priority of a process that's ALREADY RUNNING, identified by its PID.

---

# PART H: ADVANCED MONITORING TOOLS

## 🔧 Tools Beyond ps/top

```bash
# vmstat — Virtual memory statistics, great for spotting bottlenecks
vmstat 2                     # Update every 2 seconds
vmstat 1 5                    # Update every 1 second, 5 times total

# iostat — Disk I/O statistics (install: sysstat package)
iostat -x 2                   # Extended stats, every 2 seconds

# lsof — List Open Files (incredibly useful for debugging!)
lsof -p 4521                  # All files opened by PID 4521
lsof /var/log/syslog           # Which process(es) have this file open?
sudo lsof -i :80               # Which process is using port 80? (network "file")
sudo lsof -u ahmed              # All files opened by user ahmed

# fuser — Find processes using a file or mount point
sudo fuser /mnt/usb            # What's using this mount point?
sudo fuser -k /mnt/usb          # Kill whatever is using it (forceful unmount prep)

# free — Memory overview (from Chapter 1, very relevant here too)
free -h

# uptime — Quick load average check
uptime
```

### Real-World Debugging Scenario: "Why Won't This Disk Unmount?"

```bash
sudo umount /mnt/usb
# umount: /mnt/usb: target is busy.

sudo lsof /mnt/usb              # Find out WHO is using it
sudo fuser -v /mnt/usb           # Verbose: shows user + process name too

# Once you know the offending PID:
kill 4521                        # Politely ask it to stop
sudo umount /mnt/usb             # Now it should work
```

## 🗂️ Process Info Straight From `/proc` (Callback to Chapter 2!)

```bash
ls /proc/4521/                  # Everything the kernel knows about this PID
cat /proc/4521/status            # Memory, state, threads, signals
cat /proc/4521/cmdline           # Exact command line used to start it
ls -l /proc/4521/fd/             # Every file descriptor (open file) it holds
cat /proc/4521/environ | tr '\0' '\n'    # Environment variables it was started with
```

---

# PART I: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 7 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Processes:
     • A process = a program loaded into memory and running
     • Created via fork() (clone) + exec() (replace with new program)
     • Every process has PID, PPID, UID, state, and its own memory

  ✅ States:
     R (running) S (sleeping) D (uninterruptible) T (stopped)
     Z (zombie — finished, but parent hasn't collected exit status)

  ✅ Viewing Processes:
     ps aux (snapshot)   top/htop (live)   pstree (hierarchy)

  ✅ Signals:
     SIGTERM (15) = polite request, catchable
     SIGKILL (9)  = forceful, CANNOT be caught — last resort only!
     kill PID / killall name / pkill pattern

  ✅ Job Control:
     command &        → run in background
     Ctrl+Z            → suspend foreground job
     fg / bg / jobs    → manage suspended/background jobs
     nohup / disown    → survive terminal disconnection

  ✅ Priority:
     nice (-20 to +19)  -20=highest priority, +19=lowest ("most nice")
     nice -n N cmd       → set priority when STARTING
     renice -n N -p PID  → change priority of RUNNING process

  ✅ Advanced Tools:
     lsof (open files)   fuser (who's using a file/mount)
     vmstat/iostat (system performance)   /proc/PID (raw kernel data)

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 7 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

VIEWING PROCESSES                SIGNALS & KILLING               JOB CONTROL
──────────────────────         ─────────────────────         ───────────────────
ps aux            All procs     kill PID         SIGTERM       cmd &          Background
ps -ef             Alt format    kill -9 PID      SIGKILL       Ctrl+Z          Suspend
ps --forest        Tree view     kill -HUP PID    Reload cfg    jobs            List jobs
top                Live monitor  killall name     Kill by name  fg / bg         Resume
htop               Better top    pkill -f pattern Kill by match nohup cmd &     Survive logout
pstree -p          Tree + PIDs   kill -l          List signals  disown          Detach job

PRIORITY                         OPEN FILES & DEBUGGING          PROC INFO
──────────────────────         ─────────────────────         ───────────────────
nice -n N cmd      New proc     lsof -p PID      Files by PID  cat /proc/PID/status
renice -n N -p PID Running proc lsof -i :80      Port owner    cat /proc/PID/cmdline
ps -o pid,ni       Check value  fuser -v file    Who's using   ls /proc/PID/fd/
top (NI column)    Live view    fuser -k file    Force free it vmstat / iostat

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 7 Interview Questions

| #   | Question                                                                            | Key Answer Points                                                                                                                          |
| --- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | What's the difference between a program and a process?                              | A program is a static file on disk; a process is a running instance of that program loaded into memory                                     |
| 2   | How does a shell create a new process?                                              | `fork()` clones itself, then the child calls `exec()` to replace its memory with the new program                                           |
| 3   | What is a zombie process?                                                           | A finished process whose exit status hasn't been collected by its parent yet; harmless but indicates the parent isn't calling `wait()`     |
| 4   | Can you kill a zombie with `kill -9`?                                               | No — it's already dead. You must fix/kill the parent so it gets reaped                                                                     |
| 5   | Difference between SIGTERM and SIGKILL?                                             | SIGTERM (15) is a polite, catchable request allowing cleanup; SIGKILL (9) is forceful and cannot be caught, giving zero chance to clean up |
| 6   | Difference between `kill`, `killall`, and `pkill`?                                  | kill targets a PID; killall targets an exact process name; pkill matches flexible patterns (name/user/cmdline)                             |
| 7   | What happens to a background process if you close your SSH session without `nohup`? | The shell sends SIGHUP to its children, which usually terminates them, unless protected by `nohup`, `disown`, or a session tool like tmux  |
| 8   | What does a nice value of -20 vs +19 mean?                                          | -20 = highest priority (most CPU demand, needs root); +19 = lowest priority ("nicest", yields to others)                                   |
| 9   | Difference between `nice` and `renice`?                                             | `nice` sets priority when STARTING a new process; `renice` changes priority of an ALREADY-RUNNING process by PID                           |
| 10  | How would you find which process is using port 8080?                                | `sudo lsof -i :8080`                                                                                                                       |
| 11  | What does load average 4.0 mean on a 4-core machine?                                | Full utilization — exactly enough demand to keep all 4 cores busy with no queue                                                            |
| 12  | What's an orphan process?                                                           | A child process whose parent died first; it gets automatically re-parented to PID 1 (systemd/init)                                         |

## 🔬 Practical Lab: Chapter 7 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: Exploring Running Processes
# ──────────────────────────────────────────────────────────────────
ps aux | head -20
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
pstree -p | head -20
echo $$
ps -p $$

# ──────────────────────────────────────────────────────────────────
# LAB 2: Live Monitoring
# ──────────────────────────────────────────────────────────────────
top -n 1                              # One snapshot, non-interactive
top -b -n 1 | head -20                # Batch mode output

# Generate some CPU load to watch (in another terminal, run "top" live):
yes > /dev/null &
JOBPID=$!
echo "Started load generator with PID: $JOBPID"
sleep 5
kill $JOBPID                          # Clean up!

# ──────────────────────────────────────────────────────────────────
# LAB 3: Job Control Practice
# ──────────────────────────────────────────────────────────────────
sleep 100 &
jobs
fg                                     # Bring it to foreground
# Press Ctrl+C to stop it

sleep 100 &
jobs -l                                # Note the PID
kill %1                                # Kill by job number
jobs                                    # Confirm it's gone

# ──────────────────────────────────────────────────────────────────
# LAB 4: Signals Practice
# ──────────────────────────────────────────────────────────────────
sleep 300 &
PID=$!
echo "Sleep process PID: $PID"
kill -STOP $PID
ps -p $PID                              # Should show STAT as "T" (stopped)
kill -CONT $PID
ps -p $PID                              # Should show STAT as "S" again
kill $PID                                # Clean shutdown
ps -p $PID                                # Should be gone

# ──────────────────────────────────────────────────────────────────
# LAB 5: Priority and Open Files
# ──────────────────────────────────────────────────────────────────
nice -n 10 sleep 60 &
ps -o pid,ni,comm -p $!

sudo lsof -i :22 2>/dev/null            # Who's using SSH's port?
lsof -p $$ 2>/dev/null | head -10        # Files open in YOUR current shell
```

## 🧠 Mini Project: Process Watchdog Script

```bash
cat > ~/watchdog.sh << 'EOF'
#!/bin/bash
set -uo pipefail

# Usage: ./watchdog.sh <process_name>
# Restarts a process if it's not running (simple but real pattern!)

PROCESS_NAME="${1:?Usage: $0 <process_name_to_watch>}"
CHECK_INTERVAL=10

echo "🐕 Watchdog started for: $PROCESS_NAME"
echo "Checking every $CHECK_INTERVAL seconds. Press Ctrl+C to stop."

trap 'echo ""; echo "Watchdog stopped."; exit 0' SIGINT SIGTERM

while true; do
    if pgrep -f "$PROCESS_NAME" > /dev/null; then
        echo "[$(date '+%H:%M:%S')] ✅ $PROCESS_NAME is running (PID: $(pgrep -f "$PROCESS_NAME" | head -1))"
    else
        echo "[$(date '+%H:%M:%S')] ❌ $PROCESS_NAME is NOT running!"
        echo "    (In a real system, this is where you'd auto-restart it)"
        # Example: nohup "$PROCESS_NAME" &
    fi
    sleep "$CHECK_INTERVAL"
done
EOF

chmod +x ~/watchdog.sh
# Test it: ./watchdog.sh sleep   (then run "sleep 1000 &" in another terminal)
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
  ⬜ Chapter 8:  Networking (TCP/IP, DNS, SSH, firewall)
  ⬜ Chapter 9:  System Administration (systemd, logging, cron)
  ⬜ Chapter 10: Linux Security (PAM, SELinux, encryption)
  ⬜ Chapter 11: Containers (Docker, namespaces, cgroups)
  ⬜ Chapter 12: Linux Kernel Development

═══════════════════════════════════════════════════════════════════
  YOU ARE HERE: ✅✅✅✅✅✅✅ — Seven chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

Next: [Chapter 8 — Networking: TCP/IP, DNS, SSH, and Firewalls](/chapter-8.md)

---
