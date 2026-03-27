#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/gunicorn.pid"
LOG_FILE="$SCRIPT_DIR/gunicorn.log"
VENV_DIR="$SCRIPT_DIR/.venv"

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

# Function to find and initialize conda
init_conda() {
    if command -v conda &> /dev/null; then
        CONDA_BASE=$(conda info --base)
        if [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
            source "$CONDA_BASE/etc/profile.d/conda.sh"
            return 0
        fi
    fi

    local POSSIBLE_PATHS=(
        "$HOME/miniconda3"
        "$HOME/anaconda3"
        "$HOME/miniforge3"
        "/opt/miniconda3"
        "/opt/anaconda3"
        "/opt/miniforge3"
    )

    if [ -n "$SUDO_USER" ]; then
        USER_HOME=$(eval echo "~$SUDO_USER")
        POSSIBLE_PATHS=(
            "$USER_HOME/miniconda3"
            "$USER_HOME/anaconda3"
            "$USER_HOME/miniforge3"
            "${POSSIBLE_PATHS[@]}"
        )
    fi

    for CONDA_PATH in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "$CONDA_PATH/bin/conda" ]; then
            export PATH="$CONDA_PATH/bin:$PATH"
            if [ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]; then
                source "$CONDA_PATH/etc/profile.d/conda.sh"
                echo "[INFO] Found conda at $CONDA_PATH"
                return 0
            fi
        fi
    done

    return 1
}

# Function to setup venv
setup_venv() {
    # Check if python3 is available
    if ! command -v python3 &> /dev/null; then
        echo "[ERROR] python3 not found"
        return 1
    fi

    # Create venv if it doesn't exist
    if [ ! -d "$VENV_DIR" ]; then
        echo "[INFO] Creating virtual environment..."
        python3 -m venv "$VENV_DIR"
        if [ $? -ne 0 ]; then
            echo "[ERROR] Failed to create virtual environment"
            return 1
        fi
    fi

    # Activate venv
    source "$VENV_DIR/bin/activate"

    # Check if we need to install dependencies
    if ! python -c "import flask" 2>/dev/null || ! python -c "import gunicorn" 2>/dev/null; then
        echo "[INFO] Installing dependencies..."
        pip install --upgrade pip
        pip install -r "$SCRIPT_DIR/requirements.txt"
        if [ $? -ne 0 ]; then
            echo "[ERROR] Failed to install dependencies"
            return 1
        fi
    fi

    echo "[INFO] Using virtual environment: $VENV_DIR"
    return 0
}

# Try to setup environment - first conda, then venv
echo "[1/6] Setting up Python environment..."
ENV_TYPE=""

if init_conda; then
    echo "[INFO] Using conda"
    echo ""
    echo "[2/6] Checking conda environment..."
    if ! conda env list | grep -q "domain-sale"; then
        echo "[INFO] Creating conda environment 'domain-sale'..."
        conda env create -f "$SCRIPT_DIR/environment.yml" -y
        if [ $? -ne 0 ]; then
            echo "[WARNING] Conda environment creation failed, falling back to venv..."
            if setup_venv; then
                ENV_TYPE="venv"
            else
                echo "[ERROR] Both conda and venv setup failed"
                exit 1
            fi
        else
            ENV_TYPE="conda"
        fi
    else
        echo "[INFO] conda environment 'domain-sale' already exists"
        ENV_TYPE="conda"
    fi

    if [ "$ENV_TYPE" = "conda" ]; then
        echo ""
        echo "[3/6] Activating conda environment..."
        conda activate domain-sale
    fi
else
    echo "[INFO] Conda not found, using venv instead"
    if setup_venv; then
        ENV_TYPE="venv"
    else
        echo "[ERROR] Neither conda nor venv could be set up"
        echo "[ERROR] Please install either Anaconda/Miniconda or python3-venv"
        exit 1
    fi
fi

# Verify Python is working
if ! python --version &> /dev/null; then
    echo "[ERROR] Python not available after environment setup"
    exit 1
fi
echo "[INFO] Python environment ready: $(python --version)"

# Check if running as root on Linux
NEED_ROOT=0
PORT=${PORT:-80}
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ "$PORT" -eq 80 ] || [ "$PORT" -eq 443 ]; then
        NEED_ROOT=1
    fi
fi

# Check if we have permission for the port
STEP_OFFSET=$([ "$ENV_TYPE" = "conda" ] && echo 0 || echo 1)
CURRENT_STEP=$((4 - STEP_OFFSET))

if [[ "$OSTYPE" == "linux-gnu"* ]] && [ "$NEED_ROOT" -eq 1 ]; then
    if [ "$EUID" -ne 0 ]; then
        echo ""
        echo "[WARNING] Binding port $PORT requires root privileges on Linux"
        echo ""
        read -p "Continue with port 5000 instead? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            export PORT=5000
            NEED_ROOT=0
        else
            echo "[INFO] Re-running with sudo..."
            exec sudo env PATH="$PATH" CONTACT_EMAIL="$CONTACT_EMAIL" PORT="$PORT" CONDA_PREFIX="$CONDA_PREFIX" VIRTUAL_ENV="$VIRTUAL_ENV" ENV_TYPE="$ENV_TYPE" "$0" "$@"
        fi
    fi
fi

# If we were called with sudo and already have a venv, activate it
if [ -n "$SUDO_USER" ] && [ "$ENV_TYPE" = "venv" ] && [ -d "$VENV_DIR" ]; then
    source "$VENV_DIR/bin/activate"
fi

# If we were called with sudo and have conda, re-initialize
if [ -n "$SUDO_USER" ] && [ "$ENV_TYPE" = "conda" ]; then
    init_conda
    conda activate domain-sale 2>/dev/null
fi

# Choose startup mode
echo ""
CURRENT_STEP=$((CURRENT_STEP + 1))
echo "[$CURRENT_STEP/6] Select mode:"
echo "  1) Foreground (see logs, Ctrl+C to stop)"
echo "  2) Background (run as daemon)"
read -p "Enter choice (1-2, default 2): " mode_choice

# Choose server type
echo ""
CURRENT_STEP=$((CURRENT_STEP + 1))
echo "[$CURRENT_STEP/6] Select server:"
echo "  1) Flask dev server (for debugging)"
echo "  2) Gunicorn (production, recommended)"
read -p "Enter choice (1-2, default 2): " server_choice

# Start service
echo ""
CURRENT_STEP=$((CURRENT_STEP + 1))
echo "[$CURRENT_STEP/6] Starting service..."
echo "Service will be available at http://localhost:$PORT"
echo ""
echo "========================================"
echo "Environment: $ENV_TYPE"
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
