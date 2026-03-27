#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/gunicorn.pid"

echo "========================================"
echo "   Domain Sale - Stop Script"
echo "========================================"
echo ""

if [ ! -f "$PID_FILE" ]; then
    echo "[ERROR] PID file not found: $PID_FILE"
    echo "Trying to find process by port..."

    # Try to find process on port 80 or 5000
    for port in 80 5000; do
        PID=$(lsof -ti:$port 2>/dev/null || netstat -tlnp 2>/dev/null | grep :$port | awk '{print $7}' | cut -d'/' -f1 || true)
        if [ -n "$PID" ]; then
            echo "Found process on port $port: $PID"
            read -p "Kill this process? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                kill -15 $PID 2>/dev/null || kill -9 $PID 2>/dev/null
                echo "Process killed"
            fi
            exit 0
        fi
    done

    # Try to find by name
    PID=$(pgrep -f "gunicorn.*wsgi:app" 2>/dev/null || pgrep -f "python.*app.py" 2>/dev/null || true)
    if [ -n "$PID" ]; then
        echo "Found process: $PID"
        read -p "Kill this process? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill -15 $PID 2>/dev/null || kill -9 $PID 2>/dev/null
            echo "Process killed"
        fi
        exit 0
    fi

    echo "No running process found"
    exit 1
fi

PID=$(cat "$PID_FILE")

if [ -z "$PID" ]; then
    echo "[ERROR] PID file is empty"
    rm -f "$PID_FILE"
    exit 1
fi

echo "Stopping service (PID: $PID)..."

# Try graceful shutdown first
kill -15 $PID 2>/dev/null

# Wait for process to stop
for i in {1..10}; do
    if ! kill -0 $PID 2>/dev/null; then
        echo "Service stopped gracefully"
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

# Force kill if still running
echo "Force killing service..."
kill -9 $PID 2>/dev/null
rm -f "$PID_FILE"
echo "Service stopped"
