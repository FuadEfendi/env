@echo off
setlocal enabledelayedexpansion

:: ocp.cmd
::
:: Copyright (c) 2014, 2015, Oracle and/or its affiliates. All rights reserved.
::
::   NAME
::      ocp.cmd - Oracle Configuration Patcher
::
::   DESCRIPTION
::      Run "ocp.cmd help" to see supported commands.

set BASE=%~dp0

set EXIT_CODE=0

if defined JAVA_HOME (
if not ["%JAVA_HOME%"]==[""] (
   set JAVA="%JAVA_HOME%\bin\java.exe"
   call :check_no_java
)) else (
   echo JAVA_HOME is unset.
   set EXIT_CODE=1
)

set LOG_CONFIG="%BASE%\config\logging-config.xml"

set JRE_OPTIONS="-Xmx512m"

set JRE_CP="%BASE%\..\modules\features\oracle.fmwplatform.ocp_lib.jar;%BASE%\..\..\oui\modules\OraInstaller.jar"

set CMD=%JAVA% %JRE_OPTIONS% -cp %JRE_CP% oracle.fmwplatform.configpatch.ConfigPatchCLI %*

if %EXIT_CODE% == 0 (
   %CMD%
)
:: ERRORLEVEL only seems to be set on exiting the block, so repeat.
if %EXIT_CODE% == 0 (
   set EXIT_CODE=%ERRORLEVEL%
)

echo OCP exited with code = %EXIT_CODE%.
if %EXIT_CODE% GTR 0 (
   pause
)
exit /b %EXIT_CODE%

:check_no_java
   for /f "useback tokens=*" %%A in ('%JAVA%') do set shortpath=%%~fsA
   if not exist %shortpath% (
     echo The Java executable %JAVA% does not exist.
     echo Set JAVA_HOME to reference a valid JRE.
     set EXIT_CODE=1
   )

endlocal
