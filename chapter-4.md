# CHAPTER 4: TEXT PROCESSING

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 4
═══════════════════════════════════════════════════════════════
  PART A  →  Why Text Processing Is Core to Linux Philosophy
  PART B  →  Pipes & Redirection — The Foundation
  PART C  →  grep — Search Like a Pro
  PART D  →  cut, sort, uniq — Slicing and Organizing Data
  PART E  →  sed — The Stream Editor
  PART F  →  awk — The Pattern-Action Powerhouse
  PART G  →  Combining Tools — Real Pipeline Mastery
  PART H  →  Other Essential Text Tools
  PART I  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: WHY TEXT PROCESSING IS CORE TO LINUX PHILOSOPHY

## 📜 "Everything Is Text" — The UNIX Philosophy

```
THE UNIX PHILOSOPHY (Doug McIlroy, 1978)
═══════════════════════════════════════════════════════════════════
  1. Write programs that do ONE thing well.
  2. Write programs to work TOGETHER.
  3. Write programs that handle TEXT streams,
     because text is a universal interface.
═══════════════════════════════════════════════════════════════════
```

This is why Linux has hundreds of small, focused commands instead of giant all-in-one programs. `grep` only searches. `sort` only sorts. `cut` only extracts columns. But when you connect them with pipes, you can build something more powerful than any single tool.

```
WHY THIS MATTERS IN REAL LIFE
═══════════════════════════════════════════════════════════════
  Configuration files    → plain text (/etc/*.conf)
  System logs             → plain text (/var/log/*)
  Process information     → plain text (/proc/*)
  Network output           → plain text (ip, ss, netstat)
  Source code               → plain text
  CSV/data files             → plain text

  If you can manipulate text, you can manipulate
  almost ANYTHING on a Linux system.
═══════════════════════════════════════════════════════════════
```

---

# PART B: PIPES & REDIRECTION — THE FOUNDATION

## 🚰 The Pipe (`|`) — Connecting Commands

A pipe takes the **output** of one command and feeds it as the **input** of the next command.

![](/img/ch-4/the-pipe-concept.png)

```bash
# Real pipeline examples
ps aux | grep firefox              # Find Firefox process
cat /etc/passwd | wc -l            # Count lines (= number of users)
ls -la | grep "^d"                 # Show only directories
history | grep "ssh"               # Find past SSH commands you ran
dmesg | grep -i error              # Find errors in kernel messages
```

## ↩️ Redirection — Controlling Input/Output

```
REDIRECTION OPERATORS
═══════════════════════════════════════════════════════════════════
  >    Redirect STDOUT, OVERWRITE the file
  >>   Redirect STDOUT, APPEND to the file
  <    Redirect STDIN (feed a file INTO a command)
  2>   Redirect STDERR (errors only)
  2>>  Append STDERR
  &>   Redirect BOTH stdout and stderr
  2>&1 Redirect stderr to wherever stdout is going
═══════════════════════════════════════════════════════════════════
```

```bash
echo "Hello" > file.txt           # Overwrite file.txt with "Hello"
echo "World" >> file.txt          # Append "World" to file.txt
cat file.txt                       # Hello \n World

sort < unsorted.txt                # Feed unsorted.txt as INPUT to sort
command > output.log 2>&1          # Save BOTH normal output and errors
command > /dev/null 2>&1           # Discard EVERYTHING (silence a command)
ls nonexistent_file 2> errors.txt  # Save ONLY the error message
```

