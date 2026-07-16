@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Script\CompileProto.ps1" %*
set "COMPILE_EXIT_CODE=%ERRORLEVEL%"
echo.
pause
exit /b %COMPILE_EXIT_CODE%
