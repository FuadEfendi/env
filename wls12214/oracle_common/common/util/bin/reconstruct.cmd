@ECHO OFF
SETLOCAL

SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

CALL :PARSEARGS %*
if {%MW_HOME%}=={} (
  ECHO ERROR! Location of original MW HOME not specified
  EXIT /B 1
)

@REM Set the home directories...
CALL "%MW_HOME%\oracle_common\common\bin\setHomeDirs.cmd"

@REM Set the config jvm args...

CALL "%WL_HOME%\common\bin\commEnv.cmd"

FOR %%i IN ("%JAVA_HOME%") DO SET JAVA_HOME=%%~fsi
FOR %%i IN ("%SCRIPT_PATH%..\modules\com.oracle.cie.template-repo_1.0.0.0.jar") DO SET FMW_UTIL_MODULE=%%~fsi

SET CLASSPATH=%FMW_UTIL_MODULE%;%FMWCONFIG_CLASSPATH%;%DERBY_CLASSPATH%

SET JVM_ARGS=-Dprod.props.file="%WL_HOME%\.product.properties" -DMW_HOME=%MW_HOME% -Dpython.cachedir="%TEMP%\cachedir" %MEM_ARGS% %CONFIG_JVM_ARGS%

IF EXIST %JAVA_HOME% (
  IF "%#" == 0 (
    %JAVA_HOME%\bin\javaw %JVM_ARGS% com.oracle.cie.external.domain.ReconstructDomain
  ) ELSE (
    %JAVA_HOME%\bin\java %JVM_ARGS% com.oracle.cie.external.domain.ReconstructDomain %*
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

:PARSEARGS
if NOT {%1}=={} (
  GOTO :SETARG
) ELSE (
  GOTO :EOF
)

:SETARG
SET ARGNAME=%1
SET ARGVALUE=%2
FOR %%I IN (%1) DO SET ARGNAME=%%~I
IF /i "%ARGNAME%"=="-mwh" (
  FOR %%i IN ("%ARGVALUE%") DO SET MW_HOME=%%~fsi
)
SHIFT
GOTO :PARSEARGS
