# CHAPTER 6: SHELL SCRIPTING

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 6
═══════════════════════════════════════════════════════════════
  PART A  →  What Is a Shell? Shell Types Explained
  PART B  →  Your First Script — Shebang, Permissions, Execution
  PART C  →  Variables — Storing and Using Data
  PART D  →  User Input & Command-Line Arguments
  PART E  →  Conditionals — Making Decisions
  PART F  →  Loops — Repeating Actions
  PART G  →  Functions — Reusable Code Blocks
  PART H  →  Arrays — Lists of Data
  PART I  →  String & Arithmetic Operations
  PART J  →  Debugging Your Scripts
  PART K  →  Real Automation Projects
  PART L  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: WHAT IS A SHELL? SHELL TYPES EXPLAINED

## 🐚 The Shell — Your Command Translator

The **shell** is a program that reads what you type, interprets it, and tells the kernel what to do. It sits exactly at Layer 6 of the architecture diagram from Chapter 1.

```
WHERE THE SHELL FITS
═══════════════════════════════════════════════════════════════
  YOU type:  ls -la
       │
       ▼
  SHELL interprets it, finds the "ls" program, runs it
       │
       ▼
  KERNEL executes the program, returns results
       │
       ▼
  SHELL displays the output back to YOU
═══════════════════════════════════════════════════════════════
```

## 🔢 Common Shell Types

| Shell  | Full Name                  | Notes                                                |
| ------ | -------------------------- | ---------------------------------------------------- |
| `sh`   | Bourne Shell               | The original, 1977. Minimal features.                |
| `bash` | Bourne Again Shell         | Most common default shell on Linux today             |
| `zsh`  | Z Shell                    | Default on macOS, more features, plugins (Oh My Zsh) |
| `fish` | Friendly Interactive Shell | Beginner-friendly, great autocomplete                |
| `dash` | Debian Almquist Shell      | Lightweight, used for `/bin/sh` on Debian/Ubuntu     |
| `ksh`  | Korn Shell                 | Used in some enterprise/UNIX environments            |

```bash
echo $SHELL                  # Your current login shell
cat /etc/shells              # All shells installed on the system
chsh -s /bin/zsh             # Change your default shell
bash --version               # Check your bash version
```

> **📌 Key Point:** This book focuses on **bash** because it's the universal default across nearly every Linux distribution and is what most production servers, CI/CD pipelines, and DevOps tooling assume by default.

## 💻 Interactive Shell vs Script

```
TWO WAYS TO USE A SHELL
═══════════════════════════════════════════════════════════════
  INTERACTIVE MODE                  SCRIPT MODE
  ───────────────────               ─────────────
  You type commands one             You write commands into a
  at a time, see results            FILE, then run the whole
  immediately                       file at once

  Example: typing "ls" at           Example: a file called
  your terminal prompt              backup.sh containing 50
                                     commands, run in one go
═══════════════════════════════════════════════════════════════
```

---

# PART B: YOUR FIRST SCRIPT — SHEBANG, PERMISSIONS, EXECUTION

## 📝 Writing "Hello World"

```bash
# Create the script file
cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello, Linux World!"
EOF

# Make it executable
chmod +x hello.sh

# Run it
./hello.sh
```

## 🔫 The Shebang Line — `#!/bin/bash`

```
SHEBANG LINE EXPLAINED
═══════════════════════════════════════════════════════════════════
  #!/bin/bash
  ││  └────┬───┘
  ││       └─ Path to the interpreter that should run this script
  │└─ "!" — together with # this is called a "shebang" or "hashbang"
  └─ "#" — normally a comment, but at LINE 1 it's special

  Without a shebang, the script runs using YOUR CURRENT shell,
  which might not be bash! Always specify it explicitly.

  Other common shebangs:
  #!/bin/sh          → POSIX-compliant shell (more portable, fewer features)
  #!/usr/bin/env bash → finds bash wherever it is in $PATH (most portable!)
  #!/usr/bin/python3  → for Python scripts
═══════════════════════════════════════════════════════════════════
```

## ▶️ Three Ways to Run a Script

```bash
./script.sh              # Method 1: Direct execution (needs +x permission AND shebang)
bash script.sh            # Method 2: Explicitly call bash (doesn't need +x!)
source script.sh           # Method 3: Run in CURRENT shell (affects your terminal's variables!)
. script.sh                # Same as "source" — just shorthand
```

```
./script.sh vs source script.sh — THE KEY DIFFERENCE
═══════════════════════════════════════════════════════════════════
  ./script.sh                         source script.sh
  ─────────────                       ──────────────────
  Runs in a NEW subshell               Runs in your CURRENT shell
  Variables set inside DON'T            Variables set inside DO
  persist after the script ends         persist after it finishes!
  (the subshell closes and takes
   its variables with it)               This is why "source ~/.bashrc"
                                         actually updates YOUR terminal,
                                         while "./~/.bashrc" wouldn't!
═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"You run a script that does `cd /tmp`, but after it finishes, you're still in your original directory. Why?"_ **Answer:** The script ran in a child subshell (`./script.sh`), and `cd` only changed the DIRECTORY of that subshell. When the script exited, the subshell was destroyed along with its state. To make `cd` affect your current shell, you'd need to `source` the script instead.

## 🔐 Permissions Recap (from Chapter 3!)

```bash
chmod +x script.sh          # Add execute permission for everyone
chmod u+x script.sh         # Add execute permission for owner only
ls -l script.sh             # Verify the 'x' bit is present
```

---

# PART C: VARIABLES — STORING AND USING DATA

## 📦 Declaring and Using Variables

```bash
name="Ahmed"                # NO spaces around the = sign!
echo $name                  # Ahmed
echo "$name"                # Ahmed (quoted — safer, see below)
echo "${name}"              # Ahmed (curly braces — clearest, especially when concatenating)

