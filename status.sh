#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/gunicorn.pid"
LOG_FILE="$SCRIPT_DIR/gunicorn.log"

echo "========================================"
echo "   Domain Sale - Status Check"
echo "========================================"
echo ""

# Check PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 $PID 2>/dev/null; then
        echo "[RUNNING] Service is running (PID: $PID)"
        echo ""
        echo "Listening ports:"
        if command -v ss &> /dev/null; then
            ss -tlnp 2>/dev/null | grep "$PID" || ss -tlnp 2>/dev/null | grep -E ":(80|5000) "
        elif command -v netstat &> /dev/null; then
            netstat -tlnp 2>/dev/null | grep "$PID" || netstat -tlnp 2>/dev/null | grep -E ":(80|5000) "
        elif command -v lsof &> /dev/null; then
            lsof -ti:80 -ti:5000 2>/dev/null | xargs -r lsof -p 2>/dev/null
        fi
        echo ""
        if [ -f "$LOG_FILE" ]; then
            echo "Recent logs (last 10 lines):"
            tail -10 "$LOG_FILE" 2>/dev/null
            echo ""
            echo "Full log: $LOG_FILE"
        fi
        echo ""
        echo "URLs:"
        echo "  http://localhost:80"
        echo "  http://localhost:5000"
        echo ""
        echo "To stop: ./stop.sh"
        echo "To view logs: tail -f $LOG_FILE"
        exit 0
    else
        echo "[STOPPED] PID file exists but process not running"
        rm -f "$PID_FILE"
    fi
fi

# Check ports
for port in 80 5000; do
    PID=""
    if command -v lsof &> /dev/null; then
        PID=$(lsof -ti:$port 2>/dev/null)
    elif command -v ss &> /dev/null; then
        PID=$(ss -tlnp 2>/dev/null | grep ":$port " | awk '{print $6}' | cut -d',' -f2 | cut -d'=' -f2)
    elif command -v netstat &> /dev/null; then
        PID=$(netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | cut -d'/' -f1)
    fi

    if [ -n "$PID" ]; then
        echo "[RUNNING] Process found on port $port (PID: $PID)"
        echo "  To stop: ./stop.sh"
        exit 0
    fi
done

echo "[STOPPED] Service is not running"
echo ""
echo "To start: ./start.sh"
