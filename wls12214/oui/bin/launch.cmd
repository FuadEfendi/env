@ECHO OFF

@REM Ensure no stringsubs occur for this script
@REM so it's not overwritten during cloning

SETLOCAL

SET ALLARGS=%*

@REM ilaunch.exe's default is no console (equivalent of -noconsole)
@REM but OUI's default is -console
SET CONSOLEARG=-console

@REM Get drive letter and directory path
SET SCRIPT_PATH=%~dp0

@REM Get fully-qualified short name
FOR %%i in ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM Look for -noconsole which takes precedence here
@REM No attempt here to detect both -console and -noconsole
:PARSEARGS
SET ARG1=%~1

IF "%ARG1%" == "" (
  GOTO RUN
)

IF /i "%ARG1%" == "-noconsole" (
  SET CONSOLEARG=
)

IF /i "%ARG1%" == "-debug" (
  SET DEBUGARG=-debug
)

@REM omit execUAC for operations that do not modify Windows registry
@REM or modify Windows "system" files (start menu, ...)
IF /i "%ARG1%" == "-detachHome" (
  SET NOEXECUAC=TRUE
)

IF /i "%ARG1%" == "-prereqchecker" (
  SET NOEXECUAC=TRUE
)

SHIFT
GOTO PARSEARGS

:RUN

@REM -console creates new window so error messages are not lost, so
@REM add -console unless -noconsole is explicitly specified.
@REM Execute synchronously so exit code is available

IF DEFINED DEBUGARG (
  ECHO DEBUG: launch.cmd: JAVA_HOME=%JAVA_HOME%
)

@REM ensure -debug is 1st arg so it can be found by ilaunch.cmd

IF "%NOEXECUAC%" == "TRUE" (
  "%SCRIPT_PATH%\internal\ilaunch.cmd" %DEBUGARG% %ALLARGS%
) ELSE (
  "%SCRIPT_PATH%\internal\ilaunch.exe" %DEBUGARG% %CONSOLEARG% %ALLARGS%
)
SET RETURN_CODE=%ERRORLEVEL%

ENDLOCAL & SET RETURN_CODE=%RETURN_CODE%
EXIT /b %RETURN_CODE%
