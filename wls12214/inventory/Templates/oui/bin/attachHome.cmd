@ECHO OFF

SETLOCAL

SET ALLARGS=%*

@REM ilaunch.exe's default is no console (equivalent of -noconsole)
@REM but OUI's default is -console
SET CONSOLEARG=-console

@REM Initial OHOME is the default value.
@REM In GLCM_HOME env: default must be explicitly overridden on the command line.
SET OHOME=@ORACLE_HOME@
SET OHOMENAME=@ORACLE_HOME_NAME@

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
  SHIFT
  GOTO PARSEARGS
)

@REM variables are case sensitive unlike options
IF "%ARG1%" == "ORACLE_HOME" (
  ECHO WARNING: Ignoring ORACLE_HOME=value on the command line (cannot override the Oracle Home to be attached)
)

SHIFT
GOTO PARSEARGS

:RUN

@REM To accommodate GLCM_HOME env:
@REM must allow ORACLE_HOME to be overridden on the command line
@REM so specify the default first.
@REM Always allow ORACLE_HOME_NAME to be overridden
@REM if attaching to another inventory where name is already present
@REM or if it has changed since initial install by previous attachHome.
@REM Command line overrides response file so pass override
@REM ORACLE_HOME= on the command line.
"%SCRIPT_PATH%\internal\ilaunch.exe" %CONSOLEARG% -attachHome ORACLE_HOME_NAME="%OHOMENAME%" ORACLE_HOME="%OHOME%" %ALLARGS%
SET RETURN_CODE=%ERRORLEVEL%

EXIT /b %RETURN_CODE%
