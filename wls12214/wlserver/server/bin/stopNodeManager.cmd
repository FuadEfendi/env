@echo off
@rem *************************************************************************
@rem This script can be used to stop the NodeManager
@rem
@rem
@rem This script sets the following variables before stopping the NodeManager:
@rem 
@rem WL_HOME        - The root directory of your WebLogic installation.
@rem NODEMGR_HOME   - The root directory for this NodeManagerInstance.
@rem ROOT_DIRECTORY - Set by per-domain NodeManager, defaulting to NODEMGR_HOME
@rem MATCH_STRING   - The -Dweblogic.RootDirectory=$ROOT_DIRECTORY to match
@rem *************************************************************************
@rem Important internal variables:
@rem *************************************************************************
SETLOCAL ENABLEEXTENSIONS

set WL_HOME=c:\Users\xiaol\Downloads\wls\wls12214\wlserver
call "%WL_HOME%\..\oracle_common\common\bin\commEnv.cmd"

:: Set the time zone string
for /f "tokens=2*"  %%a in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v TimeZoneKeyName') do set TZ_STR=%%b
if DEFINED DEBUG echo The timezone string is:  %TZ_STR%

@rem Set user-defined variables
if "%NODEMGR_HOME%"=="" (
  set NODEMGR_HOME=%WL_HOME%\..\oracle_common\common\nodemanager
) else (
  call :info "NODEMGR_HOME is already set to %NODEMGR_HOME%"
)
if "%ROOT_DIRECTORY%"=="" (
  set ROOT_DIRECTORY=%NODEMGR_HOME%
) else (
  call :info "ROOT_DIRECTORY is already set to %ROOT_DIRECTORY%"
)

:: Windows will not allow us to append to the logfile while NM is still running
set LOGFILE=%NODEMGR_HOME%\nodemanager.log
set TEMPLOGFILE=%NODEMGR_HOME%\stopnodemanager.log

call :DELTEMPLOG
call :info BEGIN

for %%i in ("%WL_HOME%") do set WL_HOME=%%~fsi
for %%i in ("%JAVA_HOME%") do set JAVA_HOME=%%~fsi
for %%i in ("%NODEMGR_HOME%") do set NODEMGR_HOME=%%~fsi
for %%i in ("%ROOT_DIRECTORY%") do set ROOT_DIRECTORY=%%~fsi

set MATCH_STRING=-Dweblogic.RootDirectory=%ROOT_DIRECTORY%
call :debug MATCH_STRING is %MATCH_STRING%

@rem If NODEMGR_HOME does not exist, 
@rem JWM-- so, if we get a value for NODEMGR_HOME and then figure out that it's not a directory, we 
@rem JWM-- **silently** switch to using whatever the PWD happens to be? -- this just seems wrong
if not exist %NODEMGR_HOME% (
  call :error "NODEMGR_HOME is not a directory: %NODEMGR_HOME%. Using %CD%"
  set NODEMGR_HOME=%CD%
) 

@rem Bail if not a proper directory
IF EXIST %NODEMGR_HOME%\NUL GOTO DIROK 
call :error "Fatal Error: %NODEMGR_HOME% is not a directory."
GOTO:FINIS

:DIROK
cd %NODEMGR_HOME%
set PIDFILE=%NODEMGR_HOME%\nodemanager.process.id
set PROCESSLOCKFILE=%NODEMGR_HOME%\nodemanager.process.lck
IF NOT EXIST %PIDFILE% GOTO NOPIDFILE 


:: Make sure the file, which is now guaranteed to exist, is not empty
FOR /F %%i IN ("%PIDFILE%") DO set LENGTH=%%~zi
if %LENGTH% GTR 0 GOTO PIDFILEOK
call :error "NodeManager process id not found in empty file %PIDFILE%"
GOTO NOPIDINPIDFILE

:PIDFILEOK
for /f "tokens=1" %%i in (%PIDFILE%) do set PID=%%i 
if NOT DEFINED PID (
 call :info "NodeManager process id not found in file: %PIDFILE%"
 GOTO NOPIDINPIDFILE
) else (
 if %PID% GTR 0 (
   call :info "Found process id from %PIDFILE%: %PID%"
   GOTO PIDOK
 ) else (
  call :error "NodeManager process id not available in file: %PIDFILE%, possibly because the NodeManager process failed to write out its PID due to lack of native library."
  GOTO NOPIDINPIDFILE
 )
) 

:NOPIDFILE 
call :error "Could not find the file containing the pid.  It is supposed to be here: %PIDFILE%"
:NOPIDINPIDFILE
@rem todo check on just java_home
set JPS=%JAVA_HOME%\bin\jps.exe
if exist %JPS% GOTO JPSOK
call :error "Could not find the JDK program, jps.exe.  It could be used to find the Process ID of the NodeManager.  It is supposed to be here: %JPS%"
GOTO:FINIS

