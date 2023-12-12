
@REM pasteBinary.cmd
@REM
@REM Copyright (c) 2010, 2017, Oracle and/or its affiliates. All rights reserved. 
@REM
@REM    NAME
@REM      pasteBinary.cmd - Script to paste Oracle Middleware Home binary
@REM
@REM    DESCRIPTION
@REM     This script is used to paste the Middleware Home binaries.
@REM     This script invokes the OUI implementation and has one mandatory parameter
@REM     to call the implementation.
@REM
@REM      -javaHome   - java home location.
@REM      -archiveLoc   - file path of the package
@REM      -targetOracleHomeLoc   - place where the oracle home will be unpacked
@REM
@REM    NOTES
@REM      Based on the copyBinary.cmd created by ASINST team
@REM

@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
SET OUI_TEMP=%~dp0\..
CALL :OUISETTER %OUI_TEMP%

SET RETURN_CODE=0
SET IS_CLONE="0"

for /f %%i in ('echo %cd%') do SET CUR_PATH=%%i
SET SCRIPT_PATH=%~0
SET SCRIPT_PATH=%SCRIPT_PATH:pasteBinary.cmd= %

set "tmpargs=%*"
if !tmpargs!=="" goto help

@REM ### PARSE OPTIONS ###

set EMPTY_OPTION=@@EMPTY@@
set "option="
set LAST_ARG=

:Loop
IF "%~1"=="" GOTO Continue
   set LAST_ARG=%~1
   if not defined option (
   
      set arg=%LAST_ARG%
      if "!arg:~0,1!" equ "-" set "option=!arg!"
	  
   ) else (
   
	  set arg=%LAST_ARG%
	  
	  if "!arg:~0,1!" equ "-" (
	  
		set "option!option!=%EMPTY_OPTION%"
		set "option="
		set "option=!arg!"
		
	  ) else (
	  
		set "option!option!=%LAST_ARG%"
		set "option="
		
	  )
   )
SHIFT
GOTO Loop

:Continue
@REM ### IF LAST ARG WAS AN EMPTY OPTION ###
if "!LAST_ARG:~0,1!" equ "-" (
	set option%LAST_ARG%=%EMPTY_OPTION%
)
@REM ### PREPARE LAUNCH ARGUMENTS ###

@REM ### VALIDATE OPTIONS ###

SET LAUNCH_ARGS=

IF NOT "%option-ohAlreadyCloned%"=="" (
	IF "%option-ohAlreadyCloned%"=="true" (
		call :addOptionalOption "%option-ohAlreadyCloned%" -clone
		SET IS_CLONE="1"
	)
)

IF %IS_CLONE% equ "1" (
	IF NOT "%option-archiveLoc%"=="" call :addOptionalOption "%option-archiveLoc%" -archiveLoc
) ELSE (
	IF "%option-archiveLoc%"=="" goto paramsincorrect
	CALL :addRequiredOption "%option-archiveLoc%" -archiveLoc
)

IF "%option-targetOracleHomeLoc%"=="" goto paramsincorrect
CALL :addRequiredVariable "%option-targetOracleHomeLoc%" ORACLE_HOME

IF NOT "%option-targetOracleHomeName%"=="" call :addOptionalVariable "%option-targetOracleHomeName%" ORACLE_HOME_NAME

IF NOT "%option-executeSysPrereqs%"=="" (
	IF "%option-executeSysPrereqs%"=="true" (
		IF NOT "%option-prereqConfigLoc%"=="" call :addOptionalOption "%option-prereqConfigLoc%" -prereqConfigLoc
		IF NOT "%option-entryPoint%"=="" call :addOptionalOption "%option-entryPoint%" -entryPoint
	)
)

IF NOT "%option-javaHome%"=="" call :addOptionalOption "%option-javaHome%" -jreLoc
IF NOT "%option-silent%"=="" call :addOptionalOption "%option-silent%" -silent
IF NOT "%option-ignoreDiskWarning%"=="" call :addOptionalOption "%option-ignoreDiskWarning%" -ignoreDiskWarning
IF NOT "%option-ignoreJavaVersion%"=="" call :addOptionalOption "%option-ignoreJavaVersion%" -ignoreJavaVersion

@REM ### VALIDATE JAVA ###

