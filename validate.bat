@echo off
echo ================================
echo Hive Store Validation Script
echo ================================
echo.

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

set "ADDON_DIR=%GMOD_DIR%\garrysmod\addons\HiveStore"

echo Checking Hive Store installation...
echo Addon directory: %ADDON_DIR%
echo.

REM Check if addon directory exists
if not exist "%ADDON_DIR%" (
    echo [ERROR] Hive Store addon directory not found!
    echo Please run install.bat first.
    goto :error
)

echo [OK] Addon directory found

REM Check essential files
set "FILES_TO_CHECK=addon.json README.md lua\autorun\hive_store_init.lua lua\hive_store\config.lua"

for %%f in (%FILES_TO_CHECK%) do (
    if exist "%ADDON_DIR%\%%f" (
        echo [OK] %%f
    ) else (
        echo [ERROR] Missing file: %%f
        set "HAS_ERRORS=1"
    )
)

REM Check lua directory structure
if exist "%ADDON_DIR%\lua\hive_store\server" (
    echo [OK] Server files directory
) else (
    echo [ERROR] Missing server files directory
    set "HAS_ERRORS=1"
)

if exist "%ADDON_DIR%\lua\hive_store\client" (
    echo [OK] Client files directory
) else (
    echo [ERROR] Missing client files directory
    set "HAS_ERRORS=1"
)

if exist "%ADDON_DIR%\lua\hive_store\shared" (
    echo [OK] Shared files directory
) else (
    echo [ERROR] Missing shared files directory
    set "HAS_ERRORS=1"
)

REM Check specific server files
set "SERVER_FILES=sv_init.lua sv_database.lua sv_peakecoin.lua sv_commands.lua sv_networking.lua"
for %%f in (%SERVER_FILES%) do (
    if exist "%ADDON_DIR%\lua\hive_store\server\%%f" (
        echo [OK] Server: %%f
    ) else (
        echo [ERROR] Missing server file: %%f
        set "HAS_ERRORS=1"
    )
)

REM Check specific client files
set "CLIENT_FILES=cl_init.lua cl_gui.lua cl_networking.lua"
for %%f in (%CLIENT_FILES%) do (
    if exist "%ADDON_DIR%\lua\hive_store\client\%%f" (
        echo [OK] Client: %%f
    ) else (
        echo [ERROR] Missing client file: %%f
        set "HAS_ERRORS=1"
    )
)

REM Check shared files
if exist "%ADDON_DIR%\lua\hive_store\shared\sh_items.lua" (
    echo [OK] Shared: sh_items.lua
) else (
    echo [ERROR] Missing shared file: sh_items.lua
    set "HAS_ERRORS=1"
)

echo.

if "%HAS_ERRORS%"=="1" (
    goto :error
) else (
    goto :success
)

:success
echo ================================
echo Validation Successful!
echo ================================
echo.
echo All required files are present.
echo The Hive Store addon should work correctly.
echo.
echo To test:
echo 1. Start Garry's Mod
echo 2. Check console for "[Hive Store] Addon loaded successfully!"
echo 3. Press F4 to open the store
echo 4. Use !wallet to check balance
echo.
goto :end

:error
echo ================================
echo Validation Failed!
echo ================================
echo.
echo Some files are missing or incorrect.
echo Please reinstall the addon by running install.bat
echo.

:end
pause
