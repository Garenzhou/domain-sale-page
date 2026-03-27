#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/gunicorn.pid"
LOG_FILE="$SCRIPT_DIR/gunicorn.log"

echo "========================================"
echo "   Domain Sale - Startup Script"
echo "========================================"
echo ""

# Check if email is provided as argument
if [ -n "$1" ]; then
    export CONTACT_EMAIL="$1"
    echo "[INFO] Setting contact email: $1"
else
    echo "[INFO] No email provided. Checking .env file..."
    if [ -f "$SCRIPT_DIR/.env" ]; then
        echo "[INFO] Using settings from .env file"
        # Source .env file if exists
        export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
    else
        echo "[WARNING] .env file not found!"
        echo "[WARNING] Using default placeholder email."
        echo ""
        echo "Usage: ./start.sh your-email@example.com"
        echo "Or create a .env file with CONTACT_EMAIL=your-email@example.com"
        echo ""
    fi
fi

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "[ERROR] conda not found, please install Anaconda or Miniconda"
    exit 1
fi

# Check and create conda environment
echo ""
echo "[1/6] Checking conda environment..."
if ! conda env list | grep -q "domain-sale"; then
    echo "[INFO] Creating conda environment 'domain-sale'..."
    conda env create -f "$SCRIPT_DIR/environment.yml"
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create environment"
        exit 1
    fi
else
    echo "[INFO] conda environment 'domain-sale' already exists"
fi

# Activate environment
echo ""
echo "[2/6] Activating conda environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate domain-sale

# Check if running as root on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ "$EUID" -ne 0 ]; then
        echo ""
        echo "[WARNING] Binding port 80 requires root privileges on Linux"
        echo "Please run with sudo, or use setcap"
        echo ""
        read -p "Continue with port 5000 instead? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        export PORT=5000
    fi
fi

# Choose startup mode
echo ""
echo "[3/6] Select mode:"
echo "  1) Foreground (see logs, Ctrl+C to stop)"
echo "  2) Background (run as daemon)"
read -p "Enter choice (1-2, default 2): " mode_choice

# Choose server type
echo ""
echo "[4/6] Select server:"
echo "  1) Flask dev server (for debugging)"
echo "  2) Gunicorn (production, recommended)"
read -p "Enter choice (1-2, default 2): " server_choice

# Get port
PORT=${PORT:-80}

# Start service
echo ""
echo "[5/6] Starting service..."
echo "[6/6] Service will be available at http://localhost:$PORT"
echo ""
echo "========================================"
echo "Email: ${CONTACT_EMAIL:-Set via .env file}"
echo "========================================"
echo ""

case ${server_choice:-2} in
    1)
        # Flask dev server
        if [ "${mode_choice:-2}" = "1" ]; then
            echo "Starting Flask in foreground..."
            python "$SCRIPT_DIR/app.py"
        else
            echo "Starting Flask in background..."
            nohup python "$SCRIPT_DIR/app.py" > "$LOG_FILE" 2>&1 &
            echo $! > "$PID_FILE"
            echo "Service started. PID: $(cat $PID_FILE)"
            echo "Logs: $LOG_FILE"
            echo "Use ./stop.sh to stop"
        fi
        ;;
    2)
        # Gunicorn
        if [ "${mode_choice:-2}" = "1" ]; then
            echo "Starting Gunicorn in foreground..."
            gunicorn --bind 0.0.0.0:$PORT --workers 4 --chdir "$SCRIPT_DIR" wsgi:app
        else
            echo "Starting Gunicorn in background..."
            gunicorn --bind 0.0.0.0:$PORT --workers 4 \
                --pid "$PID_FILE" \
                --daemon \
                --access-logfile "$LOG_FILE" \
                --error-logfile "$LOG_FILE" \
                --chdir "$SCRIPT_DIR" \
                wsgi:app
            echo "Service started. PID: $(cat $PID_FILE)"
            echo "Logs: $LOG_FILE"
            echo "Use ./stop.sh to stop"
        fi
        ;;
    *)
        echo "[ERROR] Invalid choice"
        exit 1
        ;;
esac
