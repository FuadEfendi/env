@ECHO OFF
SETLOCAL

SET SCRIPTPATH=%~dp0

@REM Delegate to the main script...
CALL "%SCRIPTPATH%\auto\core\bin\opatchauto.cmd" %*
SET RETURNCODE=%ERRORLEVEL%
IF NOT "%RETURNCODE%"=="0" (
  EXIT /B %RETURNCODE%
)

ENDLOCAL
