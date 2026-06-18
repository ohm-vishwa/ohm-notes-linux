# CHAPTER 8: NETWORKING

### _TCP/IP, DNS, SSH, and Firewalls_

## 🗺️ Chapter Roadmap

```
What You'll Learn in Chapter 8
═══════════════════════════════════════════════════════════════
  PART A  →  Networking Models — OSI and TCP/IP
  PART B  →  IP Addressing — IPv4, Subnetting, CIDR
  PART C  →  Network Interface Configuration
  PART D  →  DNS — Turning Names Into Addresses
  PART E  →  DHCP — Automatic IP Assignment
  PART F  →  Routing — How Packets Find Their Way
  PART G  →  Ports & Protocols — TCP vs UDP
  PART H  →  SSH — Secure Remote Access Mastery
  PART I  →  Firewalls — iptables, ufw, firewalld
  PART J  →  VPN Basics
  PART K  →  Network Troubleshooting Toolkit
  PART L  →  Chapter Summary + Cheat Sheet + Labs
═══════════════════════════════════════════════════════════════
```

---

# PART A: NETWORKING MODELS — OSI AND TCP/IP

## 🗼 The OSI Model — 7 Layers of Networking

The OSI model is a conceptual framework describing how data travels across a network, broken into 7 layers.

```
THE OSI MODEL (top to bottom)
═══════════════════════════════════════════════════════════════════

  Layer 7  APPLICATION    │ HTTP, FTP, SSH, DNS         │ Your apps/browser
  Layer 6  PRESENTATION   │ Encryption, compression     │ SSL/TLS, encoding
  Layer 5  SESSION        │ Manages connections          │ Login sessions
  Layer 4  TRANSPORT      │ TCP, UDP                     │ Ports, reliability
  Layer 3  NETWORK        │ IP addresses, routing        │ Routers
  Layer 2  DATA LINK      │ MAC addresses, switches      │ Ethernet, WiFi
  Layer 1  PHYSICAL       │ Cables, signals, radio waves │ Hardware itself

  MEMORY TRICK: "Please Do Not Throw Sausage Pizza Away"
                 (Physical, Data link, Network, Transport,
                  Session, Presentation, Application)

═══════════════════════════════════════════════════════════════════
```

## 🌐 The TCP/IP Model — The Practical, Simplified Version

Linux networking is actually built and explained more practically using the 4-layer **TCP/IP model**:

```
TCP/IP MODEL vs OSI MODEL
═══════════════════════════════════════════════════════════════════

  TCP/IP MODEL                       Maps to OSI Layers
  ──────────────                     ───────────────────
  APPLICATION                        Layers 5,6,7 (Session/Presentation/App)
  (HTTP, DNS, SSH, FTP)

  TRANSPORT                          Layer 4 (Transport)
  (TCP, UDP)

  INTERNET                           Layer 3 (Network)
  (IP, routing)

  LINK (Network Access)              Layers 1,2 (Physical/Data Link)
  (Ethernet, WiFi, MAC addresses)

═══════════════════════════════════════════════════════════════════
```

> **📌 Key Point:** Real-world Linux networking tools and troubleshooting map MUCH more cleanly to the 4-layer TCP/IP model. The 7-layer OSI model is more useful for theory/interviews; use the TCP/IP model when actually thinking through a problem.

> **🎓 Interview Question:** _"At which OSI layer does a switch operate? What about a router?"_ **Answer:** A switch operates at Layer 2 (Data Link), forwarding frames based on MAC addresses. A router operates at Layer 3 (Network), forwarding packets based on IP addresses between different networks.

---

# PART B: IP ADDRESSING — IPv4, SUBNETTING, CIDR

## 🔢 What Is an IP Address?

An IP address is a unique numerical label assigned to a device on a network, so other devices can find and communicate with it.

```
IPv4 ADDRESS STRUCTURE
═══════════════════════════════════════════════════════════════
  192    .   168   .    1   .   10
   │         │          │        │
   8 bits   8 bits    8 bits   8 bits   = 32 bits total

  Each section (octet) ranges from 0-255
  Total possible IPv4 addresses: ~4.3 BILLION (and we ran out!)
═══════════════════════════════════════════════════════════════
```

## 🏠 Public vs Private IP Addresses

```
PRIVATE IP RANGES (reserved for internal/home/office networks)
═══════════════════════════════════════════════════════════════════
  10.0.0.0      –  10.255.255.255    (Class A private range)
  172.16.0.0    –  172.31.255.255    (Class B private range)
  192.168.0.0   –  192.168.255.255   (Class C private range — most homes!)

  These addresses are NOT routable on the public internet —
  your router uses NAT (Network Address Translation) to let
  many private devices share ONE public IP address.
═══════════════════════════════════════════════════════════════════
```

```
PUBLIC vs PRIVATE — THE HOME NETWORK ANALOGY
═══════════════════════════════════════════════════════════════════

           INTERNET
               │
       Public IP: 84.23.156.9
               │
       ┌───────┴────────┐
       │   YOUR ROUTER  │  ← NAT translation happens HERE
       │   (does NAT)   │
       └───────┬────────┘
               │
     ┌─────────┼─────────┐
     │         │         │
  192.168.1.10 │   192.168.1.12
  (laptop)     │   (phone)
          192.168.1.11
            (smart TV)

  All 3 devices SHARE one public IP when talking to the internet!

═══════════════════════════════════════════════════════════════════
```

