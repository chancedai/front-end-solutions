@echo off
for /f "tokens=2 delims=、." %%i in (list.txt) do echo %%i
pause>nul