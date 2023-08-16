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

if exist %SCRIPT_PATH%\cam_reconfig.cmd (
  call %SCRIPT_PATH%\cam_reconfig.cmd
)

SET JVM_ARGS=-Dpython.cachedir="%TEMP%\cachedir" %UTILS_MEM_ARGS% %SECURITY_JVM_ARGS% %CONFIG_JVM_ARGS%
SET ARGUMENTS=%* %CAM_ARGUMENTS%

IF EXIST %JAVA_HOME% (
  IF "%ARGUMENTS%" == "" (
    %JAVA_HOME%\bin\javaw %JVM_ARGS% com.oracle.cie.wizard.WizardController -target=reconfig
  ) ELSE (
    %JAVA_HOME%\bin\java %JVM_ARGS% com.oracle.cie.wizard.WizardController -target=reconfig %ARGUMENTS%
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