## 🎭 CIDR Notation — Network + Subnet Mask, Compressed

```
CIDR NOTATION
═══════════════════════════════════════════════════════════════════
  192.168.1.0/24
       │        │
       │        └─ "/24" means the first 24 BITS are the network part
       │            (leaves 8 bits = 256 addresses for hosts)
       └─ Network address

  Common CIDR sizes:
  /24  → 256 addresses   (254 usable)   — typical home/small office
  /16  → 65,536 addresses                — medium network
  /8   → 16.7 million addresses          — huge network (rare, ISP-scale)
  /32  → 1 single address                — used to refer to ONE specific host

═══════════════════════════════════════════════════════════════════
```

```bash
# Calculate subnet details easily
ipcalc 192.168.1.0/24            # Install: sudo apt install ipcalc
# Shows network, broadcast, usable range, netmask, etc.
```

## 🆕 IPv6 — The Next Generation

```
IPv6 vs IPv4
═══════════════════════════════════════════════════════════════
  IPv4: 192.168.1.10                    (32-bit, ~4.3 billion addresses)
  IPv6: 2001:0db8:85a3::8a2e:0370:7334   (128-bit, ~340 undecillion addresses!)

  Why IPv6 exists: IPv4 addresses RAN OUT. IPv6 has so many
  addresses that every device on Earth could have trillions each.
═══════════════════════════════════════════════════════════════
```

```bash
ip -6 addr show              # See your IPv6 addresses
ping6 google.com              # Ping over IPv6
```

---

# PART C: NETWORK INTERFACE CONFIGURATION

## 🔌 The Modern Way: `ip` Command

```
ip vs ifconfig
═══════════════════════════════════════════════════════════════
  ifconfig  → OLD tool (net-tools package), DEPRECATED on most
              modern distros, but still seen in older docs/scripts
  ip        → MODERN tool (iproute2 package), the CURRENT standard
              Use "ip" for everything going forward!
═══════════════════════════════════════════════════════════════
```

```bash
# VIEW network interfaces
ip addr show                    # All interfaces and their IPs (shortcut: ip a)
ip addr show eth0                # Just one interface
ip link show                     # Interface status (UP/DOWN) without IPs

# VIEW routing table
ip route show                    # Shortcut: ip r

# BRING AN INTERFACE UP/DOWN
sudo ip link set eth0 up
sudo ip link set eth0 down

# ASSIGN AN IP ADDRESS manually
sudo ip addr add 192.168.1.50/24 dev eth0
sudo ip addr del 192.168.1.50/24 dev eth0

# ADD A DEFAULT GATEWAY (route)
sudo ip route add default via 192.168.1.1

# OLDER equivalent commands (still useful to recognize!)
ifconfig                          # Old way to view interfaces
ifconfig eth0 192.168.1.50 netmask 255.255.255.0   # Old way to set IP
route -n                           # Old way to view routing table
```

### Understanding `ip addr show` Output

```
ip addr show OUTPUT EXPLAINED
═══════════════════════════════════════════════════════════════════

  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
      link/ether 08:00:27:4a:3c:1d brd ff:ff:ff:ff:ff:ff
      inet 192.168.1.50/24 brd 192.168.1.255 scope global eth0

  2:        → interface index number
  eth0      → interface name
  UP        → interface is administratively enabled
  LOWER_UP  → physical link/cable is actually connected
  link/ether → the MAC address (Layer 2)
  inet      → the IPv4 address assigned (Layer 3)
  /24       → CIDR subnet mask
  brd       → broadcast address for this subnet

═══════════════════════════════════════════════════════════════════
```

```bash
# See MAC addresses specifically
ip link show
cat /sys/class/net/eth0/address          # Straight from the kernel (Chapter 2 callback!)

# Persistent configuration (so it survives reboot)
# Debian/Ubuntu (Netplan, modern):
cat /etc/netplan/01-netcfg.yaml
sudo netplan apply

# RHEL/Fedora (NetworkManager):
nmcli connection show
nmcli device status
sudo nmcli connection modify eth0 ipv4.addresses 192.168.1.50/24
```

---

# PART D: DNS — TURNING NAMES INTO ADDRESSES

## 📛 What Is DNS?

DNS (Domain Name System) is the system that translates human-friendly names (`google.com`) into machine-friendly IP addresses (`142.250.190.78`) — it's often called "the phonebook of the internet."

```
DNS RESOLUTION PROCESS
═══════════════════════════════════════════════════════════════════

  You type: google.com in your browser
       │
       ▼
  1. Check LOCAL cache (browser, OS) — already know it? Use it.
       │ (not cached)
       ▼
  2. Check /etc/hosts file (manual overrides)
       │ (not found)
       ▼
  3. Ask the configured DNS RESOLVER (e.g. your router, or
     a public resolver like 8.8.8.8 / 1.1.1.1)
       │
       ▼
  4. Resolver asks a ROOT server → "who handles .com?"
       │
       ▼
  5. Root server points to a .com TLD server
       │
       ▼
  6. TLD server points to google.com's AUTHORITATIVE
     nameserver — which FINALLY returns the real IP
       │
       ▼
  7. Your computer connects to 142.250.190.78 🎉

═══════════════════════════════════════════════════════════════════
```

