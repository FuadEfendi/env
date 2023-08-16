@ECHO OFF
SETLOCAL

@REM Determine the location of this script...
SET SCRIPTPATH=%~dp0
FOR %%i IN ("%SCRIPTPATH%") DO SET SCRIPTPATH=%%~fsi

@REM Delegate to the common delegation script...
CALL "%SCRIPTPATH%\fmwconfig_common.cmd" qs_config_internal.cmd %*

ENDLOCAL
