@echo off
setlocal
rem Launch napari from a pixi environment defined in the napari-env GitHub repo.

set "REPO_RAW=https://raw.githubusercontent.com/cwood1967/napari-env/main"
set "APP_DIR=%USERPROFILE%\.napari-env"
set "TASK=napari"
set "PIXI_CACHE_DIR=C:\pixi-cache"
if not exist "%PIXI_CACHE_DIR%" mkdir "%PIXI_CACHE_DIR%"

rem Install pixi if missing.
set "PATH=%USERPROFILE%\.pixi\bin;%PATH%"
where pixi >nul 2>nul
if errorlevel 1 (
    echo pixi not found - installing...
    powershell -ExecutionPolicy ByPass -c "irm -useb https://pixi.sh/install.ps1 | iex"
)
where pixi >nul 2>nul
if errorlevel 1 (
    echo Failed to install pixi. Install it manually from https://pixi.sh, then re-run this file.
    pause
    exit /b 1
)

rem Fetch the latest manifest + lockfile; keep the existing copy if offline.
if not exist "%APP_DIR%" mkdir "%APP_DIR%"
for %%F in (pyproject.toml pixi.lock) do (
    curl.exe -fsSL "%REPO_RAW%/%%F" -o "%APP_DIR%\%%F.tmp" && move /Y "%APP_DIR%\%%F.tmp" "%APP_DIR%\%%F" >nul || (
        del /Q "%APP_DIR%\%%F.tmp" 2>nul
        echo Could not update %%F - using cached copy.
    )
)
if not exist "%APP_DIR%\pixi.lock" (
    echo No environment files available ^(first run needs internet^).
    pause
    exit /b 1
)

rem --frozen: install exactly what's in pixi.lock, never re-solve on the user's machine.
pixi run --frozen --manifest-path "%APP_DIR%\pyproject.toml" %TASK%