```
THE THREE STANDARD STREAMS
═══════════════════════════════════════════════════════════════
  STDIN  (0)  → Input coming INTO a program (usually keyboard)
  STDOUT (1)  → Normal output FROM a program
  STDERR (2)  → Error messages FROM a program (separate from STDOUT!)
═══════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Why does Linux separate STDOUT and STDERR into two different streams?"_ **Answer:** So you can redirect normal output and error messages independently — e.g., save results to a file while still seeing errors on screen, or vice versa. `command > results.txt` still shows errors on your terminal because they go to STDERR (fd 2), not STDOUT (fd 1).

---

# PART C: grep — SEARCH LIKE A PRO

## 🔍 grep — Global Regular Expression Print

`grep` searches text for patterns — it's probably the single most-used command in any Linux engineer's daily life.

**Syntax:** `grep [OPTIONS] PATTERN [FILE...]`

### Basic Usage

```bash
grep "error" logfile.txt                  # Find lines containing "error"
grep -i "error" logfile.txt                # Case-insensitive search
grep -v "error" logfile.txt                # INVERT: show lines WITHOUT "error"
grep -c "error" logfile.txt                # COUNT matching lines (not show them)
grep -n "error" logfile.txt                # Show LINE NUMBERS
grep -l "error" *.log                      # List only FILENAMES with matches
grep -r "TODO" /home/ahmed/                # RECURSIVE search through directories
grep -w "cat" file.txt                     # Match WHOLE WORD only (not "category")
grep -A 3 "error" logfile.txt              # Show 3 lines AFTER each match
grep -B 3 "error" logfile.txt              # Show 3 lines BEFORE each match
grep -C 3 "error" logfile.txt              # Show 3 lines of CONTEXT (before+after)
```

### grep Options Quick Table

| Option       | Meaning                                        |
| ------------ | ---------------------------------------------- |
| `-i`         | Case-insensitive                               |
| `-v`         | Invert match (show non-matching lines)         |
| `-c`         | Count matches                                  |
| `-n`         | Show line numbers                              |
| `-l`         | Show only filenames with matches               |
| `-r` or `-R` | Recursive search through directories           |
| `-w`         | Match whole words only                         |
| `-x`         | Match the entire line exactly                  |
| `-A n`       | Show n lines after match                       |
| `-B n`       | Show n lines before match                      |
| `-C n`       | Show n lines of context (before AND after)     |
| `-E`         | Extended regex (same as `egrep`)               |
| `-o`         | Show ONLY the matched part, not the whole line |
| `--color`    | Highlight matches in color                     |

## 🧩 Regular Expressions (Regex) with grep

```
COMMON REGEX SYMBOLS
═══════════════════════════════════════════════════════════════════
  .        Any single character
  *        Zero or more of the previous character
  ^        Start of line
  $        End of line
  []       Character class (any ONE of these characters)
  [^]      NOT any of these characters
  \d       Digit (with -P for Perl regex)
  +        One or more (needs -E for extended regex)
  ?        Zero or one (needs -E)
  |        OR (needs -E)
  ()       Grouping (needs -E)
  {n,m}    Repeat n to m times (needs -E)
═══════════════════════════════════════════════════════════════════
```

### Real Regex Examples

```bash
grep "^root" /etc/passwd               # Lines STARTING with "root"
grep "bash$" /etc/passwd                # Lines ENDING with "bash"
grep "^#" config.conf                   # Lines that are comments (start with #)
grep -v "^#" config.conf                # Lines that are NOT comments
grep "^$" file.txt                       # Find EMPTY lines
grep -v "^$" file.txt                    # Remove empty lines
grep "[0-9]" file.txt                    # Lines containing any digit
grep "^[A-Z]" file.txt                   # Lines starting with a capital letter
grep -E "error|warning|critical" log.txt # Match ANY of these words (OR)
grep -E "^[0-9]{3}-[0-9]{4}$" phones.txt # Match phone format 123-4567
grep -P "\d{3}\.\d{3}\.\d{3}\.\d{3}" log.txt   # Match an IP-like pattern (Perl regex)
```

### Real-World grep Examples

```bash
# Find all failed SSH login attempts
sudo grep "Failed password" /var/log/auth.log

# Find IP addresses connecting via SSH
sudo grep "sshd" /var/log/auth.log | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}"

# Find all users with bash as their shell
grep "/bin/bash$" /etc/passwd

# Find which process is using port 8080 (combine with other tools)
sudo ss -tulnp | grep 8080

# Count how many ERROR lines exist in a log
grep -c "ERROR" /var/log/app.log