age=25
echo "Age: $age"

# ⚠️ COMMON MISTAKE: spaces around =
name = "Ahmed"               # ERROR! Bash thinks "name" is a COMMAND
```

```
WHY ${} IS SAFER THAN $name
═══════════════════════════════════════════════════════════════
  name="Ahmed"
  echo "$nameXYZ"        → outputs NOTHING (bash looks for $nameXYZ!)
  echo "${name}XYZ"      → outputs "AhmedXYZ" ✅ (curly braces clarify)
═══════════════════════════════════════════════════════════════
```

## 🌍 Environment Variables vs Local (Shell) Variables

```
ENVIRONMENT vs LOCAL VARIABLES
═══════════════════════════════════════════════════════════════════
  LOCAL VARIABLE                    ENVIRONMENT VARIABLE
  ─────────────────                 ──────────────────────
  name="Ahmed"                      export name="Ahmed"
  Only visible in THIS shell        Visible to THIS shell AND any
  (and not passed to child           CHILD PROCESSES it launches
  processes/scripts it runs)         (like scripts it calls)
═══════════════════════════════════════════════════════════════════
```

```bash
export MY_VAR="hello"          # Make it an environment variable
env                              # List ALL environment variables
printenv                         # Same as env
printenv PATH                    # Show just one variable
echo $PATH                       # Show PATH (where bash searches for commands)
unset MY_VAR                     # Delete/unset a variable
```

## ⭐ Special Built-in Variables

| Variable        | Meaning                                                           |
| --------------- | ----------------------------------------------------------------- |
| `$0`            | The script's own name                                             |
| `$1`, `$2`, ... | Positional arguments (1st, 2nd argument passed to script)         |
| `$#`            | Number of arguments passed                                        |
| `$@`            | All arguments, as SEPARATE words                                  |
| `$*`            | All arguments, as ONE single string                               |
| `$?`            | Exit status of the LAST command (0 = success, non-zero = failure) |
| `$$`            | Process ID (PID) of the current script/shell                      |
| `$USER`         | Current username                                                  |
| `$HOME`         | Current user's home directory                                     |
| `$PWD`          | Current working directory                                         |
| `$RANDOM`       | A random number                                                   |

```bash
cat > argstest.sh << 'EOF'
#!/bin/bash
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "Total arguments: $#"
echo "All arguments (\$@): $@"
echo "Process ID: $$"
EOF
chmod +x argstest.sh
./argstest.sh apple banana

# Output:
# Script name: ./argstest.sh
# First argument: apple
# Second argument: banana
# Total arguments: 2
# All arguments ($@): apple banana
# Process ID: 12345
```

```bash
# $? in action — checking if a command succeeded
mkdir /tmp/testdir
echo $?              # 0 = SUCCESS

mkdir /root/no_permission_dir
echo $?              # Non-zero (likely 1) = FAILURE
```

> **🎓 Interview Question:** _"What's the difference between `$@` and `$*`?"_ **Answer:** Both represent all arguments, but `"$@"` (quoted) expands each argument as a SEPARATE quoted string (preserving spaces within arguments), while `"$*"` expands them as ONE single string joined by spaces. In loops, `"$@"` is almost always what you want.

## 🔗 Command Substitution

```bash
current_date=$(date)                  # Modern syntax (preferred)
current_date=`date`                   # Old backtick syntax (still works, harder to read/nest)
echo "Today is: $current_date"

file_count=$(ls | wc -l)
echo "Files in this directory: $file_count"

# Nesting command substitution (easy with $())
echo "Kernel: $(uname -r), on $(hostname)"
```

## 🧮 Quoting Rules — Critical for Avoiding Bugs

```
QUOTING IN BASH
═══════════════════════════════════════════════════════════════════
  'single quotes'     → LITERAL. Nothing is interpreted, not even $variables
  "double quotes"     → Variables and $(commands) ARE expanded
  no quotes            → DANGEROUS: word-splitting and glob expansion happen!

  Example:
  name="Ahmed"
  echo 'Hello $name'     → Hello $name        (literal, no expansion)
  echo "Hello $name"     → Hello Ahmed         (expanded)
  echo Hello $name        → Hello Ahmed         (works here, but risky generally)
═══════════════════════════════════════════════════════════════════
```

```bash
# Why unquoted variables are dangerous:
file="my document.txt"
rm $file                    # ❌ Tries to delete TWO files: "my" and "document.txt"!
rm "$file"                  # ✅ Correctly deletes ONE file: "my document.txt"
```

