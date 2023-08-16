@ECHO OFF

SETLOCAL

@REM for identifying unsubbed tokens
SET AT=@

@REM pre-install env: JAVA_HOME_LOCATION not stringsubbed
@REM post-install env: JAVA_HOME_LOCATION is stringsubbed

@REM Get drive letter and directory path
SET SCRIPT_PATH=%~dp0
@REM Get fully-qualified short name
FOR %%i in ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM ORACLE_HOME is the parent directory of the "oui\mw\common\framework\bin" dir where the script is located
@REM Set the ORACLE_HOME relative to this script...
FOR %%i IN ("%SCRIPT_PATH%\..\..\..\..\..") DO SET ORACLE_HOME=%%~fsi

@REM Set JRELOC
if exist "%ORACLE_HOME%\oui\bin\getProperty.cmd" (
@REM INVOKE SCRIPT TO SET THE JAVA_HOME
CALL %ORACLE_HOME%\oui\bin\getProperty.cmd JAVA_HOME JRELOC
)

@REM SET JAVA_OPTIONS=@JAVA_OPTIONS@
@REM SET HOTSPOT_JAVA_OPTIONS=@HOTSPOT_JAVA_OPTIONS@
@REM SET IBM_JAVA_OPTIONS=@IBM_JAVA_OPTIONS@
@REM SET JROCKIT_JAVA_OPTIONS=@JROCKIT_JAVA_OPTIONS@

SET JAVA_OPTIONS=
SET HOTSPOT_JAVA_OPTIONS=-mx512m -XX:MaxPermSize=512m -Doracle.installer.appendjre=true
SET IBM_JAVA_OPTIONS=-mx512m -XX:MaxPermSize=512m -Xverify:none -Doracle.installer.appendjre=true
SET JROCKIT_JAVA_OPTIONS=-mx512m -Doracle.installer.appendjre=true

@REM Copy args without parsing explicitly using %1 etc.
@REM because cmd parser turns equals sign, comma and possibly others
@REM into white space
@REM See http://support.microsoft.com/kb/35938 : equals sign considered white space
SET ALLARGS=%*

:PARSEARGS
@REM Expand arg1 and arg2 and remove any surrounding quotation marks
SET ARG1=%~1
SET ARG2=%~2

IF "%ARG1%" == "" (
	GOTO RUN
)

@REM Look for -jreLoc
IF "%ARG1%" == "-jreLoc" (
	SET JRELOC=%ARG2%
	SHIFT
	SHIFT
	GOTO PARSEARGS
)

@REM Look for -mode=console which indicates that install.cmd was invoked
@REM by install.exe and a console window has been opened
@REM (otherwise, console output is lost).
@REM So PAUSE when exiting so that the console window is not closed
@REM before the user has a chance to see the messages
IF "%ARG1%" == "-mode" (
	IF "%ARG2%" == "console" (
		SET CONSOLEMODE=TRUE
		SHIFT
		SHIFT
		GOTO PARSEARGS
	)
)

SHIFT
GOTO PARSEARGS

@REM see install.sh comment for algorithm to determine Java Home

:RUN
IF "%JRELOC%" == "" (
	IF NOT DEFINED JAVA_HOME (
		ECHO ERROR: Must specify -jreLoc option or set JAVA_HOME
		GOTO DOEXIT
	)
	SET JRELOC=%JAVA_HOME%
)

IF "%JRELOC%" == "%AT%JAVA_HOME_LOCATION%AT%" (
	IF NOT DEFINED JAVA_HOME (
		ECHO ERROR: Must specify -jreLoc option or set JAVA_HOME
		GOTO DOEXIT
	)
	SET JRELOC=%JAVA_HOME%
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

@REM change to Disk1 or OH/oui/bin
PUSHD %SCRIPT_PATH%

@REM Use quotes in message in case JRELOC is empty
IF NOT EXIST "%JRELOC%" (
	ECHO ERROR: Java Home "%JRELOC%" does not exist
	GOTO DOEXIT
)

IF NOT EXIST "%JRELOC%\bin\java.exe" (
	ECHO ERROR: Java Home "%JRELOC%" does not contain bin\java.exe
	GOTO DOEXIT
)

IF EXIST ..\jlib\ConfigLauncher.jar (
	SET JAR=..\jlib\ConfigLauncher.jar
) ELSE (
	IF EXIST ..\jlib\ConfigLauncher.jar (
		SET JAR=..\jlib\ConfigLauncher.jar
	) ELSE (
		ECHO ERROR: Cannot locate launcher
		ECHO Invoke this script from ORACLE_HOME\oui\bin or Disk1
		GOTO DOEXIT
	)
)

@REM SET CJ="..\..\..\..\modules\com.oracle.cie.comdev_7.1.0.0.jar;..\..\..\..\modules/com.oracle.cie.xmldh_2.7.0.0.jar;..\..\..\..\modules\com.oracle.cie.ora-installer_12.1.0.0.jar;..\..\..\..\modules\com.oracle.cie.oui-common_12.1.0.0.jar;%JAR%"

SET CJ="..\..\..\..\modules\installer-launch.jar;%JAR%"

@REM "%JRELOC%\bin\java.exe" %JVM_ARGS% %JAVA_OPTIONS% -cp %CJ% oracle.as.install.configlauncher.ConfigLauncher %ALLARGS%
"%JRELOC%\bin\java.exe" %JVM_ARGS% %JAVA_OPTIONS% -cp %CJ% oracle.as.install.configlauncher.GLCMConfigLauncher %ALLARGS%
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