# Search multiple files at once for a config setting
grep -r "max_connections" /etc/mysql/
```

> **🎓 Interview Question:** _"What's the difference between `grep`, `egrep`, and `fgrep`?"_ **Answer:** `grep` uses basic regex; `egrep` (= `grep -E`) uses extended regex supporting `+`, `?`, `|`, `()` without escaping; `fgrep` (= `grep -F`) treats the pattern as a LITERAL string (no regex at all) — useful and faster when searching for exact text like a filename containing dots or brackets.

---

# PART D: cut, sort, uniq — SLICING AND ORGANIZING DATA

## ✂️ `cut` — Extract Columns

**Syntax:** `cut [OPTIONS] [FILE]`

```bash
cut -d: -f1 /etc/passwd              # -d: delimiter is ":", -f1: field 1 (username)
cut -d: -f1,3 /etc/passwd             # Multiple fields: username and UID
cut -d: -f1-3 /etc/passwd             # Range: fields 1 through 3
cut -c1-5 file.txt                    # Extract CHARACTERS 1 to 5 (not fields)
echo "a,b,c,d" | cut -d, -f2-3        # Output: b,c
```

```
cut FIELD EXTRACTION DIAGRAM
═══════════════════════════════════════════════════════════════════
  Input line:    ahmed : x : 1000 : 1000 : Ahmed Khan : /home/ahmed : /bin/bash
  Delimiter:                    :

  -f1  → ahmed
  -f3  → 1000
  -f1,3 → ahmed 1000
  -f1-3 → ahmed x 1000
═══════════════════════════════════════════════════════════════════
```

## 🔢 `sort` — Order Lines

**Syntax:** `sort [OPTIONS] [FILE]`

```bash
sort names.txt                    # Alphabetical sort (default)
sort -r names.txt                 # Reverse order
sort -n numbers.txt                # NUMERIC sort (important! "10" < "9" in text sort)
sort -nr numbers.txt               # Numeric, reverse (largest first)
sort -k2 data.txt                  # Sort by the 2nd COLUMN/field
sort -k2 -n data.txt               # Sort by 2nd field, numerically
sort -u names.txt                  # Sort AND remove duplicates
sort -t: -k3 -n /etc/passwd        # Sort /etc/passwd by UID (field 3, colon-delimited)
sort -h sizes.txt                  # Human-readable sizes (1K, 2M, 1G sort correctly!)
```

> **🎓 Common Mistake:** Forgetting `-n` when sorting numbers! Without it, `sort` treats numbers as TEXT, so "10" comes before "9" alphabetically (because "1" < "9" as characters). Always use `sort -n` for true numeric ordering.

```
TEXT SORT vs NUMERIC SORT
═══════════════════════════════════════════════════════════════
  Input: 9, 10, 2, 100

  sort (text):        sort -n (numeric):
  ─────────────         ──────────────
  10                    2
  100                   9
  2                     10
  9                     100
═══════════════════════════════════════════════════════════════
```

## 🔁 `uniq` — Remove or Count Duplicate Lines

**⚠️ Important: `uniq` only works on ADJACENT duplicate lines — always `sort` first!**

```bash
sort names.txt | uniq                # Remove duplicates (must sort first!)
sort names.txt | uniq -c              # Count how many times each line appears
sort names.txt | uniq -d              # Show ONLY lines that appear MORE than once
sort names.txt | uniq -u              # Show ONLY lines that appear EXACTLY once
sort access.log | uniq -c | sort -rn  # Count + sort by frequency (very common combo!)
```

### Real-World Example: Top IP Addresses Hitting Your Server

```bash
# Extract IPs from a web log, count occurrences, show top 10
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

---

# PART E: sed — THE STREAM EDITOR

## ✏️ sed — Find and Replace at Scale

`sed` reads text line by line and applies editing commands — most famously, find-and-replace.

**Syntax:** `sed [OPTIONS] 'COMMAND' [FILE]`

### The Classic: Substitution (`s`)

```bash
sed 's/old/new/' file.txt              # Replace FIRST occurrence per line
sed 's/old/new/g' file.txt             # Replace ALL occurrences (global) per line
sed 's/old/new/2' file.txt             # Replace ONLY the 2nd occurrence per line
sed 's/old/new/gi' file.txt            # Global + case-insensitive
sed -i 's/old/new/g' file.txt          # -i = edit the FILE IN PLACE (be careful!)
sed -i.bak 's/old/new/g' file.txt      # -i.bak = in-place but KEEP a backup copy
```

