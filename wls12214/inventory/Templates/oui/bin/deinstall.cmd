@ECHO OFF

SETLOCAL

SET ALLARGS=%*

@REM ilaunch.exe's default is no console (equivalent of -noconsole)
@REM but OUI's default is -console
SET CONSOLEARG=-console

SET OHOME=@ORACLE_HOME@

@REM Get drive letter and directory path
SET SCRIPT_PATH=%~dp0

@REM Get fully-qualified short name
FOR %%i in ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

:PARSEARGS
SET ARG1=%~1

IF "%ARG1%" == "" (
  GOTO RUN
)

@REM Look for -noconsole which takes precedence here
@REM No attempt here to detect both -console and -noconsole
IF /i "%ARG1%" == "-noconsole" (
  SET CONSOLEARG=
)

@REM variables are case sensitive unlike options
IF "%ARG1%" == "ORACLE_HOME" (
  ECHO WARNING: Ignoring ORACLE_HOME=value on the command line (cannot override the Oracle Home to be deinstalled)
)

SHIFT
GOTO PARSEARGS

:RUN

@REM -console creates new window so error messages are not lost, so
@REM add -console unless -noconsole is explicitly specified.
@REM Execute synchronously so exit code is available
@REM To accommodate GLCM_HOME env:
@REM must allow ORACLE_HOME to be overridden on the command line
@REM so specify the default first.
@REM Command line overrides response file so pass override
@REM ORACLE_HOME= on the command line.
"%SCRIPT_PATH%\internal\ilaunch.exe" %CONSOLEARG% -deinstall ORACLE_HOME="%OHOME%" %ALLARGS%
SET RETURN_CODE=%ERRORLEVEL%

EXIT /b %RETURN_CODE%
