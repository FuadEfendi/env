@ECHO OFF
SETLOCAL

@REM Determine the location of this script...
SET SCRIPTPATH=%~dp0
FOR %%i IN ("%SCRIPTPATH%") DO SET SCRIPTPATH=%%~fsi

SET INTERNAL_SCRIPT=%1

SET WLS_ORACLE_HOME=@WLS_ORACLE_HOME@
FOR %%i IN ("%WLS_ORACLE_HOME%") DO SET WLS_ORACLE_HOME=%%~fsi

IF EXIST "%WLS_ORACLE_HOME%\oracle_common\common\bin\%INTERNAL_SCRIPT%" (
  SET INTERNAL_SCRIPT_PATH=%WLS_ORACLE_HOME%\oracle_common\common\bin\%INTERNAL_SCRIPT%
) ELSE (
  SET INTERNAL_SCRIPT_PATH=%SCRIPTPATH%\%INTERNAL_SCRIPT%
)

@REM Removes the first argument which is the internal script name
for /f "tokens=1,* delims= " %%a in ("%*") do set ARGS=%%b

@REM Delegate to the common delegation script...
CALL "%INTERNAL_SCRIPT_PATH%" %ARGS%

SET RETURN_CODE=%ERRORLEVEL%

IF DEFINED USE_CMD_EXIT (
  EXIT %RETURN_CODE%
) ELSE (
  EXIT /B %RETURN_CODE%
)
