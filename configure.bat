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

cd /d %0\..

setlocal

if "%OUTDIR%"=="" set OUTDIR=%cd%

set msvcg_args=cscript //nologo build/msvc-generate.js --config=version.m4
set msvcg_args=%msvcg_args% --var=EXTRA_C_DEFINES="%EXTRA_C_DEFINES%" --var=OUTDIR="%OUTDIR%"

for %%f in (config-env.bat src\config.h src\tap-windows.vcxproj) do (
	%msvcg_args% --input=%%f.in --output=%%f
	if errorlevel 1 goto error
)

mkdir src\amd64 > nul 2>&1
%msvcg_args% --config=build\vars.amd64.m4 --input=src\OemWin2k.inf.in --output=src\OemWin2k.inf
if errorlevel 1 goto error

set exitstatus=0
goto end

:error
echo FAILED
set exitstatus=1
goto end

:end

endlocal

exit /b %exitstatus%
