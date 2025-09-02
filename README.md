# 🔒 UFW Auto Block Script

A shell script that automatically blocks suspicious IP addresses and subnets based on **UFW logs**.  
It also provides an option to **unblock** all previously blocked addresses.

---

## 🚀 Features
- Parses `/var/log/ufw.log` and detects repeated connection attempts
- Blocks both **IPv4** and **IPv6** addresses
- Blocks entire subnets (`/24` for IPv4, `/64` for IPv6) after repeated attempts
- Keeps a separate log of blocked addresses (`/var/log/ufw-blocked.log`)
- Allows easy unblocking of all addresses in one command

---

## ⚙️ Requirements
- Linux with **UFW** installed and enabled
- `bash`, `awk`, `grep`, `sort`
- Root privileges (`sudo`)

---

## 📦 Installation
Clone the repository and make the script executable:

```bash
git clone https://github.com/YOUR_USERNAME/ufw-auto-block.git
cd ufw-auto-block
chmod +x ufw-auto-block.sh
```

## ▶️ Usage
Run auto-block

```bash
sudo ./ufw-auto-block.sh
```
This will:

- Analyze the last **10 minutes** of logs (`TIME_WINDOW` can be changed)
- Block IPs/subnets with **5 or more attempts** (`THRESHOLD` can be changed)
- Log all blocks into `/var/log/ufw-blocked.log`

Unblock all

```bash
sudo ./ufw-auto-block.sh unblock
```

This will:
- Remove all rules listed in /var/log/ufw-blocked.log
- Clear the block log

## ⚡ Example Output

```bash
[Blocked IPv4] 203.0.113.45  
[Blocked IPv4 Subnet] 203.0.113.0/24  
[Blocked IPv6] 2001:db8::1234  
[Blocked IPv6 Subnet] 2001:db8:0:1::/64  
Auto-block completed. All new blocks have been added to /var/log/ufw-blocked.log
```

## 📝 License

This project is licensed under the [MIT License](LICENSE).