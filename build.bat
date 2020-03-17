@echo off
rem TAP-Windows -- A kernel driver to provide virtual tap
rem                 device functionality on Windows.
rem
rem  Copyright (C) 2012      Alon Bar-Lev <alon.barlev@gmail.com>
rem
rem  This program is free software; you can redistribute it and/or modify
rem  it under the terms of the GNU General Public License as published by
rem  the Free Software Foundation; either version 2 of the License, or
rem  (at your option) any later version.
rem
rem  This program is distributed in the hope that it will be useful,
rem  but WITHOUT ANY WARRANTY; without even the implied warranty of
rem  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem  GNU General Public License for more details.
rem
rem  You should have received a copy of the GNU General Public License
rem  along with this program (see the file COPYING included with this
rem  distribution); if not, write to the Free Software Foundation, Inc.,
rem  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

set CROSSCERT=build\digicert-high-assurance-ev.crt
set TIMESTAMP_SERVER=http://timestamp.digicert.com
set TAPDIR=%~dp0

cd /d %0\..

if not exist config-env.bat (
	echo please run configure
	exit /b 1
)

if [%1]==[] goto USAGE
if [%2]==[] goto USAGE

setlocal

call config-env.bat

del /s "src\x64\Release\*.obj" > nul 2>&1
del /s "src\x64\Release\*.sys" > nul 2>&1
rmdir /s /q "src\x64\Release\tap-windows" > nul 2>&1

cmd /c _build WIN7 x64
if errorlevel 1 goto ERROR

:: Sign the driver

echo Signing and timestamping the driver
signtool sign /t %TIMESTAMP_SERVER% /td sha1 /fd sha1 /f comodo.pfx /p "%1" /v %TAPDIR%\src\x64\Release\tap-windows\tapmullvad0901.cat
signtool sign /as /tr %TIMESTAMP_SERVER% /td sha256 /fd sha256 /f comodo.pfx /p "%1" /v /ac %TAPDIR%\%CROSSCERT% %TAPDIR%\src\x64\Release\tap-windows\tapmullvad0901.cat
if errorlevel 1 goto ERROR

set exitstatus=0
goto END

:ERROR
echo FAIL
set exitstatus=1
goto END

:END

endlocal

exit /b %exitstatus%

:USAGE

echo Usage: %0 ^<certsha256_sha1_hash^> ^<certsha1_sha1_hash^>
exit /b 1
