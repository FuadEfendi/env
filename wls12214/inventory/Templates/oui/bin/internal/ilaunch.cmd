@ECHO OFF

IF "%~1" == "-debug" (
  ECHO DEBUG: ilaunch.cmd: JAVA_HOME=%JAVA_HOME%
)

GOTO BEGIN

:INVOKE

"%JRELOC%\bin\%JAVAEXE%" %JVM_ARGS% %JAVA_OPTIONS% -jar %JAR% %ALLARGS%
SET RETURN_CODE=%ERRORLEVEL%

POPD

@REM PAUSE equivalent implemented in launcher

@REM Use EXIT /b to avoid exiting the invoking cmd.exe if no execUAC
IF "%NOEXECUAC%" == "TRUE" (
  EXIT /b %RETURN_CODE%
)

@REM There is an implicit ENDLOCAL command at the end of a batch file
@REM Use EXIT without /b to ensure exit code is propagated through execUAC
EXIT %RETURN_CODE%

@REM Ensure nothing is stringsubbed before this line

:BEGIN

SET CONSOLEMODE=TRUE
SET JAVAEXE=java.exe

@REM for identifying unsubbed tokens
SET AT=@

@REM OUI platform name used at install time
SET PLATFORM_NAME=@PLATFORM_NAME@

@REM pre-install env: JAVA_HOME_LOCATION not stringsubbed
@REM post-install env: JAVA_HOME_LOCATION is stringsubbed
SET JAVA_HOME_LOCATION=@JAVA_HOME_LOCATION@

SET JAVA_OPTIONS=@JAVA_OPTIONS@
SET HOTSPOT_JAVA_OPTIONS=@HOTSPOT_JAVA_OPTIONS@
SET IBM_JAVA_OPTIONS=@IBM_JAVA_OPTIONS@
SET JROCKIT_JAVA_OPTIONS=@JROCKIT_JAVA_OPTIONS@

@REM Copy args without parsing explicitly using %1 etc.
@REM because cmd parser turns equals sign, comma and possibly others
@REM into white space
@REM See http://support.microsoft.com/kb/35938 : equals sign considered white space
SET ALLARGS=%*

@REM Get drive letter and directory path
SET SCRIPT_PATH=%~dp0

@REM Get fully-qualified short name
FOR %%i in ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM change to OH/oui/bin
@REM ilaunch.cmd is OH/oui/bin/internal/ilaunch.cmd
PUSHD %SCRIPT_PATH%\..

@REM determine the default Java Home location:
@REM 1) if "getProperty JAVA_HOME" provides a value, use it
@REM 2) else if JAVA_HOME_LOCATION is valid, use it
@REM 3) else use env variable JAVA_HOME
@REM Later, this default may be overridden by -jreLoc option

IF EXIST "%SCRIPT_PATH%\getProperty.cmd" (
  %SCRIPT_PATH%\getProperty.cmd JAVA_HOME JRELOC > NUL
)

IF NOT EXIST "%JRELOC%" (
  SET JRELOC=%JAVA_HOME_LOCATION%
)

IF NOT EXIST "%JRELOC%" (
  SET JRELOC=%JAVA_HOME%
)

:PARSEARGS
@REM Expand arg1 and arg2 and remove any surrounding quotation marks
SET ARG1=%~1
SET ARG2=%~2

IF "%ARG1%" == "" (
  GOTO RUN
)

@REM Look for -jreLoc (case insensitive)
@REM which will override the default
IF /i "%ARG1%" == "-jreLoc" (
  SET "JRELOC=%ARG2%"
  SHIFT
  SHIFT
  GOTO PARSEARGS
)

@REM Look for -noconsole (case insensitive) which indicates that no console
@REM was explicitly requested.
IF /i "%ARG1%" == "-noconsole" (
  SET CONSOLEMODE=FALSE
  SET JAVAEXE=javaw.exe
  SHIFT
  GOTO PARSEARGS
)

@REM Look for -nowait (case insensitive) to eliminate final PAUSE
IF /i "%ARG1%" == "-nowait" (
  SET NOWAIT=TRUE
  SHIFT
  GOTO PARSEARGS
)

SHIFT
GOTO PARSEARGS

@REM see launch.sh comment for algorithm to determine Java Home

:RUN
@REM do not refer to JAVA_HOME in the error message
@REM because it is not passed through execUAC if set locally
IF NOT EXIST "%JRELOC%" (
  ECHO ERROR: Cannot determine the Java Home
  ECHO ERROR: Specify the -jreLoc option
  GOTO DOEXIT
)

IF "%JAVA_OPTIONS%" == "%AT%JAVA_OPTIONS%AT%" (
  SET JAVA_OPTIONS=
)

@REM Determine VM_TYPE
@REM Assume HotSpot, look for JRockit
SET VM_TYPE=HotSpot

IF EXIST "%JRELOC%/jre/bin/jrockit" (
  SET VM_TYPE=JRockit
)
IF EXIST "%JRELOC%/bin/jrockit" (
  SET VM_TYPE=JRockit
)

IF "%VM_TYPE%" == "HotSpot" (
  IF NOT "%HOTSPOT_JAVA_OPTIONS%" == "%AT%HOTSPOT_JAVA_OPTIONS%AT%" (
    SET JAVA_OPTIONS=%HOTSPOT_JAVA_OPTIONS% %JAVA_OPTIONS%
  )
)

IF "%VM_TYPE%" == "JRockit" (
  IF NOT "%JROCKIT_JAVA_OPTIONS%" == "%AT%JROCKIT_JAVA_OPTIONS%AT%" (
    SET JAVA_OPTIONS=%JROCKIT_JAVA_OPTIONS% %JAVA_OPTIONS%
  )
)

@REM Use quotes in message in case JRELOC is empty
IF NOT EXIST "%JRELOC%" (
  ECHO ERROR: Java Home "%JRELOC%" does not exist or is not a full path
  GOTO DOEXIT
)

IF NOT EXIST "%JRELOC%\bin\java.exe" (
  ECHO ERROR: Java Home "%JRELOC%" does not contain bin\java.exe
  GOTO DOEXIT
)

IF EXIST ..\modules\ora-launcher.jar (
  SET JAR=..\modules\ora-launcher.jar
) ELSE (
  IF EXIST .\install\modules\ora-launcher.jar (
    SET JAR=.\install\modules\ora-launcher.jar
    ECHO WARNING: not supported when invoked in this context
  ) ELSE (
    ECHO ERROR: Cannot locate launcher
    GOTO DOEXIT
  )
)

GOTO INVOKE

:DOEXIT
POPD

IF "%NOEXECUAC%" == "TRUE" (
  EXIT /b 1
)

@REM No PAUSE if -nowait
IF "%NOWAIT%" == "TRUE" (
  EXIT 1
)

@REM Force response so user can see messages before window closes
IF "%CONSOLEMODE%" == "TRUE" (
  PAUSE
)
@REM Use EXIT without /b to ensure exit code is propagated through execUAC
EXIT 1
