@ECHO OFF
for /f "tokens=2 delims=:" %%i in ('ipconfig^|findstr "Address"') do set ip=%%i
SET ip=%ip:~1%
set id=%ip:~0,3%
ECHO Current IP Address : %ip%
PAUSE