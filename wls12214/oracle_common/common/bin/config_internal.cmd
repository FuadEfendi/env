@ECHO OFF
SETLOCAL

FOR /f %%i in ('cd') do set MYPWD=%%i

SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM Set the ORACLE_HOME relative to this script...
FOR %%i IN ("%SCRIPT_PATH%\..\..") DO SET ORACLE_HOME=%%~fsi

@REM Set the MW_HOME relative to the ORACLE_HOME...
FOR %%i IN ("%ORACLE_HOME%\..") DO SET MW_HOME=%%~fsi

@REM Set the home directories...
CALL "%SCRIPT_PATH%\setHomeDirs.cmd"

@REM Set the config jvm args...

CALL "%SCRIPT_PATH%\commEnv.cmd"

FOR %%i IN ("%JAVA_HOME%") DO SET JAVA_HOME=%%~fsi

SET CLASSPATH=%FMWCONFIG_CLASSPATH%;%DERBY_CLASSPATH%

if exist %SCRIPT_PATH%\cam_config.cmd (
  call %SCRIPT_PATH%\cam_config.cmd
)

SET JVM_ARGS=-Dpython.cachedir="%TEMP%\cachedir" %UTILS_MEM_ARGS% %SECURITY_JVM_ARGS% %CONFIG_JVM_ARGS%
SET MAIN_CLASS=%1

set USER_ARGUMENTS=
shift
:loop1
if "%1"=="" goto after_loop
set USER_ARGUMENTS=%USER_ARGUMENTS% %1
shift
goto loop1

:after_loop


SET ARGUMENTS=%USER_ARGUMENTS% %CAM_ARGUMENTS%
IF EXIST %JAVA_HOME% (
  IF "%ARGUMENTS%" == "" (
    %JAVA_HOME%\bin\javaw %JVM_ARGS% %MAIN_CLASS%

  ) ELSE (
    %JAVA_HOME%\bin\java %JVM_ARGS% %MAIN_CLASS% %ARGUMENTS%

  )
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
