@echo off
@rem *************************************************************************
@rem This script can be used to start the WebLogic NodeManager
@rem
@rem To start the NodeManager on <host> and <port>, set the LISTEN_ADDRESS
@rem variable to <host> and LISTEN_PORT variable to <port> before calling this
@rem script.
@rem
@rem This script sets the following variables before starting the NodeManager:
@rem
@rem WL_HOME    - The root directory of your WebLogic installation.
@rem NODEMGR_HOME - The home directory for this NodeManager instance.
@rem JAVA_HOME    - Location of the version of Java used to start WebLogic
@rem                Server. This variable must point to the root directory of
@rem                a JDK installation and will be set for you by the
@rem		    installer.  See the Oracle Fusion Middleware Supported System Configurations page
@rem                (http://www.oracle.com/technology/software/products/ias/files/fusion_certification.html)
@rem                for an up-to-date list of supported JVMs.
@rem PATH         - Adds the JDK and WebLogic directories to the system path.
@rem CLASSPATH    - Adds the JDK and WebLogic jars to the classpath.
@rem JAVA_OPTIONS - Java command-line options for running the server. (These
@rem                will be tagged on to the end of the JAVA_VM and MEM_ARGS)
@rem JAVA_VM      - The java arg specifying the VM to run.  (i.e. -server,
@rem                -client, etc.)
@rem MEM_ARGS     - The variable to override the standard memory arguments
@rem                passed to java
@rem
@rem Alternately, this script will take the first two positional parameters and
@rem set them to LISTEN_ADDRESS and LISTEN_PORT. For instance, you could call
@rem this script: "startNodeManager.cmd holly 7777" to start the NodeManager
@rem on host holly and port 7777, or just "startNodeManager.cmd holly"
@rem to start the node manager on host holly.
@rem *************************************************************************

SETLOCAL

set JAVA_VM=
set MEM_ARGS=

FOR /f %%i in ('cd') do set MYPWD=%%i

SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

set WL_HOME=c:\Users\xiaol\Downloads\wls\wls12214\wlserver
set _startnm_params=%*

@rem  store all environment variables for reset later, if restarting
call :preserveOrigEnv

call "%WL_HOME%\..\oracle_common\common\bin\commEnv.cmd"

@rem Set user-defined variables
if "%NODEMGR_HOME%"=="" (
  set NODEMGR_HOME=%WL_HOME%\..\oracle_common\common\nodemanager
) else (
  echo NODEMGR_HOME is already set to %NODEMGR_HOME%
)

for %%i in ("%WL_HOME%") do set WL_HOME=%%~fsi
for %%i in ("%JAVA_HOME%") do set JAVA_HOME=%%~fsi
for %%i in ("%NODEMGR_HOME%") do set NODEMGR_HOME=%%~fsi

@rem Set first two positional parameters to LISTEN_ADDRESS and LISTEN_PORT
if not "%1" == "" set LISTEN_ADDRESS=%1
if not "%2" == "" set LISTEN_PORT=%2

@rem If NODEMGR_HOME does not exist, create it
:checkNodeManagerHome
if exist %NODEMGR_HOME% goto checkJava
echo.
echo NODEMGR_HOME %NODEMGR_HOME% does not exist, creating it..
mkdir %NODEMGR_HOME%

@rem Check that java is where we expect it to be
:checkJava
if exist %JAVA_HOME%\bin\java.exe goto runNodeManager
echo The JDK wasn't found in directory %JAVA_HOME%.
echo Please edit this script so that the JAVA_HOME
echo variable points to the location of your JDK.
goto finish

:runNodeManager

if not "%JAVA_VM%" == "" goto noResetJavaVM
if "%JAVA_VENDOR%"=="BEA" set JAVA_VM=-client
if "%JAVA_VENDOR%"=="Sun" set JAVA_VM=-client

:noResetJavaVM
if not "%MEM_ARGS%" == "" goto noResetMemArgs
set MEM_ARGS=-Xms32m -Xmx200m

:noResetMemArgs

if not "%BEA_HOME%" == "" set JAVA_OPTIONS=-Dbea.home=%BEA_HOME% %JAVA_OPTIONS%
if not "%COHERENCE_HOME%" == "" set JAVA_OPTIONS=-Dcoherence.home=%COHERENCE_HOME% %JAVA_OPTIONS%

set compare_string=%JAVA_OPTIONS%
if "%compare_string:-Dweblogic.RootDirectory=foo%" == "%compare_string%" set JAVA_OPTIONS=-Dweblogic.RootDirectory=%NODEMGR_HOME% %JAVA_OPTIONS%

if "%compare_string:-Djdk.tls.ephemeralDHKeySize=foo%" == "%compare_string%" set JAVA_OPTIONS=-Djdk.tls.ephemeralDHKeySize=2048 %JAVA_OPTIONS%

set CLASSPATH=.;%WEBLOGIC_CLASSPATH%;%CLASSPATH%;%WL_HOME%\modules\features\oracle.wls.common.grizzly.jar

@rem Get PRE and POST environment
if not "%PRE_CLASSPATH%" == "" set CLASSPATH=%PRE_CLASSPATH%;%CLASSPATH%
if not "%POST_CLASSPATH%" == "" set CLASSPATH=%CLASSPATH%;%POST_CLASSPATH%

echo CLASSPATH=%CLASSPATH%
set TMP_UPDATE_SCRIPT=%TMP%\update.cmd
cd /d %NODEMGR_HOME%

if not "%LISTEN_PORT%" == "" if not "%LISTEN_ADDRESS%" == "" goto runNMWithListenAddressAndPort
if not "%LISTEN_ADDRESS%" == "" goto runNMWithListenAddress
if not "%LISTEN_PORT%" == "" goto runNMWithListenPort

:runNMWithoutAnyArgs
@echo on
"%JAVA_HOME%\bin\java.exe" %JAVA_PROPERTIES% %JAVA_VM% %MEM_ARGS% %JAVA_OPTIONS% "-Djava.security.policy=%WL_HOME%\server\lib\weblogic.policy" "-Dweblogic.nodemanager.JavaHome=%JAVA_HOME%" weblogic.NodeManager -v
@echo off

goto checkForRestart

:runNMWithListenAddress
@echo on
"%JAVA_HOME%\bin\java.exe" %JAVA_PROPERTIES% %JAVA_VM% %MEM_ARGS% %JAVA_OPTIONS% "-Djava.security.policy=%WL_HOME%\server\lib\weblogic.policy" "-Dweblogic.nodemanager.JavaHome=%JAVA_HOME%" -DListenAddress="%LISTEN_ADDRESS%" weblogic.NodeManager -v
@echo off

goto checkForRestart

:runNMWithListenPort
@echo on
"%JAVA_HOME%\bin\java.exe" %JAVA_PROPERTIES% %JAVA_VM% %MEM_ARGS% %JAVA_OPTIONS% "-Djava.security.policy=%WL_HOME%\server\lib\weblogic.policy" "-Dweblogic.nodemanager.JavaHome=%JAVA_HOME%" -DListenPort="%LISTEN_PORT%" weblogic.NodeManager -v
@echo off

goto checkForRestart

:runNMWithListenAddressAndPort
@echo on
"%JAVA_HOME%\bin\java.exe" %JAVA_PROPERTIES% %JAVA_VM% %MEM_ARGS% %JAVA_OPTIONS% "-Djava.security.policy=%WL_HOME%\server\lib\weblogic.policy" "-Dweblogic.nodemanager.JavaHome=%JAVA_HOME%" -DListenAddress="%LISTEN_ADDRESS%" -DListenPort="%LISTEN_PORT%" weblogic.NodeManager -v
@echo off

goto checkForRestart



@rem  
@rem preserve_env
@rem saves all of the current environment variables in an "array"
@rem
:preserveOrigEnv
  set pre=
  for /F "delims= tokens=*" %%I in ('set') do call :addv "%%I"
goto finish

@rem
@rem Takes two arguments and evaluates them as if 
@rem the first argument is a string that represents an environment variable and
@rem the second argument is an environment variable.  So this method properly 
@rem expands the first string argument to get the underlying env variable value for
@rem comparison.  Return 1 when values are not the same
@rem 
:valueSame
SETLOCAL ENABLEDELAYEDEXPANSION
set a=%~1
set bothNameAndValue=%*

@rem compare the delayed expansion because quotes within the value mess up the expansion
if NOT ""%a%" "!%a%!"" == "!bothNameAndValue!" (
  @rem echo "values are NOT same - return error"
  exit /b 1
)
SETLOCAL DISABLEDELAYEDEXPANSION
goto finish


:addv
  @rem set the params to the entire set because quotations causes windows to expand the value and split it up
  set "_params=%*"
  @rem strip the wrapper quotes
  set _params=%_params:~1,-1%
  set /a preMax+=1

  @rem wrap the entire set in quotes to deal with bad env variables like foo=<
  @rem which can only be set this way when the value isn't already wrapped in quotes
  set "pre[%preMax%]=%_params%"
goto finish

:collect
  set collection=%collection%#%~1
goto finish

@rem
@rem  restoreOrigEnv
@rem  restores the environment to the exact same as it was when we
@rem  were initially called, resetting values as they were and
@rem  unsetting any values that were set during exec.  The one
@rem  exception is JAVA_HOME - we leave that alone because
@rem  the JAVA_HOME rollout may reset/update the value
@rem
:restoreOrigEnv
  for /F "delims=^= tokens=2,*" %%I in ('set pre^[') do (
    @rem echo "checking %%I"
    if NOT "%%I" == "JAVA_HOME" (
      if NOT "%%I" == "SUN_JAVA_HOME" (
        if NOT "%%I" == "DEFAULT_SUN_JAVA_HOME" (
          call :valueSame "%%I" "%%J" || (
            echo set "%%I=%%J">>tmpResetEnv.cmd
            @rem echo "reset %%I to %%J"
          )
        )
      )
    )
  )

  if EXIST tmpResetEnv.cmd (
    call tmpResetEnv.cmd
    del tmpResetEnv.cmd
  )

  @rem unset any variables that are not in pre
  for /F "delims=^= tokens=2" %%I in ('set pre^[') do (
   call :collect "%%I"
  )

  @rem update/close collection value so all variable names are wrapped by delimiter
  set collection=%collection%#

  @rem unset all of our pre variables
  for /F "delims=^= tokens=1" %%I in ('set pre^[') do (
    set %%I=
  )
  for /F "delims=^= tokens=1,*" %%I in ( 'set' ) do (
    @rem skip collection when unsetting values, we will reset it at the end
    if NOT "%%I" == "collection" (
      echo "%collection%" |findstr /L /I #%%I# > nul || (
        @REM echo "Need to unset %%I"
        set %%I=
      )
    )
  )

  set collection=

