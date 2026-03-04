#!/bin/bash
set -euo pipefail

echo "==================================================="
echo "LoRA Dataset Architect - One-Click Installer & Runner"
echo "==================================================="
echo ""

# Find a compatible Python version (3.10 or 3.11)
PYTHON_CMD=""
if command -v python3.11 &> /dev/null; then
    PYTHON_CMD="python3.11"
elif command -v python3.10 &> /dev/null; then
    PYTHON_CMD="python3.10"
elif python3 -c "import sys; exit(0 if sys.version_info >= (3,10) and sys.version_info < (3,12) else 1)" &> /dev/null; then
    PYTHON_CMD="python3"
else
    echo "[ERROR] Could not find Python 3.10 or 3.11."
    echo "PyTorch does not fully support newer Python versions yet."
    echo ""
    echo "You can keep your current Python version (3.14), but please also install Python 3.11."
    echo "(e.g., via 'brew install python@3.11' or 'sudo apt install python3.11')"
    exit 1
fi

# Check for Node.js
if ! command -v npm &> /dev/null
then
    echo "[ERROR] Node.js (npm) is not installed."
    echo "Please install Node.js from nodejs.org."
    exit 1
fi

echo "[1/4] Setting up Python Virtual Environment using $PYTHON_CMD..."
if [ ! -d "venv" ]; then
    $PYTHON_CMD -m venv venv
fi
source venv/bin/activate

echo "[2/4] Installing Python dependencies..."
pip3 install torch torchvision torchaudio
pip3 install fastapi uvicorn transformers pillow accelerate qwen-vl-utils

echo ""
echo "[3/4] Installing User Interface dependencies..."
npm install

echo ""
echo "[4/4] Starting the servers..."
echo "Starting Python AI Server in the background..."
python3 local_caption_server.py &
PYTHON_PID=$!

echo "Starting React UI Server..."
echo "Open your browser to the URL shown below (usually http://localhost:3000)"
npm run dev

# Cleanup when script is terminated
trap "kill $PYTHON_PID" EXIT
