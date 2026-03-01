@echo off
echo ===================================================
echo LoRA Dataset Architect - One-Click Installer ^& Runner
echo ===================================================
echo.

:: Check for Python
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python is not installed or not in your PATH.
    echo Please install Python 3.10 or 3.11 from python.org and check "Add Python to PATH".
    echo Press any key to exit...
    pause >nul
    exit /b
)

:: Check for Node.js
node --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js is not installed or not in your PATH.
    echo Please install Node.js from nodejs.org.
    echo Press any key to exit...
    pause >nul
    exit /b
)

echo [1/3] Installing Python dependencies (this may take a while)...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install fastapi uvicorn transformers pillow accelerate qwen-vl-utils

echo.
echo [2/3] Installing User Interface dependencies...
call npm install

echo.
echo [3/3] Starting the servers...
echo.
echo Starting Python AI Server in a new window...
start cmd /k "title AI Caption Server && echo Starting AI Server... && python local_caption_server.py"

echo Starting React UI Server...
echo Once it says "ready", open your browser to http://localhost:5173 (or the URL shown below)
call npm run dev