```
sed SUBSTITUTION SYNTAX
═══════════════════════════════════════════════════════════════════
  s / pattern / replacement / flags
  │     │            │           │
  │     │            │           └─ g (global), i (case-insens), N (Nth)
  │     │            └─ what to replace it WITH
  │     └─ what to SEARCH FOR (supports regex!)
  └─ "s" = substitute command
═══════════════════════════════════════════════════════════════════
```

### Real-World sed Examples

```bash
# Replace all "localhost" with "myserver.com" in a config file (with backup!)
sed -i.bak 's/localhost/myserver.com/g' /etc/myapp/config.conf

# Delete blank lines
sed '/^$/d' file.txt

# Delete lines matching a pattern
sed '/^#/d' config.conf                # Delete comment lines
sed '/DEBUG/d' app.log                  # Delete lines containing "DEBUG"

# Print only specific line numbers
sed -n '5p' file.txt                    # Print ONLY line 5
sed -n '5,10p' file.txt                 # Print lines 5 through 10
sed -n '/error/p' file.txt              # Print only lines matching "error" (like grep!)

# Replace using different delimiter (useful when pattern has slashes, e.g. paths)
sed 's#/old/path#/new/path#g' file.txt

# Add text before/after a matching line
sed '/pattern/i\New line BEFORE match' file.txt   # Insert before
sed '/pattern/a\New line AFTER match' file.txt    # Append after

# Replace text only on a specific line number
sed '3s/old/new/' file.txt              # Only on line 3

# Using a variable in sed (combine with shell)
NAME="ahmed"
sed "s/USERNAME/$NAME/g" template.txt
```

> **⚠️ WARNING:** `sed -i` modifies files DIRECTLY with no undo! Always test your `sed` command WITHOUT `-i` first to preview the output, or use `-i.bak` to keep a backup automatically.

```
sed WORKFLOW SAFETY TIP
═══════════════════════════════════════════════════════════════
  Step 1: sed 's/old/new/g' file.txt          ← preview on screen
  Step 2: sed 's/old/new/g' file.txt > new.txt ← save to NEW file
  Step 3: sed -i.bak 's/old/new/g' file.txt    ← edit with backup
═══════════════════════════════════════════════════════════════
```

---

# PART F: awk — THE PATTERN-ACTION POWERHOUSE

## 🦾 awk — A Mini Programming Language for Text

`awk` is the most powerful of the three. It thinks in terms of **rows and columns** — perfect for structured text like logs, CSVs, and command output.

**Syntax:** `awk 'pattern { action }' file`

## 📐 Understanding awk's Built-in Variables

```
AWK BUILT-IN VARIABLES
═══════════════════════════════════════════════════════════════════
  $0      → The ENTIRE current line
  $1      → The 1st field/column
  $2      → The 2nd field/column
  $NF     → The LAST field (NF = Number of Fields)
  $(NF-1) → The SECOND-TO-LAST field
  NF      → Total number of fields in current line
  NR      → Current line/record number
  FS      → Field Separator (default: whitespace)
  OFS     → Output Field Separator
═══════════════════════════════════════════════════════════════════
```

### Basic awk Examples

```bash
echo "ahmed 25 developer" | awk '{print $1}'         # ahmed
echo "ahmed 25 developer" | awk '{print $2}'         # 25
echo "ahmed 25 developer" | awk '{print $NF}'        # developer (last field)
echo "ahmed 25 developer" | awk '{print NF}'         # 3 (number of fields)

awk '{print $1, $3}' data.txt                        # Print field 1 and 3
awk -F: '{print $1}' /etc/passwd                      # -F: sets field separator to ":"
awk -F, '{print $2}' data.csv                         # CSV: separator is comma
```

### Pattern Matching with awk (like grep, but smarter)

```bash
awk '/error/' logfile.txt                  # Print lines matching "error" (like grep)
awk '$3 > 100' data.txt                     # Print lines where field 3 > 100
awk '$1 == "root"' /etc/passwd              # Print lines where field 1 equals "root" (colon split needed: -F:)
awk -F: '$3 >= 1000 {print $1}' /etc/passwd # Print usernames with UID >= 1000 (real human users!)
awk 'NR==5'  file.txt                        # Print only line number 5
awk 'NR>=5 && NR<=10' file.txt              # Print lines 5 through 10
```