:JPSOK 
for /f %%a in ('jps -v ^| findstr NodeManager ^| findstr /L /C:%MATCH_STRING%') do set PID=%%a
if NOT DEFINED PID GOTO NOPIDFROMJPS
if NOT %PID% GTR 0 GOTO BADPIDFROMJPS

:PIDOK
call :checkstopped
if %IS_STOPPED% EQU 0 GOTO :RUNOK
@rem very unlikely.  But possible.
call :warning "The NodeManager process, %PID%, is not running"
GOTO:FINIS

:RUNOK 
call :info "Attempting to kill the NodeManager process, %PID%, with taskkill"
taskkill /f /pid %PID%
call :checkstopped
if %IS_STOPPED% NEQ 0 GOTO :KILLOK
call :info "It is possible that the current user has insufficient permissions for operations on: %PID%. Try running this again as a user with confirmed, adequate permissions to successfully issue 'taskkill' commands to any listed surviving process."

call :error "Could not kill the Nodemanager Process (%PID%)"
GOTO:FINIS

:NOPIDFROMJPS
call :error "Could not determine the Process ID using jps and looking for both strings NodeManager and %MATCH_STRING%"
GOTO:FINIS

:BADPIDFROMJPS
call :error  "The Process ID for NodeManager from jps was not an integer greater than zero"
GOTO:FINIS

:KILLOK
call :info "NodeManager stopped successfully"

:DELPIDFILE
del %PIDFILE%
if not exist %PIDFILE% GOTO PIDFILEDELETED 
call :warning "The file with the pid, %PIDFILE%, could not be deleted.  Please delete it manually."
GOTO:DELLOCKFILE

:PIDFILEDELETED 
call :info "The file with the pid, %PIDFILE%, was successfully deleted."

:DELLOCKFILE
del %PROCESSLOCKFILE%
if not exist %PROCESSLOCKFILE% GOTO LOCKFILEDELETED 
call :warning "The NodeManager process lock file could not be deleted.  Please delete it manually."
GOTO:FINIS

:LOCKFILEDELETED 
call :info "The NodeManager process lock file was successfully deleted."
GOTO:FINIS

:: ------------------------------------------------------------
:: -------------------  all "functions" are below -------------
:: ------------------------------------------------------------

:checkstopped
@rem tasklist always returns 0, findstr returns 1 if no match
tasklist /FO LIST /FI "PID eq %PID%" | findstr %PID%
set IS_STOPPED=%ERRORLEVEL%
GOTO:EOF

:msg
    set msgType=%1
    shift
    set msg="<%date% %time% %TZ_STR%> <%msgType%> <StopNodeManager> <%~1>"
    echo %msg%
    call :writeToNMLog %msg%
GOTO:EOF

:info
   call :msg INFO %1
GOTO:EOF

:warning
   call :msg WARNING %1
GOTO:EOF

:error
   call :msg ERROR %1
GOTO:EOF

:: In Windows it is OK to "append" to a file that doesn't exist yet...
:writeToNMLog 
   if NOT DEFINED TEMPLOGFILE GOTO:EOF
	echo %1 >> %TEMPLOGFILE%
GOTO:EOF

:debug
if NOT DEFINED DEBUG GOTO:EOF
echo **********  DEBUG  **********
echo %1 %2 %3 %4 %5
echo **********  DEBUG  **********
GOTO:EOF

:DELTEMPLOG
if NOT DEFINED TEMPLOGFILE GOTO:EOF
if NOT EXIST %TEMPLOGFILE% GOTO:EOF
del %TEMPLOGFILE%
if EXIST %TEMPLOGFILE% (
    call :warning  "can't delete %TEMPLOGFILE% Please delete it manually and then run this script again."
)
GOTO:EOF


:FINIS - handle log files
:: don't wipe out the temp file in case something was screwy.
if NOT DEFINED TEMPLOGFILE GOTO:EOF
if NOT EXIST %TEMPLOGFILE% GOTO:EOF
if NOT DEFINED LOGFILE GOTO:EOF
if NOT EXIST %LOGFILE% (
  copy %TEMPLOGFILE% %LOGFILE% > NUL 2>&1 
  echo %TEMPLOGFILE% was copied to %LOGFILE% 
) else (
  copy %LOGFILE%+%TEMPLOGFILE% %LOGFILE% > NUL 2>&1
  if ERRORLEVEL 1 (
    echo Could not append %TEMPLOGFILE% to %LOGFILE% 
  ) else ( 
    echo %TEMPLOGFILE% was appended to %LOGFILE% 
  )
)

ENDLOCAL