---

# PART D: USER INPUT & COMMAND-LINE ARGUMENTS

## ⌨️ `read` — Getting Input From the User

```bash
#!/bin/bash
echo "What's your name?"
read name
echo "Hello, $name!"

# All on one line with a prompt
read -p "Enter your age: " age
echo "You are $age years old"

# Silent input (for passwords!)
read -sp "Enter password: " password
echo ""                       # Newline since -s hides the Enter keypress too
echo "Password received (hidden)"

# Reading multiple values at once
read -p "Enter first and last name: " first last
echo "First: $first, Last: $last"

# Setting a timeout
read -t 5 -p "Answer within 5 seconds: " answer
```

## 📥 Command-Line Arguments (Revisited with Validation)

```bash
#!/bin/bash
# A script expecting exactly 2 arguments

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source> <destination>"
    exit 1
fi

source_file="$1"
dest_file="$2"
echo "Copying $source_file to $dest_file"
```

```bash
# Looping through ALL arguments, regardless of how many
for arg in "$@"; do
    echo "Got argument: $arg"
done
```

---

# PART E: CONDITIONALS — MAKING DECISIONS

## 🔀 if / elif / else

```bash
#!/bin/bash
age=20

if [ $age -ge 18 ]; then
    echo "You are an adult"
elif [ $age -ge 13 ]; then
    echo "You are a teenager"
else
    echo "You are a child"
fi
```

```
if STATEMENT STRUCTURE
═══════════════════════════════════════════════════════════════
  if [ CONDITION ]; then
      # code if true
  elif [ ANOTHER_CONDITION ]; then
      # code if that's true
  else
      # code if nothing matched
  fi          ← MUST close with "fi" (if backwards!)
═══════════════════════════════════════════════════════════════
```

## 🧪 Test Operators — `[ ]` vs `[[ ]]`

```
[ ] vs [[ ]]
═══════════════════════════════════════════════════════════════════
  [ ]   → Classic POSIX test command. More portable (works in sh too).
          Requires spaces around brackets, careful quoting.
  [[ ]] → Bash-specific extended test. Safer, supports &&, ||, =~ (regex),
          doesn't word-split unquoted variables. PREFERRED in bash scripts.
═══════════════════════════════════════════════════════════════════
```

### Numeric Comparison Operators

| Operator | Meaning                  |
| -------- | ------------------------ |
| `-eq`    | Equal to                 |
| `-ne`    | Not equal to             |
| `-gt`    | Greater than             |
| `-lt`    | Less than                |
| `-ge`    | Greater than or equal to |
| `-le`    | Less than or equal to    |

```bash
[ 5 -eq 5 ]      # true
[ 5 -ne 3 ]      # true
[ 5 -gt 3 ]      # true
```

### String Comparison Operators

| Operator    | Meaning                                                      |
| ----------- | ------------------------------------------------------------ |
| `=` or `==` | Equal (use `==` only inside `[[ ]]`)                         |
| `!=`        | Not equal                                                    |
| `-z`        | String is empty (zero length)                                |
| `-n`        | String is NOT empty                                          |
| `<` `>`     | Alphabetical comparison (needs `[[ ]]` or escaping in `[ ]`) |

```bash
name="ahmed"
if [[ "$name" == "ahmed" ]]; then echo "Match!"; fi
if [[ -z "$name" ]]; then echo "Name is empty"; fi
if [[ -n "$name" ]]; then echo "Name is NOT empty"; fi
```

### File Test Operators

| Operator | Meaning                      |
| -------- | ---------------------------- |
| `-e`     | File exists                  |
| `-f`     | Regular file exists          |
| `-d`     | Directory exists             |
| `-r`     | File is readable             |
| `-w`     | File is writable             |
| `-x`     | File is executable           |
| `-s`     | File exists and is NOT empty |
| `-L`     | File is a symbolic link      |

```bash
if [ -f "/etc/passwd" ]; then
    echo "passwd file exists"
fi

if [ -d "/home/ahmed" ]; then
    echo "ahmed's home directory exists"
fi

if [ ! -f "config.txt" ]; then
    echo "Config file is MISSING — creating default..."
    touch config.txt
fi
```

### Logical Operators

```bash
# AND (&&) — both must be true
if [ -f "file.txt" ] && [ -r "file.txt" ]; then
    echo "File exists AND is readable"
fi

# OR (||) — at least one must be true
if [ "$user" = "admin" ] || [ "$user" = "root" ]; then
    echo "Privileged user"
fi

# NOT (!)
if [ ! -d "/tmp/cache" ]; then
    mkdir /tmp/cache
fi

# Bash-specific with [[ ]] (cleaner syntax)
if [[ -f "file.txt" && -r "file.txt" ]]; then
    echo "Exists and readable"
fi
```

## 🎯 `case` Statement — Cleaner Multi-Branch Logic

```bash
#!/bin/bash
read -p "Enter a fruit: " fruit

case $fruit in
    apple)
        echo "Apples are red or green"
        ;;
    banana)
        echo "Bananas are yellow"
        ;;
    orange|tangerine)
        echo "Citrus fruit!"
        ;;
    *)
        echo "Unknown fruit"
        ;;
esac
```