### awk Calculations

```bash
awk '{sum += $1} END {print sum}' numbers.txt        # Sum a column of numbers
awk '{sum += $3} END {print "Total:", sum}' sales.txt
awk '{print $1, $2*2}' data.txt                        # Multiply field 2 by 2
awk '{total += $1; count++} END {print total/count}'  numbers.txt   # Average
```

```
awk EXECUTION MODEL
═══════════════════════════════════════════════════════════════════
  awk 'BEGIN{...}  pattern{action}  END{...}'  file

  BEGIN   → runs ONCE before reading any lines (setup)
  pattern → runs for EVERY line that matches the pattern
  action  → what to DO for each matching line
  END     → runs ONCE after all lines are processed (summary)
═══════════════════════════════════════════════════════════════════
```

### Real-World awk Example: Web Server Log Analysis

```bash
# Sample access.log line:
# 192.168.1.10 - - [14/Jun/2026:10:23:01] "GET /index.html HTTP/1.1" 200 1234

# Count requests per IP address
awk '{print $1}' access.log | sort | uniq -c | sort -rn

# Print only requests that resulted in errors (4xx/5xx status codes)
awk '$9 ~ /^[45]/ {print $1, $9, $7}' access.log

# Calculate total bytes transferred
awk '{sum += $10} END {print "Total bytes:", sum}' access.log

# Pretty report combining BEGIN, pattern, and END
awk 'BEGIN {print "=== Error Report ==="}
     $9 ~ /^5/ {count++; print $1, $9}
     END {print "Total server errors:", count}' access.log
```

### Real-World awk Example: Process Monitoring

```bash
# Print process name and memory usage, sorted by memory (descending)
ps aux | awk '{print $4, $11}' | sort -rn | head -10

# Find processes using more than 50% CPU
ps aux | awk '$3 > 50.0 {print $2, $3, $11}'

# Print free RAM in a friendly format
free -m | awk 'NR==2{printf "Used: %sMB / Total: %sMB (%.2f%%)\n", $3, $2, $3*100/$2}'
```

> **🎓 Interview Question:** _"When would you use awk instead of grep or sed?"_ **Answer:** Use `grep` for simple pattern matching, `sed` for find-and-replace transformations, and `awk` when you need to work with COLUMNS/FIELDS, do CALCULATIONS, or build conditional logic across structured data — awk is essentially a lightweight programming language for tabular text.

---

# PART G: COMBINING TOOLS — REAL PIPELINE MASTERY

## 🔗 The Power Combo

This is where Linux text processing truly shines: chaining multiple small tools into one powerful pipeline.

```bash
# Find the top 5 most frequent error messages in a log
grep "ERROR" app.log | awk -F: '{print $3}' | sort | uniq -c | sort -rn | head -5

# Find all users who can log in with a shell (not /usr/sbin/nologin)
grep -v "nologin" /etc/passwd | cut -d: -f1,7

# Find which process is listening on a port, then check its memory usage
sudo ss -tulnp | grep ":80 " | awk '{print $NF}'

# Count unique visitor IPs in today's logs
grep "$(date +%d/%b/%Y)" access.log | awk '{print $1}' | sort -u | wc -l

# Find the 5 largest files in your home directory
find ~ -type f -exec du -h {} \; 2>/dev/null | sort -rh | head -5

# Extract all email addresses from a text file
grep -oE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" file.txt

# Real-time monitoring: watch for new errors as they happen
tail -f /var/log/syslog | grep --line-buffered -i "error"
```

```
PIPELINE THINKING — BUILD IT STEP BY STEP
═══════════════════════════════════════════════════════════════════

  Goal: "Show me the top 5 IPs hitting my server with errors"

  Step 1: cat access.log
          (start with the raw data)

  Step 2: cat access.log | grep " 5[0-9][0-9] "
          (filter to only 5xx server errors)

  Step 3: cat access.log | grep " 5[0-9][0-9] " | awk '{print $1}'
          (extract just the IP address column)

  Step 4: cat access.log | grep " 5[0-9][0-9] " | awk '{print $1}' | sort
          (sort so duplicates are adjacent)

  Step 5: ... | uniq -c
          (count how many times each IP repeats)

  Step 6: ... | sort -rn
          (sort by count, highest first)

  Step 7: ... | head -5
          (keep only the top 5)

  💡 BUILD PIPELINES INCREMENTALLY — test each stage before adding the next!

═══════════════════════════════════════════════════════════════════
```

