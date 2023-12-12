@ECHO OFF
SETLOCAL

@REM Determine the location of this script...
SET SCRIPTPATH=%~dp0
FOR %%i IN ("%SCRIPTPATH%") DO SET SCRIPTPATH=%%~fsi

@REM Set the MW_HOME relative to this script
FOR %%i IN ("%SCRIPTPATH%\..\..\..") DO SET MW_HOME=%%~fsi

@REM Delegate to the main script...

echo WARNING: This is a deprecated script. Please invoke the config.cmd script under oracle_common/common/bin.

CALL "%MW_HOME%\oracle_common\common\bin\config.cmd" %*

ENDLOCAL