## 📜 `/etc/hosts` — Manual DNS Override

```bash
cat /etc/hosts
```

**Sample:**

```
127.0.0.1       localhost
127.0.1.1       myserver
192.168.1.20    devserver.local devserver
```

```bash
# Add a manual entry (great for local development/testing!)
echo "192.168.1.99 myapp.test" | sudo tee -a /etc/hosts
```

> **📌 Key Point:** `/etc/hosts` is checked BEFORE any DNS server is contacted — this is how many developers test websites locally before DNS records officially point anywhere.

## 🔧 DNS Configuration Files

```bash
cat /etc/resolv.conf            # Which DNS servers does this machine use?
```

**Sample `/etc/resolv.conf`:**

```
nameserver 8.8.8.8
nameserver 1.1.1.1
```

## 🔍 DNS Lookup Tools

```bash
# nslookup — classic, simple
nslookup google.com
nslookup google.com 8.8.8.8       # Query a SPECIFIC DNS server

# dig — more powerful, more detail (preferred for troubleshooting)
dig google.com
dig google.com +short              # Just the IP, no extra noise
dig google.com MX                  # Find MAIL servers for a domain
dig google.com NS                  # Find NAMESERVERS for a domain
dig -x 142.250.190.78               # REVERSE lookup (IP → name)
dig google.com @8.8.8.8             # Query a specific DNS server

# host — simple, script-friendly
host google.com
host -t MX google.com
```

### Real-World dig Output Breakdown

```
dig google.com OUTPUT EXPLAINED
═══════════════════════════════════════════════════════════════════

  ;; QUESTION SECTION:
  ;google.com.                   IN      A

  ;; ANSWER SECTION:
  google.com.             300    IN      A       142.250.190.78
                            │              │            │
                            │              │            └─ The actual IP
                            │              └─ "A" record = IPv4 address
                            └─ TTL (Time To Live) — cache this for 300 seconds

═══════════════════════════════════════════════════════════════════
```

| DNS Record Type | Purpose                                                          |
| --------------- | ---------------------------------------------------------------- |
| `A`             | Maps a domain to an IPv4 address                                 |
| `AAAA`          | Maps a domain to an IPv6 address                                 |
| `CNAME`         | Alias — points one domain name to ANOTHER domain name            |
| `MX`            | Mail server for the domain                                       |
| `NS`            | Authoritative nameservers for the domain                         |
| `TXT`           | Arbitrary text (often used for verification, SPF/email security) |
| `PTR`           | Reverse lookup — IP back to domain name                          |

> **🎓 Interview Question:** _"You changed your DNS records but the website still shows the old server. Why?"_ **Answer:** DNS caching! Each record has a TTL (Time To Live) — until that cache expires (at any layer: your browser, OS, ISP resolver), the OLD value may still be returned. Lowering TTL before a planned change, and clearing local caches, helps speed up propagation.

---

# PART E: DHCP — AUTOMATIC IP ASSIGNMENT

## 🎫 What Is DHCP?

DHCP (Dynamic Host Configuration Protocol) automatically assigns IP addresses to devices joining a network — without it, you'd have to manually configure every single device's IP!

```
DHCP — THE "DORA" PROCESS
═══════════════════════════════════════════════════════════════════

  Your Device                              DHCP Server (often your router)
      │                                              │
      │── 1. DISCOVER ──────────────────────────►   │  "Is anyone a DHCP server?"
      │                                              │
      │  ◄──────────────────── 2. OFFER ──────────  │  "I am! Here's an IP: .50"
      │                                              │
      │── 3. REQUEST ───────────────────────────►   │  "I'll take that IP!"
      │                                              │
      │  ◄──────────────────── 4. ACK ─────────────  │  "Confirmed, it's yours
      │                                              │   for the next 24 hours"

  D-O-R-A = Discover, Offer, Request, Acknowledge

═══════════════════════════════════════════════════════════════════
```

```bash
# Renew your DHCP lease manually
sudo dhclient -r              # Release current lease
sudo dhclient                  # Request a new lease

# Modern NetworkManager equivalent
sudo nmcli connection up eth0

# See current lease info
cat /var/lib/dhcp/dhclient.leases 2>/dev/null
```

---

# PART F: ROUTING — HOW PACKETS FIND THEIR WAY

## 🗺️ The Routing Table — Your Device's "Map"

```bash
ip route show                  # View the routing table
ip r                             # Shortcut
```

**Sample output:**

```
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.50
```

```
READING A ROUTE
═══════════════════════════════════════════════════════════════════
  default via 192.168.1.1 dev eth0
     │            │              │
     │            │              └─ Use THIS network interface
     │            └─ Send it to this GATEWAY (router) first
     └─ "default" = the route used when NO other rule matches
        (i.e., "I don't know where this is, ask the router")

  192.168.1.0/24 dev eth0 scope link
     │                  │
     │                  └─ Directly reachable, no gateway needed
     └─ "If destination is on MY local subnet, just send it directly"
═══════════════════════════════════════════════════════════════════
```

```bash
# Add a static route
sudo ip route add 10.0.0.0/24 via 192.168.1.254

# Delete a route
sudo ip route del 10.0.0.0/24

# Trace the path packets take to a destination
traceroute google.com
tracepath google.com           # Doesn't need root, simpler output
mtr google.com                  # "My Traceroute" — live, continuously updating!
```

