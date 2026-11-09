@echo off
setlocal

set "TOOL_NAME=napari-env"
set "TOOL_SOURCE=git+https://github.com/cwood1967/napari-env"

set "UV_CACHE_DIR=C:\pixi-cache\uv-cache"
if not exist "%UV_CACHE_DIR%" mkdir "%UV_CACHE_DIR%"

set "UV_EXE=uv"
where uv >nul 2>nul
if errorlevel 1 (
    echo uv not found - installing...
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    set "UV_EXE=%USERPROFILE%\.local\bin\uv.exe"
)
if not "%UV_EXE%"=="uv" if not exist "%UV_EXE%" (
    echo Failed to install uv. Install it manually from https://astral.sh/uv, then re-run this file.
    pause
    exit /b 1
)


"%UV_EXE%" tool list | findstr /B /I "%TOOL_NAME% " >nul 2>nul
if errorlevel 1 (
    echo Installing %TOOL_NAME%...
    "%UV_EXE%" tool install "%TOOL_SOURCE%"
)

"%UV_EXE%" tool run %TOOL_SOURCE%
