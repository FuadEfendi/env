@rem *************************************************************************
@rem This script is used to initialize common environment to start WebLogic
@rem Server, as well as WebLogic development.
@rem
@rem It sets the following variables:
@rem
@rem WEBLOGIC_CLASSPATH
@rem            - Classpath required to start WebLogic server.
@rem FMWCONFIG_CLASSPATH
@rem            - Classpath required to start config tools such as config wizard, pack, and unpack..
@rem FMWLAUNCH_CLASSPATH
@rem            - Additional classpath needed for WLST start script
@rem DERBY_CLASSPATH
@rem            - Classpath needed to start Derby.
@rem DERBY_TOOLS
@rem            - Derby tools jar file.
@rem PATCH_CLASSPATH
@rem            - WebLogic Patch system classpath
@rem *************************************************************************

IF NOT DEFINED MW_HOME (
  echo Please set MW_HOME  
  IF DEFINED USE_CMD_EXIT (
   EXIT 1
  ) ELSE (
   EXIT /B 1
  )
)

IF NOT DEFINED WL_HOME (
  echo Please set WL_HOME 
  IF DEFINED USE_CMD_EXIT (
   EXIT 1
  ) ELSE (
   EXIT /B 1
  )
)


@rem setup profile specific server classpath

set PROFILE_CLASSPATH=%WL_HOME%\server\lib\weblogic.jar
if /I "%SERVER_PROFILE%" == "WEB" (
  set PROFILE_CLASSPATH=%WL_HOME%\server\lib\weblogic-webprofile.jar
)

@rem set up WebLogic Server's class path and config tools classpath
@rem The versioned jar needs to be removed once the unversioned is available
set CAM_NODEMANAGER_JAR_PATH=%WL_HOME%\modules\features\oracle.wls.common.nodemanager.jar

set WEBLOGIC_CLASSPATH=%JAVA_HOME%\lib\tools.jar;%PROFILE_CLASSPATH%;%ANT_CONTRIB%\ant-contrib-1.0b3.jar;%CAM_NODEMANAGER_JAR_PATH%

set CONFIG_LAUNCH_JAR=%MW_HOME%\oracle_common\modules\features\cieCfg_wls_lib.jar

if exist %MW_HOME%\oracle_common\modules\features\cieCfg_cam_lib.jar set CONFIG_LAUNCH_JAR=%MW_HOME%\oracle_common\modules\features\cieCfg_cam_lib.jar
 
@rem set up launch classpath for use by WLST   
set FMWLAUNCH_CLASSPATH=%CONFIG_LAUNCH_JAR%

if DEFINED DB_DRIVER_CLASSPATH (
  set FMWCONFIG_CLASSPATH=%FMWCONFIG_CLASSPATH%;%DB_DRIVER_CLASSPATH%
  set FMWLAUNCH_CLASSPATH=%FMWLAUNCH_CLASSPATH%;%DB_DRIVER_CLASSPATH%  
)


if NOT "%PATCH_CLASSPATH%"=="" (
  set WEBLOGIC_CLASSPATH=%PATCH_CLASSPATH%;%WEBLOGIC_CLASSPATH%
  set FMWCONFIG_CLASSPATH=%PATCH_CLASSPATH%;%FMWCONFIG_CLASSPATH%
)

if /I "%SIP_ENABLED%"=="true" goto set_sip_classpath
goto no_sip

:set_sip_classpath
@rem set up SIP classpath
set SIP_CLASSPATH=%WLSS_HOME%\server\lib\weblogic_sip.jar
@rem add to WLS classpath
set WEBLOGIC_CLASSPATH=%WEBLOGIC_CLASSPATH%;%SIP_CLASSPATH%
set FMWCONFIG_CLASSPATH=%FMWCONFIG_CLASSPATH%;%SIP_CLASSPATH%
:no_sip

@rem set up DERBY configuration
set DERBY_HOME=%WL_HOME%\common\derby
set DERBY_CLIENT_CLASSPATH=%DERBY_HOME%\lib\derbyclient.jar;%DERBY_HOME%\lib\derby.jar
set DERBY_CLASSPATH=%DERBY_HOME%\lib\derbynet.jar;%DERBY_CLIENT_CLASSPATH%
set DERBY_TOOLS=%DERBY_HOME%\lib\derbytools.jar

IF NOT "%DERBY_PRE_CLASSPATH%"=="" (
  set DERBY_CLASSPATH=%DERBY_PRE_CLASSPATH%;%DERBY_CLASSPATH%
)
IF NOT "%DERBY_POST_CLASSPATH%"=="" (
  set DERBY_CLASSPATH=%DERBY_CLASSPATH%;%DERBY_POST_CLASSPATH%
)

:end