---

# PART H: OTHER ESSENTIAL TEXT TOOLS

## 🧰 More Tools Worth Knowing

### `tr` — Translate or Delete Characters

```bash
echo "hello" | tr 'a-z' 'A-Z'              # HELLO (lowercase to uppercase)
echo "hello world" | tr -d ' '             # helloworld (delete spaces)
echo "a,b,c" | tr ',' '\n'                  # Convert commas to newlines
cat file.txt | tr -s ' '                   # Squeeze multiple spaces into one
```

### `wc` — Word/Line/Byte Count (revisited)

```bash
wc -l file.txt              # Line count
wc -w file.txt              # Word count
wc -c file.txt              # Byte count
ls | wc -l                  # Count how many files/folders are in a directory!
```

### `paste` and `join` — Combining Files

```bash
paste file1.txt file2.txt          # Merge files SIDE BY SIDE (column-wise)
paste -d, file1.txt file2.txt      # Use comma as the delimiter

join file1.txt file2.txt           # Merge files based on a MATCHING common field
                                    # (like a SQL JOIN, but for text files!)
```

### `tee` — Save AND Display Output Simultaneously

```bash
echo "test" | tee output.txt                  # Show on screen AND save to file
command | tee output.txt | grep "error"       # Save full output, but only show errors
sudo command | tee -a /var/log/myapp.log       # -a = append instead of overwrite
```

```
tee — THE "SPLITTER" TOOL
═══════════════════════════════════════════════════════════════
                       ┌──────► Terminal screen
  command ──► tee ─────┤
                       └──────► output.txt file

  (Like a real "T" pipe junction in plumbing!)
═══════════════════════════════════════════════════════════════
```

### `xargs` — Build Commands from Piped Input

```bash
find . -name "*.tmp" | xargs rm                  # Delete all found .tmp files
echo "file1.txt file2.txt" | xargs cat            # Pass each as an argument to cat
find . -name "*.log" | xargs grep -l "ERROR"      # Search inside every found file
ls *.txt | xargs -I {} cp {} /backup/             # -I {} = placeholder for each item
```

### `diff` — Compare Two Files

```bash
diff file1.txt file2.txt           # Show differences line by line
diff -u file1.txt file2.txt        # Unified format (used in patches/git diffs)
diff -y file1.txt file2.txt        # Side-by-side comparison
```

---

