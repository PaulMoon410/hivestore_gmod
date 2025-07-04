@echo off
echo ================================
echo Hive Store Installation Script
echo ================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script should be run as administrator for best results.
    echo.
)

REM Find Garry's Mod directory
set "GMOD_DIR="
if exist "%ProgramFiles(x86)%\Steam\steamapps\common\GarrysMod" (
    set "GMOD_DIR=%ProgramFiles(x86)%\Steam\steamapps\common\GarrysMod"
) else if exist "%ProgramFiles%\Steam\steamapps\common\GarrysMod" (
    set "GMOD_DIR=%ProgramFiles%\Steam\steamapps\common\GarrysMod"
) else (
    echo Garry's Mod installation not found in default Steam directory.
    echo Please enter the full path to your Garry's Mod installation:
    set /p "GMOD_DIR="
)

if not exist "%GMOD_DIR%" (
    echo Error: Garry's Mod directory not found: %GMOD_DIR%
    pause
    exit /b 1
)

echo Found Garry's Mod at: %GMOD_DIR%
echo.

REM Create addons directory if it doesn't exist
set "ADDONS_DIR=%GMOD_DIR%\garrysmod\addons"
if not exist "%ADDONS_DIR%" (
    echo Creating addons directory...
    mkdir "%ADDONS_DIR%"
)

REM Copy HiveStore addon
set "DEST_DIR=%ADDONS_DIR%\HiveStore"
echo Copying HiveStore addon to: %DEST_DIR%

if exist "%DEST_DIR%" (
    echo Warning: HiveStore addon already exists. Overwriting...
    rmdir /s /q "%DEST_DIR%"
)

REM Copy current directory to addons
xcopy "%~dp0" "%DEST_DIR%" /E /I /H /Y

if %errorLevel% neq 0 (
    echo Error: Failed to copy addon files.
    pause
    exit /b 1
)

echo.
echo ================================
echo Installation Complete!
echo ================================
echo.
echo The Hive Store addon has been installed to:
echo %DEST_DIR%
echo.
echo Next steps:
echo 1. Start or restart Garry's Mod
echo 2. The addon will automatically load
echo 3. Press F4 in-game to open the store
echo 4. Use !wallet to check your PeakeCoin balance
echo.
echo For configuration, edit:
echo %DEST_DIR%\lua\hive_store\config.lua
echo.
echo For more information, see:
echo %DEST_DIR%\README.md
echo.
pause
