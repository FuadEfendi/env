@ECHO OFF
SETLOCAL

SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM Set the ORACLE_HOME relative to this script...
FOR %%i IN ("%SCRIPT_PATH%\..\..") DO SET ORACLE_HOME=%%~fsi

@REM Set the MW_HOME relative to the ORACLE_HOME...
FOR %%i IN ("%ORACLE_HOME%\..") DO SET MW_HOME=%%~fsi

@REM Set the home directories...
CALL "%SCRIPT_PATH%\setHomeDirs.cmd"

CALL "%SCRIPT_PATH%\commEnv.cmd"

SET CLASSPATH=%FMWCONFIG_CLASSPATH%;%DERBY_CLASSPATH%;%POINTBASE_CLASSPATH%

if exist %SCRIPT_PATH%\cam_pack.cmd (
  call %SCRIPT_PATH%\cam_pack.cmd
)

SET JVM_ARGS=%UTILS_MEM_ARGS% %SECURITY_JVM_ARGS% %CONFIG_JVM_ARGS%

IF EXIST %JAVA_HOME% (
  %JAVA_HOME%\bin\java %JVM_ARGS% com.oracle.cie.domain.script.Packer %*
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
