@ECHO OFF
SETLOCAL

SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM Set CURRENT_HOME...
FOR %%i IN ("%SCRIPT_PATH%\..\..") DO SET CURRENT_HOME=%%~fsi

@REM Set the MW_HOME relative to the CURRENT_HOME...
FOR %%i IN ("%CURRENT_HOME%\..") DO SET MW_HOME=%%~fsi

call %MW_HOME%\oracle_common\common\bin\setWlstEnv_internal.cmd
IF EXIST %JAVA_HOME% (
 "%JAVA_HOME%\bin\java" %JVM_ARGS% weblogic.WLST %*
) ELSE (
  CALL :SET_RC 1
)

SET RETURN_CODE=%ERRORLEVEL%

IF DEFINED USE_CMD_EXIT (
  EXIT %RETURN_CODE%
) ELSE (
  EXIT /B %RETURN_CODE%
)

:SET_RC
EXIT /B %1

