@ECHO OFF
SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi
FOR %%i IN ("%SCRIPT_PATH%\..\..\..") DO SET MW_HOME=%%~fsi

CALL "%MW_HOME%\oracle_common\common\bin\setWlstEnv_internal.cmd"