```
case STATEMENT STRUCTURE
═══════════════════════════════════════════════════════════════
  case $variable in
      pattern1)
          commands
          ;;          ← double semicolon ends EACH branch
      pattern2|pattern3)
          commands     ← "|" means "OR" between patterns
          ;;
      *)
          default commands   ← "*" = catch-all, like "else"
          ;;
  esac        ← MUST close with "esac" (case backwards!)
═══════════════════════════════════════════════════════════════
```

### Real-World Example: A Service Control Script Using case

```bash
#!/bin/bash
case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking status..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
```

---

# PART F: LOOPS — REPEATING ACTIONS

## 🔁 `for` Loop

```bash
# Loop over a list of values
for fruit in apple banana orange; do
    echo "I like $fruit"
done

# Loop over a RANGE of numbers
for i in {1..5}; do
    echo "Number: $i"
done

# Loop with a step value
for i in {0..10..2}; do
    echo "Even: $i"
done

# C-style for loop
for ((i=1; i<=5; i++)); do
    echo "Count: $i"
done

# Loop over files matching a pattern (globbing)
for file in *.txt; do
    echo "Found text file: $file"
done

# Loop over command output
for user in $(cut -d: -f1 /etc/passwd); do
    echo "User: $user"
done

# Loop over array elements (more on arrays in Part H)
fruits=("apple" "banana" "orange")
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done
```

## 🔄 `while` Loop

```bash
# Basic while loop
count=1
while [ $count -le 5 ]; do
    echo "Count is: $count"
    count=$((count + 1))
done

# Reading a file line by line (VERY common real-world pattern!)
while IFS= read -r line; do
    echo "Line: $line"
done < input.txt

# Infinite loop (use with break, or for daemons/monitoring scripts)
while true; do
    echo "Monitoring... (Ctrl+C to stop)"
    sleep 5
done
```

> **🎓 Interview Question:** _"Why use `while IFS= read -r line` instead of `for line in $(cat file)`?"_ **Answer:** The `for` approach splits on whitespace and mangles lines with spaces or special characters; `while IFS= read -r line` reads the file line-by-line correctly, preserving whitespace and not interpreting backslashes, making it the SAFE and CORRECT way to process files line by line.

## ⏳ `until` Loop — The Opposite of `while`

```bash
# Repeats UNTIL the condition becomes TRUE (opposite logic of while)
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done

# Real-world example: wait until a service is up
until curl -s http://localhost:8080 > /dev/null; do
    echo "Waiting for service to start..."
    sleep 2
done
echo "Service is up!"
```

## ⏭️ `break` and `continue`

```bash
# break — exit the loop entirely
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        break
    fi
    echo "Number: $i"
done
# Prints 1, 2, 3, 4 — stops at 5

# continue — skip to the NEXT iteration
for i in {1..10}; do
    if [ $((i % 2)) -eq 0 ]; then
        continue          # Skip even numbers
    fi
    echo "Odd number: $i"
done
# Prints only odd numbers: 1, 3, 5, 7, 9
```

```
break vs continue
═══════════════════════════════════════════════════════════════
  break       → STOP the loop completely, jump past it
  continue    → SKIP just this iteration, go to the NEXT one
═══════════════════════════════════════════════════════════════
```

---

# PART G: FUNCTIONS — REUSABLE CODE BLOCKS

## 🧩 Defining and Calling Functions

```bash
# Method 1 (preferred style)
greet() {
    echo "Hello, $1!"
}

# Method 2 (also valid)
function greet2 {
    echo "Hi there, $1!"
}

# Calling functions
greet "Ahmed"             # Hello, Ahmed!
greet2 "Fatima"            # Hi there, Fatima!
```

```
FUNCTION ARGUMENTS WORK LIKE SCRIPT ARGUMENTS!
═══════════════════════════════════════════════════════════════
  Inside a function:
  $1, $2, $3...  → arguments passed to the FUNCTION (not the script!)
  $#             → number of arguments passed to the FUNCTION
  $@             → all arguments passed to the FUNCTION
═══════════════════════════════════════════════════════════════
```

## 🔙 Return Values

```bash
#!/bin/bash
# Functions can "return" an EXIT STATUS (0-255), NOT arbitrary data!

is_even() {
    if [ $(($1 % 2)) -eq 0 ]; then
        return 0       # 0 = success/true in bash convention
    else
        return 1       # non-zero = failure/false
    fi
}

if is_even 4; then
    echo "4 is even"
fi

# To return ACTUAL DATA (like a string or number), use echo + command substitution:
get_full_name() {
    echo "$1 $2"
}

fullname=$(get_full_name "Ahmed" "Khan")
echo "Full name: $fullname"
```

> **⚠️ Common Mistake:** Beginners try to `return "some text"` expecting it to work like other languages. In bash, `return` ONLY accepts a numeric exit status (0-255). To return actual DATA, use `echo` inside the function and capture it with `$(function_name)`.

## 🌐 Local vs Global Variables in Functions

```bash
my_function() {
    local local_var="I'm local"     # ONLY visible inside this function
    global_var="I'm global"          # Visible EVERYWHERE (no 'local' keyword)
}

my_function
echo "$global_var"     # Works: "I'm global"
echo "$local_var"       # Empty! local_var doesn't exist outside the function
```

