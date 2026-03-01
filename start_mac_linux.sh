#!/bin/bash
echo "==================================================="
echo "LoRA Dataset Architect - One-Click Installer & Runner"
echo "==================================================="
echo ""

# Check for Python
if ! command -v python3 &> /dev/null
then
    echo "[ERROR] Python 3 is not installed."
    echo "Please install Python 3.10 or 3.11."
    exit 1
fi

# Check for Node.js
if ! command -v npm &> /dev/null
then
    echo "[ERROR] Node.js (npm) is not installed."
    echo "Please install Node.js from nodejs.org."
    exit 1
fi

echo "[1/3] Installing Python dependencies..."
pip3 install torch torchvision torchaudio
pip3 install fastapi uvicorn transformers pillow accelerate qwen-vl-utils

echo ""
echo "[2/3] Installing User Interface dependencies..."
npm install

echo ""
echo "[3/3] Starting the servers..."
echo "Starting Python AI Server in the background..."
python3 local_caption_server.py &
PYTHON_PID=$!

echo "Starting React UI Server..."
echo "Open your browser to the URL shown below (usually http://localhost:5173)"
npm run dev

# Cleanup when script is terminated
trap "kill $PYTHON_PID" EXIT
