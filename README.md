# Expo
## Server-setup

1. install
```sh
pkg install cloudflared # termux android

sudo apt install cloudflared # debian / ubuntu / kali linux
sudo pacman -S clodflared # Arch linux
```
2. login
```bash
cloudflared tunnel login # cert.pem will be created
```

3. create tunnel
```sh
# Provision a unique tunnel architecture instance
cloudflared tunnel create ohm-server
```

**list tunnel**
```sh
cloudflared tunnel list
```
4. Local Configuration Profile
`nano ~/.cloudflared/config.yml`
```sh
tunnel: YOUR_NEW_TUNNEL_ID
credentials-file: /data/data/com.termux/files/home/.cloudflared/YOUR_NEW_TUNNEL_ID.json # android termux
#credentials-file: /home/USER_NAME/.cloudflared/YOUR_NEW_TUNNEL_ID.json # for pc


ingress:
  - hostname: api.ohm.dpdns.org
    service: http://localhost:3000
  - service: http_status:404
```

5. Edge Networking & DNS Injection
```sh
cloudflared tunnel route dns ohm-server api.ohm.dpdns.org
```

6. Execution Profiles & Process Control
```sh
cloudflared --config ~/.cloudflared/config.yml tunnel run
```

---
---
**Run this command to let `cloudflared` automatically test its DNS, transport layer, and API access**
```sh
cloudflared tunnel diag
```

**If that runs cleanly without the "temporary file creation failed" errors, use the same variable trick to spin up your tunnel server:**
```sh
TMPDIR=~/tmp cloudflared --config ~/.cloudflared/config.yml tunnel run
```
---


---


---

