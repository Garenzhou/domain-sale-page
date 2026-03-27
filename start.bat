@echo off
echo ========================================
echo    Domain Sale - Startup Script
echo ========================================
echo.

REM Check if email is provided as argument
if "%~1"=="" (
    echo [INFO] No email provided. Checking .env file...
    if exist ".env" (
        echo [INFO] Using settings from .env file
    ) else (
        echo [WARNING] .env file not found!
        echo [WARNING] Using default placeholder email.
        echo.
        echo Usage: start.bat your-email@example.com
        echo Or create a .env file with CONTACT_EMAIL=your-email@example.com
        echo.
    )
) else (
    echo [INFO] Setting contact email: %~1
    set CONTACT_EMAIL=%~1
)

echo.

REM Check if conda is available
where conda >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] conda not found, please install Anaconda or Miniconda
    pause
    exit /b 1
)

REM Check and create conda environment
echo [1/4] Checking conda environment...
call conda env list | findstr "domain-sale" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Creating conda environment "domain-sale"...
    call conda env create -f environment.yml
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Failed to create environment
        pause
        exit /b 1
    )
) else (
    echo [INFO] conda environment "domain-sale" already exists
)

REM Activate environment and start service
echo.
echo [2/4] Activating conda environment...
echo [3/4] Starting Flask server...
echo [4/4] Service will start at http://localhost:80
echo.
echo ========================================
if defined CONTACT_EMAIL (
    echo Email: %CONTACT_EMAIL%
) else (
    echo Email: Set via .env file
)
echo ========================================
echo.
echo Press Ctrl+C to stop the service
echo.

call conda activate domain-sale && python app.py

pause