---

# PART H: ARRAYS — LISTS OF DATA

## 📚 Declaring and Using Arrays

```bash
# Declare an array
fruits=("apple" "banana" "orange" "grape")

# Access elements (ZERO-indexed!)
echo "${fruits[0]}"          # apple
echo "${fruits[1]}"          # banana
echo "${fruits[-1]}"         # grape (last element, bash 4.3+)

# Print ALL elements
echo "${fruits[@]}"          # apple banana orange grape

# Print the NUMBER of elements
echo "${#fruits[@]}"         # 4

# Print the LENGTH of one element
echo "${#fruits[0]}"         # 5 (length of "apple")

# Add an element
fruits+=("mango")
echo "${fruits[@]}"          # apple banana orange grape mango

# Loop through an array
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Loop with INDEX too
for i in "${!fruits[@]}"; do
    echo "Index $i: ${fruits[$i]}"
done

# Remove an element (by index)
unset fruits[1]               # Removes "banana"
echo "${fruits[@]}"            # apple orange grape mango (gap in indices!)

# Slice an array
echo "${fruits[@]:1:2}"        # Elements starting at index 1, taking 2 elements
```

## 🗺️ Associative Arrays (Key-Value Pairs, Bash 4+)

```bash
declare -A capitals
capitals["USA"]="Washington DC"
capitals["France"]="Paris"
capitals["Japan"]="Tokyo"

echo "${capitals[France]}"           # Paris

# Loop through KEYS
for country in "${!capitals[@]}"; do
    echo "$country -> ${capitals[$country]}"
done
```

```
INDEXED vs ASSOCIATIVE ARRAYS
═══════════════════════════════════════════════════════════════
  INDEXED ARRAY                     ASSOCIATIVE ARRAY
  ───────────────                   ──────────────────
  arr=("a" "b" "c")                 declare -A arr
  Access by NUMBER: arr[0]          arr["key"]="value"
  Order matters                     Access by NAME: arr["key"]
                                     Like a dictionary/hashmap
═══════════════════════════════════════════════════════════════
```

---

# PART I: STRING & ARITHMETIC OPERATIONS

## 🔢 Arithmetic in Bash

```bash
# Method 1: $(( )) — the standard, preferred way
result=$((5 + 3))
echo $result                # 8

a=10
b=3
echo $((a + b))              # 13
echo $((a - b))              # 7
echo $((a * b))              # 30
echo $((a / b))              # 3  (integer division — no decimals!)
echo $((a % b))              # 1  (modulo/remainder)
echo $((a ** b))             # 1000 (exponent)

# Increment/decrement
count=5
count=$((count + 1))         # count is now 6
((count++))                  # Alternative increment syntax
((count--))                  # Decrement

# Method 2: let
let result=5+3
echo $result                  # 8

# Method 3: expr (older, slower, rarely used now)
result=$(expr 5 + 3)

# For DECIMAL/floating-point math, bash needs help from bc:
result=$(echo "5.5 + 3.2" | bc)
echo $result                  # 8.7
```

> **🎓 Common Mistake:** `$((5 / 2))` gives `2`, NOT `2.5`! Bash only does INTEGER arithmetic natively. For floating-point math, pipe to `bc` or use tools like `awk`.

## ✂️ String Manipulation

```bash
str="Hello World"

echo "${#str}"                  # 11 (length of string)
echo "${str:0:5}"                # Hello (substring: start at 0, length 5)
echo "${str:6}"                  # World (substring from position 6 to end)
echo "${str^^}"                  # HELLO WORLD (uppercase, bash 4+)
echo "${str,,}"                  # hello world (lowercase, bash 4+)
echo "${str/World/Linux}"        # Hello Linux (replace FIRST match)
echo "${str//o/0}"                # Hell0 W0rld (replace ALL matches)

filename="document.tar.gz"
echo "${filename%.gz}"            # document.tar  (remove shortest match from END)
echo "${filename%%.*}"            # document      (remove LONGEST match from END)
echo "${filename#*.}"             # tar.gz         (remove shortest match from START)
echo "${filename##*.}"            # gz             (remove LONGEST match from START — get extension!)
```

```
STRING TRIMMING CHEAT SHEET (THE CONFUSING ONE!)
═══════════════════════════════════════════════════════════════════
  ${var#pattern}    → Remove SHORTEST match from the START
  ${var##pattern}   → Remove LONGEST match from the START
  ${var%pattern}    → Remove SHORTEST match from the END
  ${var%%pattern}   → Remove LONGEST match from the END

  Memory trick: # is near the START of the keyboard's top row,
  % is more towards the END. (Not perfect, but it helps some!)

  Most common real use: getting a file extension
  filename="archive.tar.gz"
  echo "${filename##*.}"    →  gz   (everything after the LAST dot)
═══════════════════════════════════════════════════════════════════
```

---

# PART J: DEBUGGING YOUR SCRIPTS

## 🐛 Built-in Debugging Tools

