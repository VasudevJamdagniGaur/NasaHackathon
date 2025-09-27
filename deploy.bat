@echo off
REM KeplerAI Deployment Script for Windows
REM This script sets up and deploys the KeplerAI application on Windows

setlocal enabledelayedexpansion

echo.
echo 🚀 KeplerAI Deployment Script (Windows)
echo =======================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed. Please install Python 3.8+ first.
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Check command line argument
set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=setup

if "%COMMAND%"=="setup" goto setup
if "%COMMAND%"=="dev" goto dev
if "%COMMAND%"=="stop" goto stop
if "%COMMAND%"=="docker" goto docker
if "%COMMAND%"=="clean" goto clean
if "%COMMAND%"=="help" goto help
goto help

:setup
echo [INFO] Setting up KeplerAI...
echo.

REM Install Python dependencies
echo [INFO] Installing Python dependencies...
cd backend
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Python dependencies
    pause
    exit /b 1
)

REM Train ML model if it doesn't exist
if not exist "models\exoplanet_classifier.pkl" (
    echo [INFO] Training ML model (this may take a few minutes)...
    python train_model.py
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to train ML model
        pause
        exit /b 1
    )
    echo [SUCCESS] ML model trained successfully
) else (
    echo [SUCCESS] ML model already exists
)

cd ..

REM Install Node.js dependencies if npm is available
where npm >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Installing Node.js dependencies...
    cd frontend\web
    npm install
    cd ..\..
    echo [SUCCESS] Node.js dependencies installed
) else (
    echo [WARNING] Node.js/npm not found. Please install Node.js for web development.
)

echo.
echo [SUCCESS] Setup completed!
echo Run 'deploy.bat dev' to start development servers.
echo.
pause
goto end

:dev
echo [INFO] Starting development servers...
echo.

REM Start backend server
echo [INFO] Starting backend API server...
cd backend
start "KeplerAI Backend" python app.py
cd ..

REM Start frontend if npm is available
where npm >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Starting React web app...
    cd frontend\web
    start "KeplerAI Frontend" npm start
    cd ..\..
)

echo.
echo [SUCCESS] KeplerAI is starting up!
echo.
echo 🌐 Web App: http://localhost:3000
echo 🔧 API: http://localhost:5000
echo 📱 Mobile: Connect Flutter app to http://localhost:5000
echo.
echo Press any key to stop all servers...
pause >nul

REM Stop servers
taskkill /f /im python.exe >nul 2>&1
taskkill /f /im node.exe >nul 2>&1
echo [INFO] Servers stopped.
goto end

:stop
echo [INFO] Stopping development servers...
taskkill /f /im python.exe >nul 2>&1
taskkill /f /im node.exe >nul 2>&1
echo [SUCCESS] Development servers stopped.
pause
goto end

:docker
REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    echo Download from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo [INFO] Deploying with Docker...

REM Ensure ML model is trained
cd backend
if not exist "models\exoplanet_classifier.pkl" (
    echo [INFO] Training ML model first...
    pip install -r requirements.txt
    python train_model.py
)
cd ..

REM Deploy with Docker
docker-compose down >nul 2>&1
docker-compose up --build -d

if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] KeplerAI deployed with Docker!
    echo.
    echo 🌐 Web App: http://localhost:3000
    echo 🔧 API: http://localhost:5000
    echo 📊 Full App: http://localhost (if using nginx)
    echo.
) else (
    echo [ERROR] Docker deployment failed.
)
pause
goto end

:clean
echo [INFO] Cleaning up Docker resources...
docker-compose down --rmi all --volumes --remove-orphans >nul 2>&1
echo [SUCCESS] Docker cleanup completed.
pause
goto end

:help
echo Usage: deploy.bat [COMMAND]
echo.
echo Commands:
echo   setup     - Install dependencies and train ML model
echo   dev       - Start development servers
echo   stop      - Stop development servers
echo   docker    - Deploy with Docker
echo   clean     - Clean up Docker containers and images
echo   help      - Show this help message
echo.
echo Examples:
echo   deploy.bat setup     # First time setup
echo   deploy.bat dev       # Start development
echo   deploy.bat docker    # Production deployment
echo.
pause
goto end

:end
endlocal
