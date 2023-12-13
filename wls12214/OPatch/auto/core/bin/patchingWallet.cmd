@ECHO OFF
SETLOCAL

SET SCRIPTPATH=%~dp0

CALL "%SCRIPTPATH%\opatchautoEnv.cmd"
SET RETURNCODE=%ERRORLEVEL%
IF NOT "%RETURNCODE%"=="0" (
  EXIT /B %RETURNCODE%
)

%OPATCHAUTO_JAVA_HOME%\bin\java.exe %OPATCHAUTO_JVM_ARGS% -cp %OPATCHAUTO_CLASSPATH% com.oracle.glcm.patch.wallet.WalletTool %*

ENDLOCAL