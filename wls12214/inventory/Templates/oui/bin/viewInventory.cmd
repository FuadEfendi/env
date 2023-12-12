@ECHO OFF

SETLOCAL

@REM for identifying unsubbed tokens
SET AT=@

@REM OUI platform name used at install time
SET PLATFORM_NAME=@PLATFORM_NAME@

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

@REM determine the default Java Home location:
@REM 1) if "getProperty JAVA_HOME" provides a value, use it
@REM 2) else if JAVA_HOME_LOCATION is valid, use it
@REM 3) else use env variable JAVA_HOME
@REM Later, this default may be overridden by -jreLoc option

IF EXIST "%SCRIPT_PATH%\getProperty.cmd" (
  CALL %SCRIPT_PATH%\getProperty.cmd JAVA_HOME JRELOC > NUL
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

@REM Look for -jreLoc
IF /i "%ARG1%" == "-jreLoc" (
	SET JRELOC=%ARG2%
	SHIFT
	SHIFT
	GOTO PARSEARGS
)

SHIFT
GOTO PARSEARGS

:RUN
IF NOT EXIST "%JRELOC%" (
	ECHO ERROR: Cannot determine the Java Home
	ECHO ERROR: Specify the -jreLoc option or set JAVA_HOME
	GOTO DOEXIT
)

IF "%JAVA_OPTIONS%" == "%AT%JAVA_OPTIONS%AT%" (
	SET JAVA_OPTIONS=
)

@REM Determine VM_TYPE
@REM Assume HotSpot, look for JRockit
SET VM_TYPE=HotSpot

IF EXIST %JRELOC%/jre/bin/jrockit (
	SET VM_TYPE=JRockit
)
IF EXIST %JRELOC%/bin/jrockit (
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

@REM change to OH/oui/bin
PUSHD %SCRIPT_PATH%

IF NOT EXIST "%JRELOC%\bin\java.exe" (
	ECHO ERROR: Java Home "%JRELOC%" does not contain bin\java.exe
	GOTO DOEXIT
)

IF EXIST ..\modules\gdr-external.jar (
	SET JAR=..\modules\gdr-external.jar
) ELSE (
	ECHO ERROR: Cannot locate Inventory Dump tool
	ECHO Invoke this script from ORACLE_HOME\oui\bin
	GOTO DOEXIT
)
"%JRELOC%\bin\java.exe" %JVM_ARGS% -classpath %JAR% com.oracle.cie.gdr.tools.InventoryDump %ALLARGS%
SET RETURN_CODE=%ERRORLEVEL%

POPD

@REM Force response so user can see messages before window closes
IF "%CONSOLEMODE%" == "TRUE" (
	PAUSE
)

ENDLOCAL & SET RETURN_CODE=%RETURN_CODE%
EXIT /b %RETURN_CODE%


:DOEXIT
@REM Force response so user can see messages before window closes
IF "%CONSOLEMODE%" == "TRUE" (
	PAUSE
)
ENDLOCAL

EXIT /b 1
