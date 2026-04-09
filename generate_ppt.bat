@echo off
REM College Management System - PowerPoint Documentation Generator
REM This script automatically generates PowerPoint documentation

echo ========================================
echo College Management System
echo PowerPoint Documentation Generator
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    echo.
    echo Please install Python from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo [OK] Python is installed
echo.

REM Check if python-pptx is installed
python -c "import pptx" >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] python-pptx package not found
    echo [INFO] Installing python-pptx...
    echo.
    python -m pip install python-pptx
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install python-pptx
        echo Please try manually: pip install python-pptx
        echo.
        pause
        exit /b 1
    )
    echo.
    echo [OK] python-pptx installed successfully
    echo.
)

echo [INFO] Generating PowerPoint documentation...
echo.

REM Run the generator script
python generate_docs.py
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to generate PowerPoint
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo [SUCCESS] PowerPoint generated!
echo ========================================
echo.
echo File created: College_Management_System_Documentation.pptx
echo.
echo You can now open the file in:
echo   - Microsoft PowerPoint
echo   - Google Slides
echo   - LibreOffice Impress
echo.

REM Try to open the file automatically
if exist "College_Management_System_Documentation.pptx" (
    echo Opening the file...
    start "" "College_Management_System_Documentation.pptx"
)

echo.
pause
