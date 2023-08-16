@ECHO OFF
SETLOCAL

@REM utility to update jdk variable value
SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi
SET MAIN_CLASS="com.oracle.cie.domain.info.VariableModifier"
@REM Delegate to the common delegation script...
CALL "%SCRIPTPATH%\fmwconfig_common.cmd" config_internal.cmd %MAIN_CLASS% %*

SET RETURN_CODE=%ERRORLEVEL%

IF DEFINED USE_CMD_EXIT (

  EXIT %RETURN_CODE%

) ELSE (

  EXIT /B %RETURN_CODE%

)