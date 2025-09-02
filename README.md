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
# ufw-auto-block
