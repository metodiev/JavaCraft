@echo off
rem Restart JavaCraft. Double-click friendly wrapper around restart.ps1.
setlocal
where pwsh >nul 2>nul
if %errorlevel% equ 0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0restart.ps1" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restart.ps1" %*
)
set "jc_exit=%errorlevel%"
rem Keep the window open when the script was double-clicked so the output stays readable.
echo %cmdcmdline% | find /i "%~nx0" >nul 2>nul
if not errorlevel 1 pause
exit /b %jc_exit%
