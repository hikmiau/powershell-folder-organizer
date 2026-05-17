@echo off
setlocal
cd /d "%~dp0"

echo powershell-folder-organizer
echo Preview mode. No files will be moved.
echo.

set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%PS%" (
    set "PS=%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
)

if not exist "%PS%" (
    echo PowerShell was not found.
    pause
    exit /b 1
)

if not exist "%~dp0scripts\Organize-Folder.ps1" (
    echo Organizer script was not found.
    echo Make sure the zip was fully extracted.
    pause
    exit /b 1
)

if "%~1"=="" (
    "%PS%" -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force; Get-ChildItem -Recurse | Unblock-File; & '%~dp0scripts\Organize-Folder.ps1' -DryRun"
) else (
    "%PS%" -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force; Get-ChildItem -Recurse | Unblock-File; & '%~dp0scripts\Organize-Folder.ps1' -Path '%~1' -DryRun"
)

echo.
pause