# PART I: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 4 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Philosophy:
     • Everything in Linux is text — that's why these tools are universal
     • Small tools + pipes (|) = powerful combinations

  ✅ Pipes & Redirection:
     |   connects commands     >  overwrite     >>  append
     2>  redirect errors        2>&1  errors→stdout    < feed file as input

  ✅ grep — Search:
     -i (case-insens) -v (invert) -c (count) -n (line#) -r (recursive)
     Regex: ^ start, $ end, . any char, * repeat, [] class

  ✅ cut/sort/uniq — Slice and Organize:
     cut -d: -f1     sort -n     sort -k2     uniq -c (after sort!)

  ✅ sed — Find & Replace:
     sed 's/old/new/g' file        sed -i (edit in place — be careful!)
     sed '/pattern/d'  (delete lines)     sed -n '5,10p' (print range)

  ✅ awk — Columns & Logic:
     $1, $2... = fields    NF = field count    NR = line number
     -F: sets separator    BEGIN/END blocks for setup/summary

  ✅ Pipeline Building:
     Build incrementally — test each stage before adding the next!

  ✅ Other Tools:
     tr (translate chars)   tee (split output)   xargs (pipe→arguments)
     paste/join (combine files)   diff (compare files)

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 4 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

GREP                            SED                                    AWK
──────────────────────         ─────────────────────                ───────────────────
grep "x" f         Search       sed 's/old/new/' f  Replace 1st        sed-like: awk '/x/' f
grep -i "x" f       Case-ins    sed 's/o/n/g' f      Replace all         awk -F: '{print $1}'
grep -v "x" f       Invert      sed -i 's/o/n/g' f   Edit in-place        awk '$3>100' f
grep -c "x" f       Count       sed '/x/d' f         Delete lines         awk '{sum+=$1} END{print sum}'
grep -r "x" dir     Recursive   sed -n '5,10p' f     Print range          NF / NR / $0 / $NF

CUT / SORT / UNIQ                      PIPES & REDIRECTS                      OTHER TOOLS
──────────────────────                ─────────────────────                ───────────────────
cut -d: -f1 f       Field 1            cmd1 | cmd2          Pipe                tr 'a-z' 'A-Z'   Case
sort f              Alpha sort         cmd > file           Overwrite           tee file          Split out
sort -n f           Numeric            cmd >> file          Append              xargs cmd         Args from pipe
sort -k2 f          By column          cmd 2> file           Errors only         paste f1 f2      Merge cols
uniq -c             Count dups         cmd > /dev/null 2>&1  Silence all         diff f1 f2       Compare

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 4 Interview Questions

| #   | Question                                                    | Key Answer Points                                                                                    |
| --- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| 1   | What's the difference between `>` and `>>`?                 | `>` overwrites the file; `>>` appends to the end                                                     |
| 2   | Why do we use `2>&1`?                                       | To redirect STDERR (fd 2) into wherever STDOUT (fd 1) currently points                               |
| 3   | What does `grep -v` do?                                     | Inverts the match — shows lines that DON'T match the pattern                                         |
| 4   | Why must you `sort` before `uniq`?                          | `uniq` only removes ADJACENT duplicate lines, not all duplicates globally                            |
| 5   | What's the danger of `sed -i`?                              | It edits the file directly with no undo — always test without `-i` first or use `-i.bak`             |
| 6   | What is `$0` vs `$1` in awk?                                | `$0` is the entire line; `$1` is the first field/column                                              |
| 7   | What does `NF` mean in awk?                                 | Number of Fields — the total column count in the current line                                        |
| 8   | When would you use awk instead of grep?                     | When you need column-based logic, calculations, or conditional processing, not just pattern matching |
| 9   | What's the difference between `grep`, `egrep`, and `fgrep`? | grep=basic regex, egrep=extended regex (+, ?,                                                        |
| 10  | Why does `find . -name "\*.log"                             | rm`fail but`                                                                                         |
| 11  | How would you count unique IPs in a log file?               | `awk '{print $1}' access.log \| sort -u \| wc -l`                                                    |
| 12  | What's the purpose of `tee`?                                | Sends output to BOTH the screen and a file simultaneously                                            |

## 🔬 Practical Lab: Chapter 4 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: grep Practice
# ──────────────────────────────────────────────────────────────────
grep "bash" /etc/passwd
grep -c "bash" /etc/passwd
grep -v "nologin" /etc/passwd
grep -n "root" /etc/passwd
grep -E "bash|sh$" /etc/passwd
sudo grep -i "failed" /var/log/auth.log 2>/dev/null | head -5

# ──────────────────────────────────────────────────────────────────
# LAB 2: cut, sort, uniq Practice
# ──────────────────────────────────────────────────────────────────
cut -d: -f1 /etc/passwd | head -10
cut -d: -f1,3 /etc/passwd | head -10
cut -d: -f7 /etc/passwd | sort | uniq -c          # Count shells used
awk -F: '{print $7}' /etc/passwd | sort | uniq -c # Same thing, with awk!

# ──────────────────────────────────────────────────────────────────
# LAB 3: sed Practice (SAFE — work on a copy!)
# ──────────────────────────────────────────────────────────────────
cp /etc/passwd ~/passwd_copy.txt
sed 's/bash/zsh/' ~/passwd_copy.txt | head -5
sed -n '1,5p' ~/passwd_copy.txt
sed '/nologin/d' ~/passwd_copy.txt | head -5
sed -i.bak 's/bash/SHELL_CHANGED/g' ~/passwd_copy.txt
diff ~/passwd_copy.txt.bak ~/passwd_copy.txt | head -5

# ──────────────────────────────────────────────────────────────────
# LAB 4: awk Practice
# ──────────────────────────────────────────────────────────────────
awk -F: '{print $1}' /etc/passwd | head -10
awk -F: '$3 >= 1000 {print $1, $3}' /etc/passwd
awk -F: '{print NF}' /etc/passwd | sort -u
ps aux | awk '{print $2, $3, $11}' | head -10
free -m | awk 'NR==2{printf "Memory used: %.2f%%\n", $3*100/$2}'

# ──────────────────────────────────────────────────────────────────
# LAB 5: Pipeline Mastery Challenge
# ──────────────────────────────────────────────────────────────────
# Build this step by step, testing at each stage:
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn | head -5
# (Shows which users own the most running processes)

cat /etc/passwd | awk -F: '{print $7}' | sort | uniq -c | sort -rn
# (Shows which shells are most commonly assigned)

find /var/log -name "*.log" 2>/dev/null | xargs -I {} wc -l {} 2>/dev/null | sort -rn | head -5
# (Shows the 5 longest log files on the system)
```

## 🧠 Mini Project: Log Analyzer Script

```bash
cat > ~/log_analyzer.sh << 'EOF'
#!/bin/bash
# ─────────────────────────────────────────────
# Chapter 4 Mini Project: Simple Log Analyzer
# Usage: ./log_analyzer.sh /path/to/logfile
# ─────────────────────────────────────────────

LOGFILE="${1:-/var/log/syslog}"

if [ ! -f "$LOGFILE" ]; then
    echo "Log file not found: $LOGFILE"
    exit 1
fi

echo "========================================"
echo "   LOG ANALYZER REPORT"
echo "   File: $LOGFILE"
echo "   $(date)"
echo "========================================"
echo ""

echo "─── TOTAL LINES ────────────────────────"
wc -l < "$LOGFILE"
echo ""

echo "─── ERROR COUNT ────────────────────────"
grep -ic "error" "$LOGFILE"
echo ""

echo "─── WARNING COUNT ──────────────────────"
grep -ic "warning" "$LOGFILE"
echo ""

echo "─── TOP 5 MOST FREQUENT WORDS (4+ chars) ─"
grep -oE '\b[a-zA-Z]{4,}\b' "$LOGFILE" | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -5
echo ""

echo "─── LAST 5 ERROR LINES ─────────────────"
grep -i "error" "$LOGFILE" | tail -5
echo ""

echo "========================================"
echo "   END OF REPORT"
echo "========================================"
EOF

chmod +x ~/log_analyzer.sh
bash ~/log_analyzer.sh /var/log/syslog
```

## 🗺️ Where You Are in the Linux Roadmap

```
LINUX MASTERY ROADMAP — YOUR PROGRESS
═══════════════════════════════════════════════════════════════════

  ✅ Chapter 1:  Hardware, Boot, OS, Kernel, History, First Commands
  ✅ Chapter 2:  Linux Filesystem (FHS, /proc, /sys, /dev, inodes, links)
  ✅ Chapter 3:  Users, Groups & Permissions (chmod, chown, SUID, ACLs)
  ✅ Chapter 4:  Text Processing (grep, sed, awk, cut, sort, pipelines)
  ⬜ Chapter 5:  Package Management (apt, yum, dnf, pacman)
  ⬜ Chapter 6:  Shell Scripting (bash, variables, loops, functions)
  ⬜ Chapter 7:  Process Management (ps, top, signals, jobs)
  ⬜ Chapter 8:  Networking (TCP/IP, DNS, SSH, firewall)
  ⬜ Chapter 9:  System Administration (systemd, logging, cron)
  ⬜ Chapter 10: Linux Security (PAM, SELinux, encryption)
  ⬜ Chapter 11: Containers (Docker, namespaces, cgroups)
  ⬜ Chapter 12: Linux Kernel Development

═══════════════════════════════════════════════════════════════════
  YOU ARE HERE: ✅✅✅✅ — Four chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

Next: [Chapter 5 — Package Management: apt, yum, dnf, and Installing Software the Right Way](/chapter-5.md)

---
