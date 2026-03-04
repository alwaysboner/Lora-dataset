@echo off
echo ===================================================
echo LoRA Dataset Architect - One-Click Installer ^& Runner
echo ===================================================
echo.

:: Find a compatible Python version (3.10 or 3.11)
set PYTHON_CMD=
py -3.11 -c "import sys; exit(0 if sys.maxsize > 2**32 else 1)" >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    set PYTHON_CMD=py -3.11
) ELSE (
    py -3.10 -c "import sys; exit(0 if sys.maxsize > 2**32 else 1)" >nul 2>&1
    IF %ERRORLEVEL% EQU 0 (
        set PYTHON_CMD=py -3.10
    ) ELSE (
        python -c "import sys; exit(0 if sys.version_info >= (3,10) and sys.version_info < (3,12) and sys.maxsize > 2**32 else 1)" >nul 2>&1
        IF %ERRORLEVEL% EQU 0 (
            set PYTHON_CMD=python
        )
    )
)

IF "%PYTHON_CMD%"=="" (
    echo [ERROR] Could not find a 64-bit installation of Python 3.10 or 3.11.
    echo PyTorch does not support Python 3.12+ or 32-bit Python yet.
    echo.
    echo You can keep your current Python version ^(3.14^), but you MUST ALSO install Python 3.11.
    echo Please download the 64-bit installer for Python 3.11 from python.org.
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

echo [1/4] Setting up Python Virtual Environment using %PYTHON_CMD%...
IF NOT EXIST "venv" (
    %PYTHON_CMD% -m venv venv
    IF %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Failed to create virtual environment.
        pause >nul
        exit /b
    )
)
call venv\Scripts\activate

echo.
echo [2/4] Installing Python dependencies (this may take a while)...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install PyTorch.
    pause >nul
    exit /b
)
pip install fastapi uvicorn transformers pillow accelerate qwen-vl-utils
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install Python dependencies.
    pause >nul
    exit /b
)

echo.
echo [3/4] Installing User Interface dependencies...
call npm install
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install Node.js dependencies.
    pause >nul
    exit /b
)

echo.
echo [4/4] Starting the servers...
echo.
echo Starting Python AI Server in a new window...
start cmd /k "title AI Caption Server && call venv\Scripts\activate && echo Starting AI Server... && python local_caption_server.py"

echo Starting React UI Server...
echo Once it says "ready", open your browser to http://localhost:3000 (or the URL shown below)
call npm run dev
