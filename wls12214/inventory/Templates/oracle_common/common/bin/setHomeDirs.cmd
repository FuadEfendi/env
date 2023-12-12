@ECHO OFF

FOR %%i IN ("%MW_HOME%") DO SET MW_HOME=%%~fsi

SET WL_HOME=%MW_HOME%\wlserver
FOR %%i IN ("%WL_HOME%") DO SET WL_HOME=%%~fsi

@REM Set common components home...
SET COMMON_COMPONENTS_HOME=%MW_HOME%\oracle_common
IF EXIST %COMMON_COMPONENTS_HOME% FOR %%i IN ("%MW_HOME%\oracle_common") DO SET COMMON_COMPONENTS_HOME=%%~fsi

if DEFINED JAVA_HOME if  DEFINED JAVA_VENDOR goto noReset
IF EXIST "%JAVA_HOME%" SET ORIGINAL_JAVA_HOME=%JAVA_HOME%

@REM The call below sets JAVA_HOME
call "%MW_HOME%\oui\bin\getProperty.cmd" JAVA_HOME

IF EXIST "%JAVA_HOME%" ( 
  SET JAVA_VENDOR=@JAVA_VENDOR@
) ELSE (
  IF DEFINED ORIGINAL_JAVA_HOME SET JAVA_HOME=%ORIGINAL_JAVA_HOME%
)

IF NOT EXIST "%JAVA_HOME%" (
 echo The jdk %JAVA_HOME% is not accessible.
 echo Please set appropriate JAVA_HOME and run again.
 IF DEFINED USE_CMD_EXIT (
  EXIT 1
 ) ELSE (
  EXIT /B 1
 )
)

:noReset
FOR %%i IN ("%JAVA_HOME%") DO SET JAVA_HOME=%%~fsi
