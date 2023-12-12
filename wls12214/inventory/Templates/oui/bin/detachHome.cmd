@ECHO OFF

SETLOCAL

SET ALLARGS=%*

SET OHOME=@ORACLE_HOME@

@REM Get drive letter and directory path
SET SCRIPT_PATH=%~dp0

@REM Get fully-qualified short name
FOR %%i in ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM detachHome no longer calls execUAC (ilaunch.exe)
@REM to avoid UAC prompt for non-interactive usage
@REM because detachHome does not modify Windows registry.
@REM Implication: privilege is not elevated, therefore updates to
@REM central inventory by ora-installer may fail.
@REM Communicate no execUAC via env variable only.
@REM To accommodate GLCM_HOME env:
@REM must allow ORACLE_HOME to be overridden on the command line.
@REM Command line overrides response file so pass override
@REM ORACLE_HOME= on the command line.
SET NOEXECUAC=TRUE
"%SCRIPT_PATH%\internal\ilaunch.cmd" -detachHome ORACLE_HOME="%OHOME%" %ALLARGS%
SET RETURN_CODE=%ERRORLEVEL%

EXIT /b %RETURN_CODE%
