@ECHO OFF
SETLOCAL

@REM Determine the location of this script...
SET SCRIPTPATH=%~dp0
FOR %%i IN ("%SCRIPTPATH%") DO SET SCRIPTPATH=%%~fsi

@REM Set CURRENT_HOME...
FOR %%i IN ("%SCRIPTPATH%\..\..") DO SET CURRENT_HOME=%%~fsi

@REM Set the MW_HOME relative to the CURRENT_HOME...
FOR %%i IN ("%CURRENT_HOME%\..") DO SET MW_HOME=%%~fsi

@REM Delegate to the COMMON_COMPONENTS_HOME script...
SET WLST_SCRIPT=%MW_HOME%\oracle_common\common\bin\wlst.cmd

echo WARNING: This is a deprecated script. Please invoke the wlst.cmd script under oracle_common/common/bin.

CALL "%WLST_SCRIPT%" %*
