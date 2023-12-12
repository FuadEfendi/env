@ECHO OFF
SETLOCAL

@REM Determine the location of this script...
SET SCRIPTPATH=%~dp0
FOR %%i IN ("%SCRIPTPATH%") DO SET SCRIPTPATH=%%~fsi

@REM Delegate to the common delegation script...
CALL "%SCRIPTPATH%\fmwconfig_common.cmd" reconfig_internal.cmd %*

SET RETURN_CODE=%ERRORLEVEL%

IF DEFINED USE_CMD_EXIT (

  EXIT %RETURN_CODE%

) ELSE (

  EXIT /B %RETURN_CODE%

)