```
TRACEROUTE CONCEPT
═══════════════════════════════════════════════════════════════════

  Your PC ──► Router 1 ──► ISP Router ──► Backbone ──► ... ──► google.com
     1 hop      2 hops        3 hops        4 hops              N hops

  traceroute shows EVERY hop along the way, and how long each
  one takes — perfect for finding WHERE a connection is slow
  or broken (e.g., "it dies at hop 4 — that's my ISP's problem!")

═══════════════════════════════════════════════════════════════════
```

---

# PART G: PORTS & PROTOCOLS — TCP vs UDP

## 🚪 What Is a Port?

If an IP address is like a building's street address, a **port** is like a specific apartment number inside that building — it tells the OS exactly which APPLICATION should receive incoming data.

```
IP + PORT = COMPLETE DESTINATION
═══════════════════════════════════════════════════════════════
  192.168.1.50 : 443
       │          │
       │          └─ Port 443 = HTTPS web traffic
       └─ The building (the SERVER)

  One server can run MANY services simultaneously, each
  listening on its own port — like apartments in one building!
═══════════════════════════════════════════════════════════════
```

## 📋 Well-Known Ports

| Port  | Protocol | Service                      |
| ----- | -------- | ---------------------------- |
| 20/21 | TCP      | FTP (data/control)           |
| 22    | TCP      | SSH                          |
| 23    | TCP      | Telnet (insecure, avoid!)    |
| 25    | TCP      | SMTP (sending email)         |
| 53    | TCP/UDP  | DNS                          |
| 67/68 | UDP      | DHCP                         |
| 80    | TCP      | HTTP                         |
| 110   | TCP      | POP3 (email)                 |
| 143   | TCP      | IMAP (email)                 |
| 443   | TCP      | HTTPS                        |
| 3306  | TCP      | MySQL                        |
| 5432  | TCP      | PostgreSQL                   |
| 6379  | TCP      | Redis                        |
| 8080  | TCP      | Common alternative HTTP port |

```bash
cat /etc/services | head -20          # The system's master port-to-service mapping
grep "^ssh" /etc/services               # Look up a specific service's port
```

## 🤝 TCP vs UDP

```
TCP vs UDP
═══════════════════════════════════════════════════════════════════
  TCP (Transmission Control Protocol)    UDP (User Datagram Protocol)
  ─────────────────────────────────      ──────────────────────────
  CONNECTION-ORIENTED                     CONNECTIONLESS
  Guarantees delivery (retransmits        NO guarantee — packets can
   lost packets)                           be lost, no retransmission
  Guarantees ORDER (reassembles            NO ordering guarantee
   packets correctly)
  Slower (more overhead)                  Faster (minimal overhead)

  Used for: web browsing, SSH,            Used for: video streaming,
  file transfer, email                     DNS queries, VoIP, gaming
  (where ACCURACY matters)                 (where SPEED matters more
                                            than occasional dropped data)
═══════════════════════════════════════════════════════════════════
```

## 🤝 The TCP Three-Way Handshake

```
TCP THREE-WAY HANDSHAKE
═══════════════════════════════════════════════════════════════════

  Client                                    Server
     │                                          │
     │── SYN (Synchronize) ─────────────────►   │  "Want to connect?"
     │                                          │
     │  ◄──────────── SYN-ACK ────────────────  │  "Yes, let's connect!"
     │                                          │
     │── ACK (Acknowledge) ─────────────────►   │  "Great, confirmed!"
     │                                          │
     │◄═══════ CONNECTION ESTABLISHED ═══════►  │  Now data can flow

═══════════════════════════════════════════════════════════════════
```

> **🎓 Interview Question:** _"Why does DNS use UDP but file transfer uses TCP?"_ **Answer:** DNS queries are small and need to be FAST; if a query is lost, the client just retries quickly — the overhead of TCP's handshake and guarantees isn't worth it. File transfers need every byte to arrive correctly and in order, so TCP's reliability is essential even at the cost of more overhead.

---

# PART H: SSH — SECURE REMOTE ACCESS MASTERY

## 🔐 SSH — Your Gateway to Every Remote Server

```bash
ssh username@192.168.1.50            # Basic connection
ssh username@server.com -p 2222       # Connect on a non-default port
ssh -v username@server.com            # Verbose — great for troubleshooting connection issues
```

## 🔑 SSH Key-Based Authentication (Much Safer Than Passwords!)

```
SSH KEY AUTHENTICATION CONCEPT
═══════════════════════════════════════════════════════════════════

  YOUR COMPUTER                         REMOTE SERVER
  ┌──────────────────┐                  ┌──────────────────┐
  │ PRIVATE KEY      │                  │ PUBLIC KEY       │
  │ (~/.ssh/id_rsa)  │                  │ (~/.ssh/         │
  │ NEVER share this!│                  │  authorized_keys)│
  └──────────────────┘                  └──────────────────┘

  The server sends a CHALLENGE that only your PRIVATE key can
  correctly answer (mathematically), proving it's really you —
  WITHOUT ever transmitting your private key over the network!

═══════════════════════════════════════════════════════════════════
```