```bash
# Run a script in DEBUG mode — shows every command before executing it
bash -x script.sh

# Or add this INSIDE the script itself, at the top:
#!/bin/bash
set -x          # Turn ON debug mode from this point forward
# ... your commands ...
set +x          # Turn OFF debug mode

# Other useful "set" options for safer scripts:
set -e          # EXIT immediately if any command fails (non-zero exit code)
set -u          # Treat USE of an undefined variable as an ERROR
set -o pipefail # Make a pipeline fail if ANY command in it fails (not just the last)

# The "strict mode" combo many professional scripts start with:
#!/bin/bash
set -euo pipefail
```

```
WHY set -euo pipefail MATTERS
═══════════════════════════════════════════════════════════════════
  WITHOUT it:                        WITH it:
  ────────────                       ─────────
  A script keeps running even        Script STOPS IMMEDIATELY at the
  after a command fails —             first error, preventing it from
  potentially causing DAMAGE          continuing with bad/missing data
  with bad assumptions                 — much safer for automation!

  Example disaster WITHOUT -e:
  cd /nonexistent_folder    (fails silently, stays in old dir)
  rm -rf *                  (deletes everything in the WRONG folder!)

  WITH set -e: the script would have STOPPED right after the
  failed "cd", never reaching the dangerous "rm -rf *"
═══════════════════════════════════════════════════════════════════
```

## 🔍 Manual Debugging Techniques

```bash
# Add echo statements to trace execution
echo "DEBUG: about to process file $filename"

# Check exit codes after important commands
some_command
if [ $? -ne 0 ]; then
    echo "ERROR: some_command failed!"
    exit 1
fi

# Validate your script's SYNTAX without running it
bash -n script.sh             # -n = "no execute", just check syntax

# Use shellcheck — the industry-standard bash linter (install separately)
shellcheck script.sh
```

---

# PART K: REAL AUTOMATION PROJECTS

## 🚀 Project 1: Automated Backup Script

```bash
cat > ~/backup.sh << 'EOF'
#!/bin/bash
set -euo pipefail

SOURCE_DIR="$HOME/Documents"
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="backup_${DATE}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "Starting backup of $SOURCE_DIR..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR"

if [ $? -eq 0 ]; then
    echo "✅ Backup successful: $BACKUP_DIR/$BACKUP_FILE"
    SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    echo "Backup size: $SIZE"
else
    echo "❌ Backup failed!"
    exit 1
fi

# Keep only the last 5 backups (cleanup old ones)
cd "$BACKUP_DIR"
ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm
echo "Old backups cleaned up. Current backups:"
ls -lh "$BACKUP_DIR"
EOF

chmod +x ~/backup.sh
```

## 🚀 Project 2: Server Health Monitor

```bash
cat > ~/healthmon.sh << 'EOF'
#!/bin/bash
set -uo pipefail

THRESHOLD_CPU=80
THRESHOLD_DISK=80
THRESHOLD_MEM=80

echo "=========================================="
echo "  SERVER HEALTH CHECK — $(date)"
echo "=========================================="

# CPU check
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo "CPU Usage: ${cpu_usage}%"
if (( $(echo "$cpu_usage > $THRESHOLD_CPU" | bc -l) )); then
    echo "⚠️  WARNING: CPU usage is above ${THRESHOLD_CPU}%!"
fi

# Memory check
mem_usage=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
echo "Memory Usage: ${mem_usage}%"
if [ "$mem_usage" -gt "$THRESHOLD_MEM" ]; then
    echo "⚠️  WARNING: Memory usage is above ${THRESHOLD_MEM}%!"
fi

# Disk check
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
echo "Disk Usage (/): ${disk_usage}%"
if [ "$disk_usage" -gt "$THRESHOLD_DISK" ]; then
    echo "⚠️  WARNING: Disk usage is above ${THRESHOLD_DISK}%!"
fi

echo "=========================================="
echo "  Health check complete."
echo "=========================================="
EOF

chmod +x ~/healthmon.sh
bash ~/healthmon.sh
```

## 🚀 Project 3: Bulk User Creation Script

```bash
cat > ~/bulk_create_users.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# usernames.txt should have one username per line
USERLIST="$1"

if [ ! -f "$USERLIST" ]; then
    echo "Usage: $0 <userlist_file>"
    exit 1
fi

while IFS= read -r username; do
    if id "$username" &>/dev/null; then
        echo "User $username already exists, skipping."
        continue
    fi

    sudo useradd -m -s /bin/bash "$username"
    temp_password=$(openssl rand -base64 12)
    echo "$username:$temp_password" | sudo chpasswd
    sudo passwd -e "$username"      # Force password change on first login

    echo "✅ Created user: $username (temp password: $temp_password)"
done < "$USERLIST"

echo "Bulk user creation complete!"
EOF

chmod +x ~/bulk_create_users.sh
# Usage: ./bulk_create_users.sh usernames.txt
```

---