goto finish



:checkForRestart
@echo off

if ERRORLEVEL 86 if not ERRORLEVEL 87 set errorlvl="86"
if ERRORLEVEL 88 if not ERRORLEVEL 89 set errorlvl="88"

@rem if errorlevel == 86
if %errorlvl% == "86" (
  call :doUpdateAndRestart
) else if %errorlvl% == "88" (
  call :doRestart
)
goto finish

:doUpdateAndRestart
  SETLOCAL EnableDelayedExpansion
  set updatedLockExists="false"
:checkUpdateLock
  if EXIST "%TMP_UPDATE_SCRIPT%.lck" (
    if !updatedLockExists! == "false" (
      echo Waiting for file '%TMP_UPDATE_SCRIPT%.lck' to be removed
      for /F "eol=# delims== tokens=1,*" %%a in (%TMP_UPDATE_SCRIPT%.lck) do (
        if NOT "%%a"=="" if NOT "%%b"=="" set %%a=%%b
      )
      set updatedLockExists="true"
    )
    timeout 1 /NOBREAK 1>nul
    goto checkUpdateLock
  )

  if !updatedLockExists! == "false" (
    if EXIST "%TMP_UPDATE_SCRIPT%"  (
      cd /d %TMP%
      call "%TMP_UPDATE_SCRIPT%"
      @rem if errorlevel == 42
      if ERRORLEVEL 42 if not ERRORLEVEL 43 (
        set JAVA_HOME=
        set SUN_JAVA_HOME=
        set DEFAULT_SUN_JAVA_HOME=
      )
    ) else (
      echo "ERROR! %TMP_UPDATE_SCRIPT% did not exist"
    )
  ) else (
    if /I "!ResetJava!" == "true" (
      set JAVA_HOME=
      set SUN_JAVA_HOME=
      set DEFAULT_SUN_JAVA_HOME=
    )
  )
  SETLOCAL DisableDelayedExpansion

  @rem reset the environment variables to the exact same as original call
  @rem to make sure values do not continue to grow
  call :restoreOrigEnv
  ::  call the same script path that was supplied in order to support
  ::  symbolic links
  call "%SCRIPT_PATH%\startNodeManager.cmd" %_startnm_params%
  goto finish

:doRestart
  @rem if errorlevel == 88
  call :restoreOrigEnv
  call "%SCRIPT_PATH%\startNodeManager.cmd" %_startnm_params%
  goto finish

:finish


ENDLOCAL
