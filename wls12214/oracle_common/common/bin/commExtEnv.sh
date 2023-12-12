#!/bin/sh

#*****************************************************************************
# This script is used to set up a common environment for starting WebLogic
# Server, as well as WebLogic development.
#
# It sets the following variables:
# MW_HOME        - The home directory of all your Oracle installation.
# WL_HOME        - The root directory of the BEA installation.
# WEBLOGIC_CLASSPATH - Classpath required to start WebLogic Server.
# FMWCONFIG_CLASSPATH - Classpath required to start config tools such as WLST, config wizard, pack, and unpack..
# FMWLAUNCH_CLASSPATH - Additional classpath needed for WLST start script
# CLASSPATHSEP   - CLASSPATH delimiter.
# DERBY_TOOLS - Derby tools jar.
# DERBY_CLASSPATH - Classpath needed to start Derby.
# DERBY_CLIENT_CLASSPATH
#                     - Derby client classpath.
# PATCH_CLASSPATH     - WebLogic system classpath patch
# It exports the following function:
# resetFd        - Reset the number of open file descriptors to 1024.
#
#*****************************************************************************

if [ -z "${MW_HOME}" -o -z "${WL_HOME}" ]; then
 echo "Please set both MW_HOME and WL_HOME."
 exit 1
fi


# Set the classpath separator
case `uname -s` in
Windows_NT*)
  CLASSPATHSEP=\;
;;
CYGWIN*)
  CLASSPATHSEP=\;
;;
esac

if [ "${CLASSPATHSEP}" = "" ]; then
  CLASSPATHSEP=:
fi
export CLASSPATHSEP


# set up profile specific classpath
PROFILE_CLASSPATH="${WL_HOME}/server/lib/weblogic.jar"
SERVER_PROFILE=`echo ${SERVER_PROFILE} | awk '{print toupper($0)}'`
if [ "${SERVER_PROFILE}" = "WEB" ]; then
  PROFILE_CLASSPATH="${WL_HOME}/server/lib/weblogic-webprofile.jar"
fi
export PROFILE_CLASSPATH
 
# set up WebLogic Server's class path 
# The versioned jar needs to be removed once the unversioned is available
CAM_NODEMANAGER_JAR_PATH="${WL_HOME}/modules/features/oracle.wls.common.nodemanager.jar"


export CAM_NODEMANAGER_JAR_PATH
WEBLOGIC_CLASSPATH="${JAVA_HOME}/lib/tools.jar${CLASSPATHSEP}${PROFILE_CLASSPATH}${CLASSPATHSEP}${ANT_CONTRIB}/ant-contrib-1.0b3.jar${CLASSPATHSEP}${CAM_NODEMANAGER_JAR_PATH}"

case `uname -s` in
AIX)
WEBLOGIC_CLASSPATH="${WEBLOGIC_CLASSPATH}${CLASSPATHSEP}${MW_HOME}/oracle_common/modules/glassfish.jaxp.jar"
;;
*)
;;
esac

export WEBLOGIC_CLASSPATH

CONFIG_LAUNCH_JAR_PATH="${MW_HOME}/oracle_common/modules/features/cieCfg_wls_lib.jar"

if [ -f "${MW_HOME}/oracle_common/modules/features/cieCfg_cam_lib.jar" ] ; then
  CONFIG_LAUNCH_JAR_PATH="${MW_HOME}/oracle_common/modules/features/cieCfg_cam_lib.jar"
fi

# set up config tools class path
FMWLAUNCH_CLASSPATH="${CONFIG_LAUNCH_JAR_PATH}"

if [ ! -z "${DB_DRIVER_CLASSPATH}" ]; then
  FMWLAUNCH_CLASSPATH="${FMWLAUNCH_CLASSPATH}${CLASSPATHSEP}${DB_DRIVER_CLASSPATH}"
  FMWCONFIG_CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${DB_DRIVER_CLASSPATH}" 
  export FMWCONFIG_CLASSPATH
fi
export FMWLAUNCH_CLASSPATH

if [ "${PATCH_CLASSPATH}" != "" ] ; then
    WEBLOGIC_CLASSPATH="${PATCH_CLASSPATH}${CLASSPATHSEP}${WEBLOGIC_CLASSPATH}"
    export WEBLOGIC_CLASSPATH
    FMWCONFIG_CLASSPATH="${PATCH_CLASSPATH}${CLASSPATHSEP}${FMWCONFIG_CLASSPATH}"
    export FMWCONFIG_CLASSPATH
fi

if [ "$SIP_ENABLED" = "true" ]; then
  # set up SIP classpath
  SIP_CLASSPATH="${WLSS_HOME}/server/lib/weblogic_sip.jar"
  # add to WLS class path
  WEBLOGIC_CLASSPATH="${WEBLOGIC_CLASSPATH}${CLASSPATHSEP}${SIP_CLASSPATH}"
  export WEBLOGIC_CLASSPATH
  FMWCONFIG_CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${SIP_CLASSPATH}"
  export FMWCONFIG_CLASSPATH
fi

# DERBY configuration
DERBY_HOME="${WL_HOME}/common/derby"
DERBY_CLIENT_CLASSPATH="${DERBY_HOME}/lib/derbyclient.jar${CLASSPATHSEP}${DERBY_HOME}/lib/derby.jar"
DERBY_CLASSPATH="${CLASSPATHSEP}${DERBY_HOME}/lib/derbynet.jar${CLASSPATHSEP}${DERBY_CLIENT_CLASSPATH}"
DERBY_TOOLS="${DERBY_HOME}/lib/derbytools.jar"

if [ "${DERBY_PRE_CLASSPATH}" != "" ] ; then
  DERBY_CLASSPATH="${DERBY_PRE_CLASSPATH}${CLASSPATHSEP}${DERBY_CLASSPATH}"
fi
 
if [ "${DERBY_POST_CLASSPATH}" != "" ] ; then
  DERBY_CLASSPATH="${DERBY_CLASSPATH}${CLASSPATHSEP}${DERBY_POST_CLASSPATH}"
fi

export DERBY_HOME DERBY_CLASSPATH DERBY_TOOLS 