# PART L: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 6 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Shell Basics:
     bash = most common shell. Shebang (#!/bin/bash) tells the
     system which interpreter to use. chmod +x to make executable.

  ✅ Variables:
     var="value" (no spaces!)   "${var}" for clarity
     export VAR for environment variables    $(command) for substitution
     ALWAYS quote "$variable" to avoid word-splitting bugs!

  ✅ Special Variables:
     $1 $2... args   $#=count   $@=all args   $?=exit status   $$=PID

  ✅ Conditionals:
     if/elif/else/fi    [[ ]] preferred over [ ] in bash
     -eq -ne -gt -lt (numbers)   = != -z -n (strings)   -f -d -e (files)
     case/esac for clean multi-branch logic

  ✅ Loops:
     for...in / for ((C-style))    while [ cond ]    until [ cond ]
     break (exit loop)   continue (skip iteration)
     while IFS= read -r line — the SAFE way to process files

  ✅ Functions:
     name() { ... }    local for function-scoped variables
     return only sends EXIT CODES (0-255); use echo+$() for actual data

  ✅ Arrays:
     arr=(a b c)   ${arr[0]}   ${arr[@]}   ${#arr[@]}
     declare -A for associative (key-value) arrays

  ✅ Strings & Math:
     $((math))  for integers    bc for decimals
     ${var:0:5} substring   ${var^^} upper   ${var##*.} extension trick

  ✅ Debugging:
     bash -x (trace)   bash -n (syntax check)   set -euo pipefail (strict mode)
     shellcheck — install and use it on every script!

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 6 BASH SCRIPTING CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

VARIABLES                       CONDITIONALS                    LOOPS
──────────────────────         ─────────────────────         ───────────────────
var="x"          Assign         if [ cond ]; then              for i in {1..5}
echo "$var"      Use            elif [ cond ]; then              do ... done
export VAR       Env var        else / fi                      while [ cond ]
$(cmd)           Substitution   [[ a == b ]]   Bash test          do ... done
${var:-default}  Default value  -eq -ne -gt -lt   Numbers       until [ cond ]
${var^^} ${var,,} Upper/lower   = != -z -n        Strings         do ... done
${#var}          Length         -f -d -e          File tests    break / continue

FUNCTIONS                       ARRAYS                          DEBUGGING
──────────────────────         ─────────────────────         ───────────────────
name() { ... }   Define         arr=(a b c)       Create        bash -x script   Trace
local x=1        Local var      ${arr[0]}         Access        bash -n script   Syntax chk
return N         Exit code       ${arr[@]}         All elements  set -x / set +x  Toggle trace
echo "$(f)"      Get data       ${#arr[@]}        Count          set -euo pipefail Strict mode
                                declare -A m       Assoc array    shellcheck file  Lint script

SPECIAL VARS                    STRING TRICKS
──────────────────────         ─────────────────────
$1 $2 ...   Arguments           ${f%.*}    Remove ext (shortest, end)
$#          Arg count           ${f##*.}   Get ext (longest, start)
$@          All args            ${s/a/b}   Replace first match
$?          Exit status         ${s//a/b}  Replace all matches
$$          Process ID          ${s:0:5}   Substring

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 6 Interview Questions

| #   | Question                                                                   | Key Answer Points                                                                                                      |
| --- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| 1   | What is a shebang line?                                                    | `#!/bin/bash` at line 1 — tells the OS which interpreter to use                                                        |
| 2   | Difference between `./script.sh` and `source script.sh`?                   | First runs in a subshell (variables don't persist); second runs in current shell (variables DO persist)                |
| 3   | Why should you quote variables: `"$var"`?                                  | Unquoted variables undergo word-splitting and glob expansion, causing bugs especially with filenames containing spaces |
| 4   | Difference between `[ ]` and `[[ ]]`?                                      | `[[ ]]` is bash-specific, safer (no word-splitting issues), supports `&&`/`\|`/regex; `[ ]` is more portable (POSIX)   |
| 5   | What does `$?` represent?                                                  | The exit status of the last executed command (0 = success, non-zero = failure)                                         |
| 6   | What's the difference between `$@` and `$*`?                               | `"$@"` preserves each argument separately; `"$*"` joins all into one string                                            |
| 7   | Can a bash function return a string?                                       | Not via `return` (numeric exit codes only, 0-255) — use `echo` and capture with `$(function_name)`                     |
| 8   | Why use `local` inside functions?                                          | Prevents variables from leaking into/overwriting the global scope                                                      |
| 9   | What does `set -e` do?                                                     | Causes the script to exit immediately if any command returns a non-zero exit status                                    |
| 10  | Why is `while IFS= read -r line` preferred over `for line in $(cat file)`? | It correctly handles lines with spaces/special characters; `for` would word-split and break on whitespace              |
| 11  | How do you get a file's extension in bash?                                 | `${filename##*.}` — removes everything up to and including the last dot                                                |
| 12  | Why can't bash do `5/2` and get `2.5`?                                     | Bash only supports integer arithmetic natively; decimal math requires external tools like `bc`                         |
| 13  | What does `shellcheck` do?                                                 | A static analysis tool/linter for shell scripts that catches quoting bugs, unused variables, and common mistakes       |

## 🔬 Practical Lab: Chapter 6 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: First Script + Variables
# ──────────────────────────────────────────────────────────────────
mkdir -p ~/lab6 && cd ~/lab6
cat > greet.sh << 'EOF'
#!/bin/bash
name="$1"
if [ -z "$name" ]; then
    name="stranger"
fi
echo "Hello, $name! Today is $(date +%A)."
EOF
chmod +x greet.sh
./greet.sh
./greet.sh Ahmed

# ──────────────────────────────────────────────────────────────────
# LAB 2: Conditionals + File Tests
# ──────────────────────────────────────────────────────────────────
cat > checkfile.sh << 'EOF'
#!/bin/bash
file="$1"
if [ -z "$file" ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi
if [ -f "$file" ]; then
    echo "$file exists."
    if [ -r "$file" ]; then echo "It's readable."; fi
    if [ -w "$file" ]; then echo "It's writable."; fi
else
    echo "$file does NOT exist."
fi
EOF
chmod +x checkfile.sh
./checkfile.sh /etc/passwd
./checkfile.sh /nonexistent

# ──────────────────────────────────────────────────────────────────
# LAB 3: Loops Practice
# ──────────────────────────────────────────────────────────────────
cat > countdown.sh << 'EOF'
#!/bin/bash
for i in {10..1}; do
    echo "$i..."
    sleep 0.3
done
echo "Liftoff! 🚀"
EOF
chmod +x countdown.sh
./countdown.sh

cat > processusers.sh << 'EOF'
#!/bin/bash
while IFS=: read -r username _ uid _ _ _ shell; do
    if [ "$uid" -ge 1000 ] && [ "$uid" -lt 65534 ]; then
        echo "Human user: $username (UID $uid, shell: $shell)"
    fi
done < /etc/passwd
EOF
chmod +x processusers.sh
./processusers.sh

# ──────────────────────────────────────────────────────────────────
# LAB 4: Functions + Arrays
# ──────────────────────────────────────────────────────────────────
cat > toolkit.sh << 'EOF'
#!/bin/bash

is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

square() {
    echo $(( $1 * $1 ))
}

numbers=(2 4 6 8 10)
for n in "${numbers[@]}"; do
    if is_number "$n"; then
        result=$(square "$n")
        echo "$n squared is $result"
    fi
done
EOF
chmod +x toolkit.sh
./toolkit.sh

# ──────────────────────────────────────────────────────────────────
# LAB 5: Debugging Practice
# ──────────────────────────────────────────────────────────────────
cat > buggy.sh << 'EOF'
#!/bin/bash
set -euo pipefail
echo "Step 1"
cd /this/folder/does/not/exist
echo "Step 2 (should never print!)"
EOF
chmod +x buggy.sh
bash -x buggy.sh || echo "Script stopped early due to set -e — exactly as intended!"
```

## 🧠 Mini Project: Interactive System Setup Wizard

```bash
cat > ~/setup_wizard.sh << 'EOF'
#!/bin/bash
set -uo pipefail

echo "=========================================="
echo "   INTERACTIVE SYSTEM SETUP WIZARD"
echo "=========================================="
echo ""

read -p "Enter your project name: " project_name
read -p "Create a backups directory? (y/n): " create_backup

PROJECT_DIR="$HOME/projects/$project_name"
mkdir -p "$PROJECT_DIR"
echo "✅ Created project directory: $PROJECT_DIR"

if [[ "$create_backup" == "y" || "$create_backup" == "Y" ]]; then
    mkdir -p "$PROJECT_DIR/backups"
    echo "✅ Created backups subdirectory"
fi

echo ""
echo "Choose project type:"
select ptype in "Web App" "CLI Tool" "Data Science" "Other"; do
    case $ptype in
        "Web App")
            mkdir -p "$PROJECT_DIR"/{src,public,tests}
            echo "✅ Web app structure created"
            break
            ;;
        "CLI Tool")
            mkdir -p "$PROJECT_DIR"/{bin,lib}
            echo "✅ CLI tool structure created"
            break
            ;;
        "Data Science")
            mkdir -p "$PROJECT_DIR"/{data,notebooks,models}
            echo "✅ Data science structure created"
            break
            ;;
        "Other")
            echo "✅ Basic structure only"
            break
            ;;
        *)
            echo "Invalid option, try again."
            ;;
    esac
done

echo ""
echo "─── PROJECT SUMMARY ────────────────────"
echo "Name: $project_name"
echo "Location: $PROJECT_DIR"
tree -L 2 "$PROJECT_DIR" 2>/dev/null || ls -R "$PROJECT_DIR"
echo "=========================================="
echo "   SETUP COMPLETE! 🎉"
echo "=========================================="
EOF

chmod +x ~/setup_wizard.sh
bash ~/setup_wizard.sh
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
  ⬜ Chapter 7:  Process Management (ps, top, signals, jobs)
  ⬜ Chapter 8:  Networking (TCP/IP, DNS, SSH, firewall)
  ⬜ Chapter 9:  System Administration (systemd, logging, cron)
  ⬜ Chapter 10: Linux Security (PAM, SELinux, encryption)
  ⬜ Chapter 11: Containers (Docker, namespaces, cgroups)
  ⬜ Chapter 12: Linux Kernel Development

═══════════════════════════════════════════════════════════════════
  YOU ARE HERE: ✅✅✅✅✅✅ — Six chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

Next: [Chapter 7 — Process Management: ps, top, signals, and Job Control](/chapter-7.md)

---