```bash
# Generate a new SSH key pair
ssh-keygen -t ed25519 -C "your_email@example.com"     # Modern, recommended algorithm
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"  # Older, still widely supported

# Copy your public key to a remote server (the easy way!)
ssh-copy-id username@server.com

# Manual method (if ssh-copy-id isn't available)
cat ~/.ssh/id_ed25519.pub | ssh username@server.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Test it — should connect WITHOUT asking for a password now!
ssh username@server.com
```

> **⚠️ WARNING:** Remember Chapter 3's permissions! `~/.ssh` must be `700` and `authorized_keys`/private keys must be `600`, or SSH will REFUSE to use them for security reasons.

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519              # Private key
chmod 644 ~/.ssh/id_ed25519.pub           # Public key (fine to be more open)
chmod 600 ~/.ssh/authorized_keys
```

## ⚙️ SSH Config File — `~/.ssh/config`

```bash
cat > ~/.ssh/config << 'EOF'
Host myserver
    HostName 192.168.1.50
    User ahmed
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

Host webserver
    HostName web.example.com
    User deploy
    Port 22
EOF

# Now you can just type:
ssh myserver           # Instead of: ssh -p 2222 ahmed@192.168.1.50
```

## 📁 Copying Files Over SSH

```bash
# scp — Secure Copy
scp file.txt username@server:/home/username/         # Upload a file
scp username@server:/path/to/file.txt ./              # Download a file
scp -r myfolder/ username@server:/home/username/      # Copy a whole directory

# rsync — Smarter, faster, resumable (preferred for larger transfers!)
rsync -avz myfolder/ username@server:/home/username/myfolder/
#      │││
#      ││└─ z = compress during transfer
#      │└── v = verbose
#      └─── a = archive mode (preserves permissions, timestamps, etc.)

rsync -avz --delete myfolder/ username@server:/path/   # Also delete files removed locally
rsync -avz --progress bigfile.iso username@server:/path/  # Show progress bar
```

> **🎓 Interview Question:** _"Why would you use `rsync` instead of `scp`?"_ **Answer:** `rsync` only transfers the DIFFERENCES between source and destination (delta transfer), can resume interrupted transfers, and preserves more metadata — making it far more efficient for large files or repeated syncs, while `scp` always copies the entire file from scratch.

## 🚇 SSH Tunneling (Port Forwarding)

```bash
# LOCAL port forwarding: access a remote service through a local port
ssh -L 8080:localhost:80 username@server.com
# Now visiting http://localhost:8080 on YOUR machine reaches
# port 80 on the REMOTE server!

# REMOTE port forwarding: expose YOUR local service to the remote side
ssh -R 9000:localhost:3000 username@server.com

# Dynamic forwarding (creates a SOCKS proxy — browse through the tunnel!)
ssh -D 1080 username@server.com
```

```
LOCAL PORT FORWARDING — REAL USE CASE
═══════════════════════════════════════════════════════════════════
  A database on a remote server is firewalled and only accepts
  connections from "localhost" on that server. You need to
  connect a GUI tool from YOUR laptop to it.

  ssh -L 5432:localhost:5432 username@dbserver.com

  Now connect your GUI tool to localhost:5432 on YOUR machine —
  SSH tunnels it securely to the remote database!
