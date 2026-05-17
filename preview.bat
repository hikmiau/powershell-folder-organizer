@echo off
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%PS%" (
    set "PS=%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
)

if "%~1"=="" (
    "%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Organize-Folder.ps1" -DryRun
) else (
    "%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Organize-Folder.ps1" -Path "%~1" -DryRun
)

pause
