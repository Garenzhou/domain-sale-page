# Domain Sale Page

[中文文档](README.zh.md)

A sleek, modern single-page website for listing domain names for sale.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)

---

## Quick Start

Get up and running in 3 steps:

### Step 1: Copy config file

```bash
cp .env.example .env
```

### Step 2: Set your email

Edit `.env` and add your contact email:

```env
CONTACT_EMAIL=your-email@example.com
```

### Step 3: Start

| System | Command |
|--------|---------|
| **Windows** | Double-click `start.bat` |
| **Linux/macOS** | `chmod +x start.sh && sudo ./start.sh` |

Done! Visit http://localhost:80 to see your site.

---

## Features

| Feature | Description |
|---------|-------------|
| 🎨 Premium Design | Dark gradient + glassmorphism UI |
| 🌍 Multi-language | 8 languages, auto-detect browser language |
| 📱 Responsive | Perfect for mobile and desktop |
| 📧 One-click Contact | Email link opens mail client automatically |

**Supported Languages:** 🇺🇸 English 🇨🇳 中文 🇯🇵 日本語 🇰🇷 한국어 🇩🇪 Deutsch 🇫🇷 Français 🇪🇸 Español

---

## Detailed Documentation

### Prerequisites

- Anaconda or Miniconda (recommended)
- Or Python 3.11+

---

### Option 1: Using .env file (Recommended)

```bash
# 1. Copy example config
cp .env.example .env

# 2. Edit .env to set email and port
CONTACT_EMAIL=your-email@example.com
PORT=80

# 3. Start
# Windows: Double-click start.bat
# Linux/macOS: sudo ./start.sh
```

---

### Option 2: Pass email as argument

No config file needed, pass email directly when starting:

```bash
# Windows
start.bat your-email@example.com

# Linux/macOS
sudo ./start.sh your-email@example.com
```

---

### Option 3: Manual start (For developers)

```bash
# 1. Create and activate conda environment
conda env create -f environment.yml
conda activate domain-sale

# 2. Set environment variables
export CONTACT_EMAIL=your-email@example.com
export PORT=80

# 3. Start (choose one)
# Development mode:
python app.py

# Production mode (Gunicorn):
gunicorn --bind 0.0.0.0:80 --workers 4 wsgi:app
```

---

## Linux/macOS Service Management

| Script | Function |
|--------|----------|
| `start.sh` | Start service (foreground or background) |
| `stop.sh` | Stop service |
| `status.sh` | Check service status |

### Start in background

```bash
sudo ./start.sh your-email@example.com
# Select 2 (background mode) and 2 (Gunicorn)
```

### Check status

```bash
./status.sh
```

### Stop service

```bash
sudo ./stop.sh
```

---

## Manual Command Reference

```bash
# Start in background
export CONTACT_EMAIL=your-email@example.com
sudo nohup gunicorn --bind 0.0.0.0:80 --workers 4 --daemon --pid gunicorn.pid wsgi:app

# View process
ps aux | grep gunicorn
ss -tlnp | grep :80

# Stop process
sudo kill -15 <PID>    # Graceful stop
sudo kill -9 <PID>     # Force stop

# View logs
tail -f gunicorn.log
```

---

## Files

| File | Description |
|------|-------------|
| `app.py` | Flask application main file |
| `wsgi.py` | WSGI entry point (for Gunicorn) |
| `requirements.txt` | pip dependencies |
| `environment.yml` | Conda environment config |
| `start.bat` | Windows startup script |
| `start.sh` | Linux/macOS startup script |
| `stop.sh` | Linux/macOS stop script |
| `status.sh` | Linux/macOS status check script |
| `.env.example` | Environment variables example |
| `.gitignore` | Git ignore config |

---

## Configuration

| Env Var | Default | Description |
|---------|---------|-------------|
| `CONTACT_EMAIL` | `your-email@example.com` | Contact email |
| `PORT` | `80` | Server port |
| `SHOW_GITHUB` | `true` | Show GitHub link in corner (set to `false` to hide) |
| `GITHUB_URL` | `https://github.com/Garenzhou/domain-sale-page` | GitHub repository URL |

---

## Port Notes

Default port is **80**.

- Linux/macOS binding port 80 requires root privileges (use `sudo`)
- If permission denied, switch to another port:

```bash
export PORT=5000
python app.py
```

---

## Tech Stack

- **Web Framework**: Flask
- **Application Server**: Gunicorn
- **Environment Management**: Conda
- **Fonts**: Google Fonts (Playfair Display, Inter)

---

## Star History

If you find this project helpful, please give it a Star ⭐

---

## Contributing

Issues and PRs are welcome!

---

## License

MIT License - see [LICENSE](LICENSE) file for details.