═══════════════════════════════════════════════════════════════════
```

---

# PART I: FIREWALLS — iptables, ufw, firewalld

## 🧱 What Does a Firewall Do?

A firewall inspects network traffic and decides whether to ALLOW or BLOCK it, based on rules you define (source/destination IP, port, protocol).

```
FIREWALL CONCEPT
═══════════════════════════════════════════════════════════════
  Incoming traffic
       │
       ▼
  ┌──────────────────┐
  │     FIREWALL     │   Rule: "Allow port 22 (SSH)"     → ✅ ALLOWED
  │  (checks rules)  │   Rule: "Allow port 80/443 (web)" → ✅ ALLOWED
  │                  │   Everything else                → ❌ BLOCKED
  └──────────────────┘
       │
       ▼
  Your server (only receives what's allowed)
═══════════════════════════════════════════════════════════════
```

## 🔧 `ufw` — Uncomplicated Firewall (Ubuntu/Debian)

```bash
sudo ufw status                    # Check if it's running and what's allowed
sudo ufw enable                     # Turn on the firewall
sudo ufw disable                    # Turn off the firewall

sudo ufw allow 22                    # Allow SSH by port number
sudo ufw allow ssh                   # Allow SSH by service name (same thing)
sudo ufw allow 80/tcp                 # Allow HTTP, TCP specifically
sudo ufw allow from 192.168.1.100     # Allow ALL traffic from one specific IP
sudo ufw allow from 192.168.1.0/24 to any port 22    # Allow SSH only from this subnet

sudo ufw deny 23                      # Explicitly block telnet
sudo ufw delete allow 80               # Remove a rule

sudo ufw status verbose                # Detailed view of all rules
sudo ufw status numbered               # Numbered list (useful for deleting by number)
sudo ufw delete 3                       # Delete rule #3
```

> **⚠️ CRITICAL WARNING:** If you're connected via SSH, ALWAYS run `sudo ufw allow ssh` (or your custom SSH port) BEFORE running `sudo ufw enable`! Forgetting this locks you out of your own remote server instantly — a classic, painful mistake.

## 🔧 `firewalld` — RHEL/Fedora/CentOS

```bash
sudo systemctl status firewalld         # Check if it's running
sudo firewall-cmd --state                # Quick state check

sudo firewall-cmd --list-all              # See current zone's rules
sudo firewall-cmd --get-zones              # List available zones

sudo firewall-cmd --add-port=22/tcp --permanent      # Allow SSH permanently
sudo firewall-cmd --add-service=http --permanent      # Allow HTTP by service name
sudo firewall-cmd --reload                              # Apply --permanent changes!

sudo firewall-cmd --remove-port=22/tcp --permanent
sudo firewall-cmd --add-port=22/tcp --zone=public --permanent
```

> **📌 Key Point:** `firewalld` changes made with `--permanent` do NOT take effect immediately — you must run `firewall-cmd --reload` afterward. Without `--permanent`, changes apply immediately but are LOST on reboot. Many beginners forget one or the other!

## 🔧 `iptables` — The Low-Level Engine Underneath

Both `ufw` and `firewalld` are friendly front-ends for the same underlying kernel technology: `iptables` (or its modern successor `nftables`).

```bash
sudo iptables -L                       # List current rules
sudo iptables -L -v -n                  # Verbose, numeric (no DNS lookups, faster)

# Allow SSH (port 22)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Block a specific IP entirely
sudo iptables -A INPUT -s 203.0.113.50 -j DROP

# Set default policy: drop everything not explicitly allowed
sudo iptables -P INPUT DROP

# Save rules so they survive reboot (varies by distro)
sudo iptables-save > /etc/iptables/rules.v4
```

```
iptables RULE STRUCTURE
═══════════════════════════════════════════════════════════════
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT
              │      │        │           │
              │      │        │           └─ ACTION: ACCEPT/DROP/REJECT
              │      │        └─ destination port to match
              │      └─ protocol (tcp/udp/icmp)
              └─ CHAIN: INPUT (incoming), OUTPUT (outgoing), FORWARD (routed)

  -A = Append a rule to the end of the chain
═══════════════════════════════════════════════════════════════
```

---

# PART J: VPN BASICS

## 🔒 What Is a VPN?

A VPN (Virtual Private Network) creates an encrypted tunnel between your device and a remote network, making it appear as though you're physically connected to that remote network.

```
VPN CONCEPT
═══════════════════════════════════════════════════════════════════

  Your Device                                  Company Network
  ┌──────────┐                                 ┌──────────────┐
  │          │═══ ENCRYPTED TUNNEL ════════════│              │
  │          │   (over the public internet)    │ Internal     │
  └──────────┘                                 │ Resources    │
                                               └──────────────┘

  To anyone watching the public internet traffic, all they see
  is ENCRYPTED noise — they cannot read what's inside the tunnel.

═══════════════════════════════════════════════════════════════════
```

```bash
# WireGuard — modern, fast, simple VPN (increasingly the standard)
sudo apt install wireguard
wg genkey | tee privatekey | wg pubkey > publickey    # Generate key pair
sudo wg-quick up wg0                                     # Start a configured tunnel
sudo wg-quick down wg0                                    # Stop it
wg show                                                    # See active tunnels

# OpenVPN — older, very widely supported, more complex config
sudo apt install openvpn
sudo openvpn --config client.ovpn
```

---

# PART K: NETWORK TROUBLESHOOTING TOOLKIT

## 🧰 The Tools Every Linux Admin Reaches For

```bash
# PING — Is the host even reachable?
ping google.com                    # Continuous (Ctrl+C to stop)
ping -c 4 google.com                # Stop after 4 packets
ping -i 0.2 google.com               # Faster interval between pings

# ss — Modern replacement for netstat (socket statistics)
ss -tulnp                            # TCP+UDP, listening, numeric, show process
#  │││││
#  ││││└─ p = show PROCESS using the socket
#  │││└── n = numeric (don't resolve hostnames — faster)
#  ││└─── l = listening sockets only
#  │└──── u = UDP
#  └───── t = TCP

ss -ta                                 # All TCP connections (not just listening)
ss -s                                   # Summary statistics

# netstat — older tool, still seen everywhere in tutorials
netstat -tulnp                          # Same idea as ss -tulnp

# curl — Test HTTP/API endpoints directly
curl https://example.com                  # Fetch a page
curl -I https://example.com                 # HEADERS only (fast check)
curl -v https://example.com                  # VERBOSE — see the full request/response
curl -o output.html https://example.com       # Save to a file

# wget — Download files (great for scripts)
wget https://example.com/file.zip
wget -c https://example.com/file.zip          # Resume a partial download

# tcpdump — Capture and inspect raw network packets (powerful!)
sudo tcpdump -i eth0                       # Capture on interface eth0
sudo tcpdump -i eth0 port 80                 # Only HTTP traffic
sudo tcpdump -i eth0 host 192.168.1.50        # Only traffic to/from one host
sudo tcpdump -w capture.pcap                   # Save to a file for later analysis (e.g. Wireshark)

# nmap — Network/port scanner (use responsibly, only on networks you own/have permission for!)
nmap 192.168.1.0/24                          # Scan an entire subnet for live hosts
nmap -p 1-1000 192.168.1.50                    # Scan a range of ports on one host
nmap -sV 192.168.1.50                            # Try to detect SERVICE VERSIONS running
```

> **⚠️ WARNING:** Tools like `nmap` and `tcpdump` are legitimate, essential admin tools — but using them against networks you DON'T own or have explicit permission to test is illegal in most jurisdictions. Always practice on your own lab/home network.

### Real-World Troubleshooting Flowchart

```
"I CAN'T REACH THE WEBSITE!" — TROUBLESHOOTING FLOW
═══════════════════════════════════════════════════════════════════

  1. ping 8.8.8.8                  → Can I reach the internet AT ALL?
     (tests raw IP connectivity, bypasses DNS)

  2. ping google.com                → Is DNS working?
     (if step 1 worked but this fails, it's a DNS problem!)

  3. dig google.com                  → What does DNS actually return?

  4. curl -v https://google.com       → Can I make an HTTP(S) connection?
     (tests beyond just ping — actual application-layer access)

  5. traceroute google.com             → WHERE along the path does it break?

  6. ss -tulnp                          → Is MY server listening on the
                                          right port at all? (for server-side issues)

═══════════════════════════════════════════════════════════════════
```

---

# PART L: CHAPTER SUMMARY + CHEAT SHEET + LABS

## 📝 Chapter Summary

```
CHAPTER 8 — KEY TAKEAWAYS
═══════════════════════════════════════════════════════════════════

  ✅ Models:
     OSI = 7 layers (theory)   TCP/IP = 4 layers (practical, used by Linux tools)

  ✅ IP Addressing:
     IPv4 = 32-bit, dotted decimal   Private ranges: 10.x, 172.16-31.x, 192.168.x
     CIDR /24 = 256 addresses        NAT lets many private IPs share 1 public IP

  ✅ Interfaces:
     ip addr show / ip link / ip route   (modern)
     ifconfig / route -n                   (legacy, still seen)

  ✅ DNS:
     Translates names → IPs   /etc/hosts checked FIRST, then resolvers
     dig / nslookup / host for lookups   A, AAAA, CNAME, MX, NS, TXT records

  ✅ DHCP:
     DORA = Discover, Offer, Request, Acknowledge

  ✅ Routing:
     Routing table decides where packets go   default route = "ask the gateway"
     traceroute/mtr show the path packet-by-packet

  ✅ Ports & Protocols:
     TCP = reliable, ordered, slower (web, SSH, file transfer)
     UDP = fast, no guarantees (DNS, streaming, gaming)
     Three-way handshake: SYN → SYN-ACK → ACK

  ✅ SSH:
     Key-based auth >> passwords    ~/.ssh permissions matter (700/600)
     scp/rsync for file transfer    -L/-R/-D for tunneling

  ✅ Firewalls:
     ufw (Debian/Ubuntu)   firewalld (RHEL/Fedora)   iptables (low-level engine)
     ALWAYS allow SSH before enabling a firewall remotely!

  ✅ Troubleshooting:
     ping → dig → curl → traceroute → ss   — work through the layers systematically

═══════════════════════════════════════════════════════════════════
```

## 📌 Quick Reference Cheat Sheet

```
CHAPTER 8 COMMAND CHEAT SHEET
═══════════════════════════════════════════════════════════════════════════════

INTERFACES & ROUTING            DNS                              SSH
──────────────────────         ─────────────────────         ───────────────────
ip addr show     IPs            dig domain         Lookup       ssh user@host       Connect
ip link show     Status         dig +short          Just IP      ssh-keygen -t ed25519 Gen key
ip route show    Routes         nslookup domain     Lookup       ssh-copy-id user@host Copy key
ip route add     Add route      cat /etc/hosts      Manual map   scp file user@host:path Copy file
traceroute host  Path to host   cat /etc/resolv.conf DNS servers rsync -avz src dest    Sync files
mtr host         Live trace                                      ssh -L 8080:host:80 user@x Tunnel

PORTS & SOCKETS                  FIREWALLS                       TROUBLESHOOTING
──────────────────────         ─────────────────────         ───────────────────
ss -tulnp        Listening      ufw allow 22       Allow port   ping host          Reachable?
ss -ta           All TCP        ufw enable          Turn on      curl -I url         HTTP headers
netstat -tulnp   Legacy ver.    firewall-cmd --add-port=N/tcp   curl -v url          Verbose req
cat /etc/services Port lookup   firewall-cmd --reload  Apply     tcpdump -i eth0     Packet capture
                                iptables -L          List rules  nmap host           Port scan

═══════════════════════════════════════════════════════════════════════════════
```

## ❓ Chapter 8 Interview Questions

| #   | Question                                                                                | Key Answer Points                                                                                                                                |
| --- | --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | What's the difference between the OSI and TCP/IP models?                                | OSI has 7 theoretical layers; TCP/IP has 4 practical layers that Linux tools and real protocols map to directly                                  |
| 2   | What is NAT and why is it needed?                                                       | Network Address Translation lets many private IP devices share one public IP, conserving the limited IPv4 address space                          |
| 3   | What does /24 mean in CIDR notation?                                                    | The first 24 bits are the network portion, leaving 8 bits (256 addresses) for hosts                                                              |
| 4   | Explain the DNS resolution process.                                                     | Check local cache → /etc/hosts → configured resolver → root servers → TLD servers → authoritative nameserver returns the IP                      |
| 5   | What does DORA stand for in DHCP?                                                       | Discover, Offer, Request, Acknowledge — the 4-step process of automatic IP assignment                                                            |
| 6   | TCP vs UDP — when would you use each?                                                   | TCP for reliable, ordered delivery (web, SSH, file transfer); UDP for speed-critical, loss-tolerant traffic (DNS, streaming, gaming)             |
| 7   | Describe the TCP three-way handshake.                                                   | SYN (client requests) → SYN-ACK (server acknowledges + requests back) → ACK (client confirms) — connection established                           |
| 8   | Why is SSH key authentication more secure than passwords?                               | The private key never leaves your machine; the server only verifies a cryptographic challenge, eliminating brute-force password risk             |
| 9   | Why use rsync instead of scp for large file transfers?                                  | rsync only transfers differences (delta), can resume interrupted transfers, and is far more efficient for repeated syncs                         |
| 10  | What's the danger of enabling a firewall on a remote server without allowing SSH first? | You instantly lock yourself out of your own remote session with no way back in except console/recovery access                                    |
| 11  | What's the relationship between ufw/firewalld and iptables?                             | ufw and firewalld are user-friendly front-ends; iptables (or nftables) is the actual underlying kernel firewall engine they configure            |
| 12  | How would you troubleshoot "I can't reach this website"?                                | Systematically test each layer: ping the IP directly, then DNS resolution, then HTTP-level connectivity (curl), then trace the path (traceroute) |

## 🔬 Practical Lab: Chapter 8 Exercises

```bash
# ──────────────────────────────────────────────────────────────────
# LAB 1: Interface and Routing Investigation
# ──────────────────────────────────────────────────────────────────
ip addr show
ip route show
ip link show
hostname -I

# ──────────────────────────────────────────────────────────────────
# LAB 2: DNS Investigation
# ──────────────────────────────────────────────────────────────────
cat /etc/resolv.conf
dig google.com
dig google.com +short
dig google.com MX
dig -x 8.8.8.8                  # Reverse lookup
cat /etc/hosts

# ──────────────────────────────────────────────────────────────────
# LAB 3: Port and Socket Investigation
# ──────────────────────────────────────────────────────────────────
ss -tulnp
sudo ss -tulnp | grep LISTEN
cat /etc/services | grep -w "80\|443\|22"

# ──────────────────────────────────────────────────────────────────
# LAB 4: SSH Key Setup (practice on a test VM or localhost)
# ──────────────────────────────────────────────────────────────────
ssh-keygen -t ed25519 -f ~/.ssh/lab_key -C "lab-test"
cat ~/.ssh/lab_key.pub
chmod 700 ~/.ssh
chmod 600 ~/.ssh/lab_key
ls -l ~/.ssh/

# ──────────────────────────────────────────────────────────────────
# LAB 5: The Troubleshooting Flowchart in Action
# ──────────────────────────────────────────────────────────────────
ping -c 3 8.8.8.8                 # Raw connectivity
ping -c 3 google.com               # DNS working?
curl -I https://google.com          # HTTP-level check
traceroute google.com 2>/dev/null || tracepath google.com
ss -tulnp | head -10
```

## 🧠 Mini Project: Network Diagnostic Script

```bash
cat > ~/netcheck.sh << 'EOF'
#!/bin/bash
set -uo pipefail

echo "=========================================="
echo "   NETWORK DIAGNOSTIC REPORT"
echo "   $(date)"
echo "=========================================="
echo ""

echo "─── NETWORK INTERFACES ─────────────────"
ip -brief addr show
echo ""

echo "─── DEFAULT GATEWAY ────────────────────"
ip route show default
echo ""

echo "─── DNS SERVERS ────────────────────────"
cat /etc/resolv.conf | grep nameserver
echo ""

echo "─── CONNECTIVITY TESTS ─────────────────"
if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    echo "✅ Internet (raw IP): REACHABLE"
else
    echo "❌ Internet (raw IP): UNREACHABLE"
fi

if ping -c 1 -W 2 google.com &>/dev/null; then
    echo "✅ DNS Resolution: WORKING"
else
    echo "❌ DNS Resolution: FAILED"
fi
echo ""

echo "─── LISTENING PORTS ────────────────────"
ss -tulnp 2>/dev/null | grep LISTEN | head -10
echo ""

echo "─── ACTIVE CONNECTIONS ─────────────────"
ss -ta | grep ESTAB | wc -l
echo "established connections currently open"
echo ""

echo "=========================================="
echo "   END OF REPORT"
echo "=========================================="
EOF

chmod +x ~/netcheck.sh
bash ~/netcheck.sh
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
  ⬜ Chapter 9:  System Administration (systemd, logging, cron)
  ⬜ Chapter 10: Linux Security (PAM, SELinux, encryption)
  ⬜ Chapter 11: Containers (Docker, namespaces, cgroups)
  ⬜ Chapter 12: Linux Kernel Development

═══════════════════════════════════════════════════════════════════
  YOU ARE HERE: ✅✅✅✅✅✅✅✅ — Eight chapters down! 💪
═══════════════════════════════════════════════════════════════════
```

---

Next: [Chapter 9 — System Administration: systemd, Logging, and Scheduled Jobs](/chapter-9.md)

---
