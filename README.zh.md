# Domain Sale Page

[English Documentation](README.md)

一个简洁高端的单页网站，用于展示域名待售信息。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)

---

## 快速开始

只需 3 步，1 分钟启动网站：

### 步骤 1：复制配置文件

```bash
cp .env.example .env
```

### 步骤 2：设置你的邮箱

编辑 `.env` 文件，填入你的联系邮箱：

```env
CONTACT_EMAIL=your-email@example.com
```

### 步骤 3：启动

| 系统 | 命令 |
|------|------|
| **Windows** | 双击 `start.bat` |
| **Linux/macOS** | `chmod +x start.sh && sudo ./start.sh` |

完成！访问 http://localhost:80 查看网站。

---

## 功能演示

| 功能 | 说明 |
|------|------|
| 🎨 高端设计 | 暗黑渐变 + 玻璃拟态风格 |
| 🌍 多语言 | 8种语言，自动检测浏览器语言 |
| 📱 响应式 | 完美适配手机和电脑 |
| 📧 一键联系 | 邮箱点击自动打开邮件客户端 |

**支持的语言：** 🇺🇸 English 🇨🇳 中文 🇯🇵 日本語 🇰🇷 한국어 🇩🇪 Deutsch 🇫🇷 Français 🇪🇸 Español

---

## 详细文档

### 前置要求

- Anaconda 或 Miniconda（推荐）
- 或 Python 3.11+

---

### 方式一：使用 .env 文件（推荐）

```bash
# 1. 复制示例配置
cp .env.example .env

# 2. 编辑 .env，设置邮箱和端口
CONTACT_EMAIL=your-email@example.com
PORT=80

# 3. 启动
# Windows: 双击 start.bat
# Linux/macOS: sudo ./start.sh
```

---

### 方式二：命令行传参

无需配置文件，直接在启动时传入邮箱：

```bash
# Windows
start.bat your-email@example.com

# Linux/macOS
sudo ./start.sh your-email@example.com
```

---

### 方式三：手动启动（开发者）

```bash
# 1. 创建并激活 conda 环境
conda env create -f environment.yml
conda activate domain-sale

# 2. 设置环境变量
export CONTACT_EMAIL=your-email@example.com
export PORT=80

# 3. 启动（二选一）
# 开发模式：
python app.py

# 生产模式（Gunicorn）：
gunicorn --bind 0.0.0.0:80 --workers 4 wsgi:app
```

---

## Linux/macOS 服务管理

| 脚本 | 功能 |
|------|------|
| `start.sh` | 启动服务（可选择前台/后台） |
| `stop.sh` | 停止服务 |
| `status.sh` | 查看服务状态 |

### 后台启动

```bash
sudo ./start.sh your-email@example.com
# 选择 2 (后台模式) 和 2 (Gunicorn)
```

### 查看状态

```bash
./status.sh
```

### 停止服务

```bash
sudo ./stop.sh
```

---

## 手动命令参考

```bash
# 后台启动
export CONTACT_EMAIL=your-email@example.com
sudo nohup gunicorn --bind 0.0.0.0:80 --workers 4 --daemon --pid gunicorn.pid wsgi:app

# 查看进程
ps aux | grep gunicorn
ss -tlnp | grep :80

# 停止进程
sudo kill -15 <PID>    # 优雅停止
sudo kill -9 <PID>     # 强制停止

# 查看日志
tail -f gunicorn.log
```

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `app.py` | Flask 应用主文件 |
| `wsgi.py` | WSGI 入口（用于 Gunicorn） |
| `requirements.txt` | pip 依赖列表 |
| `environment.yml` | Conda 环境配置 |
| `start.bat` | Windows 启动脚本 |
| `start.sh` | Linux/macOS 启动脚本 |
| `stop.sh` | Linux/macOS 停止脚本 |
| `status.sh` | Linux/macOS 状态查看脚本 |
| `.env.example` | 环境变量示例 |
| `.gitignore` | Git 忽略配置 |

---

## 配置说明

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| `CONTACT_EMAIL` | `your-email@example.com` | 联系邮箱 |
| `PORT` | `80` | 服务端口 |

---

## 端口说明

默认使用 **80** 端口。

- Linux/macOS 绑定 80 端口需要 root 权限（使用 `sudo`）
- 如权限不足，可切换到其他端口：

```bash
export PORT=5000
python app.py
```

---

## 技术栈

- **Web 框架**: Flask
- **应用服务器**: Gunicorn
- **环境管理**: Conda
- **字体**: Google Fonts (Playfair Display, Inter)

---

## Star History

如果这个项目对你有帮助，请给个 Star ⭐

---

## 贡献

欢迎提交 Issue 和 PR！

---

## License

MIT License - 详见 [LICENSE](LICENSE) 文件。