if NOT "%option-javaHome%"=="" (
	if NOT exist "%option-javaHome%\bin\java.exe" (
		echo  Java Home location is invalid as "%option-javaHome%\bin\java.exe" does not exist.
        SET RETURN_CODE=1
		goto end
	)	
)

@REM ### VALIDATE LAUNCH.CMD ###
cd %SCRIPT_PATH%

if NOT exist "..\..\oui\bin\launch.cmd" (
	echo This script is not executed from bin directory of ORACLE_HOME\oracle_common as launch.cmd is not available under bin directory of ORACLE_HOME\oui . Execute from bin directory.
        SET RETURN_CODE=1
	goto end	
)

cd %CUR_PATH%

:invokeLauncher
cd %SCRIPT_PATH%

IF %IS_CLONE% equ "1" (
	set ERRORLEVEL=
	"..\..\oui\bin\launch.cmd" -silent -nowait %LAUNCH_ARGS%
) ELSE (
	set ERRORLEVEL=
	"..\..\oui\bin\launch.cmd" -applyCloneArchive -nowait %LAUNCH_ARGS%
)
SET RETURN_CODE=%ERRORLEVEL%

cd %CUR_PATH%

goto end

:OUISETTER %TEMP_CH%
SETLOCAL ENABLEEXTENSIONS
ENDLOCAL&SET OUI=%~f1&goto :EOF

:paramsincorrect
SET RETURN_CODE=1
goto help

:help
echo usage: 
echo        Options in brackets [] are optional
echo.
echo        pasteBinary.cmd
echo.
echo        -archiveLoc archive_location
echo        -targetOracleHomeLoc target_Oracle_Home
echo.
echo        [-javaHome java_home]
echo        [-silent true^|false]
echo        [-ignoreDiskWarning false^|true]
echo        [-ignoreJavaVersion false^|true]
echo        [-targetOracleHomeName target_Oracle_Home_name]
echo        [-ohAlreadyCloned false^|true]  * If true then -archiveLoc is optional
echo        [-prereqConfigLoc prereqs_file_location]
echo        [-entryPoint entry_point_name]
echo        [-executeSysPrereqs false^|true]
echo.
echo Try "pasteBinary.cmd -help"  for more information.
echo.
echo If pasteBinary is not available it can also be invoked from package like:
echo.
echo        java -jar archive_location -targetOracleHomeLoc target_Oracle_Home
echo.
echo For more information you can also call:
echo.
echo        java -jar archive_location -help
goto end

:end
EXIT /B %RETURN_CODE%

@REM ### VALIDATION FUNCTIONS ###

:addRequiredOption
SET VALIDATE_OPTION=%~1
SET LAUNCH_OPTION=%~2
IF "%VALIDATE_OPTION%"=="%EMPTY_OPTION%" (
	goto paramsincorrect
) ELSE (
	SET LAUNCH_ARGS=%LAUNCH_ARGS% %LAUNCH_OPTION% %VALIDATE_OPTION%
)
goto:eof

:addRequiredVariable
SET VALIDATE_OPTION=%~1
SET LAUNCH_OPTION=%~2
IF "%VALIDATE_OPTION%"=="%EMPTY_OPTION%" (
	goto paramsincorrect
) ELSE (
	SET LAUNCH_ARGS=%LAUNCH_ARGS% %LAUNCH_OPTION%=%VALIDATE_OPTION%
)
goto:eof

:addOptionalOption
SET VALIDATE_OPTION=%~1
SET LAUNCH_OPTION=%~2
IF "%VALIDATE_OPTION%"=="%EMPTY_OPTION%" (
	SET LAUNCH_ARGS=%LAUNCH_ARGS% %LAUNCH_OPTION%
) ELSE (
	SET LAUNCH_ARGS=%LAUNCH_ARGS% %LAUNCH_OPTION% %VALIDATE_OPTION%
)
goto:eof

:addOptionalVariable
SET VALIDATE_OPTION=%~1
SET LAUNCH_OPTION=%~2
IF "%VALIDATE_OPTION%"=="%EMPTY_OPTION%" (
	SET LAUNCH_ARGS=%LAUNCH_ARGS% %LAUNCH_OPTION%=true
) ELSE (
	SET LAUNCH_ARGS=%LAUNCH_ARGS% %LAUNCH_OPTION%=%VALIDATE_OPTION%
)
goto:eof
