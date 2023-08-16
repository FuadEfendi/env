#!/bin/sh

#*****************************************************************************
# This script is used to set up a common environment for starting WebLogic
# Server, as well as WebLogic development.
#
# It sets the following variables:
# BEA_HOME       - The home directory of all your BEA installation.
# MW_HOME        - The home directory of all your Oracle installation.
# WL_HOME        - The root directory of the BEA installation.
# COHERENCE_HOME - The root directory of the COHERENCE installation.
# ANT_HOME       - The Ant Home directory.
# ANT_CONTRIB    - The Ant contrib directory
# JAVA_HOME      - Location of the version of Java used to start WebLogic
#                  Server. See the Oracle Fusion Middleware Supported System Configurations page
#                  (http://www.oracle.com/technology/software/products/ias/files/fusion_certification.html) for an
#                  up-to-date list of supported JVMs on your platform.
# JAVA_VENDOR    - Vendor of the JVM (i.e. Oracle, HP, IBM, Sun, etc.)
# JAVA_USE_64BIT - Indicates if JVM uses 64 bit operations
# PATH           - JDK and WebLogic directories will be added to the system
#                  path.
# LD_LIBRARY_PATH, LIBPATH and SHLIB_PATH
#                - To locate native libraries.
# JAVA_VM        - The java arg specifying the VM to run.  (e.g.
#                  -server, -hotspot, etc.)
# MEM_ARGS       - The variable to override the standard memory arguments
#                  passed to java.
# UTILS_MEM_ARGS       - The variable to override the standard memory arguments
#                  passed to java for configuration utilities.
# PATHSEP        - Path delimiter.
# DERBY_HOME - Derby home directory.
# DERBY_TOOLS - Derby tools jar.
# PRODUCTION_MODE     - Indicates if the Server will be started in PRODUCTION_MODE
# PATCH_LIBPATH  - Library path used for patches
# PATCH_PATH     - Path used for patches
# WEBLOGIC_EXTENSION_DIRS - Extension dirs for WebLogic classpath patch
#
# It exports the following function:
# trapSIGINT     - Get actual Derby PID when running in MKSNT environment;
#                  trap SIGINT to make sure Derby will also be stopped.
#
# resetFd        - Reset the number of open file descriptors to 1024.
#
# jDriver for Oracle users: This script assumes that native libraries required
# for jDriver for Oracle have been installed in the proper location and that
# your os specific library path variable (i.e. LD_LIBRARY_PATH/solaris,
# SHLIB_PATH/hpux, etc...) has been set appropriately.  Also note that this
# script defaults to the oci920_8 version of the shared libraries. If this is
# not the version you need, please adjust the library path variable
# accordingly.
#
#*****************************************************************************

#*****************************************************************************
# sub functions
#*****************************************************************************

# limit the number of open file descriptors
resetFd() {
  if [ ! -n "`uname -s |grep -i cygwin || uname -s |grep -i windows_nt || \
       uname -s |grep -i HP-UX`" ]
  then
    ofiles=`ulimit -S -n`
    maxfiles=`ulimit -H -n`
    if [ "$?" = "0" -a  `expr ${maxfiles} : '[0-9][0-9]*$'` -eq 0 -a `expr ${ofiles} : '[0-9][0-9]*$'` -eq 0 ]; then   
      ulimit -n 4096
    else
      if [ "$?" = "0" -a `uname -s` = "SunOS" -a `expr ${maxfiles} : '[0-9][0-9]*$'` -eq 0 ]; then
        if [ ${ofiles} -lt 65536 ]; then
          ulimit -H -n 65536
        else
          ulimit -H -n ${ofiles}
        fi
      fi
    fi
  fi
}

# Get actual Derby process when running in MKS/NT environment;
# Trap SIGINT
# input:
# DERBY_PID -- Derby server process id.
# output:
# DERBY_PID -- Actual Derby pid in MKS/NT environment.
trapSIGINT() {

  # With MKS, the pid of $! dosen't show up correctly.
  # It starts a shell process to launch whatever commands it calls.
  if [ `uname -s` = "Windows_NT" ]; then
    DERBY_PID=`ps -eo pid,ppid |
      awk -v DERBY_PID=${DERBY_PID} '$2 == DERBY_PID {print $1}'`
  fi

  # Kill Derby on interrupt from this script (^C)
  trap 'if [ "${DERBY_PID}" != "" ]; then
        kill -9 ${DERBY_PID}
        unset DERBY_PID
        fi' 2
}

#*****************************************************************************
# end of sub functions
#*****************************************************************************

if [ -z "${MW_HOME}" -o -z "${WL_HOME}" ]; then
 echo "Please set both MW_HOME and WL_HOME."
 exit 1
fi

# Set up BEA Home
BEA_HOME="${MW_HOME}"

# Set up COHERENCE Home
COHERENCE_HOME="${MW_HOME}/coherence"

# Set up Common Modules Directory
MODULES_DIR="${MW_HOME}/oracle_common/modules"

# Set up Common Features Directory
FEATURES_DIR="${MW_HOME}/oracle_common/modules/features"

if [ -d "${MW_HOME}/oracle_common/modules/thirdparty/org.apache.ant/1.10.5.0.0/apache-ant-1.10.5" ]; then
  ANT_HOME="${MW_HOME}/oracle_common/modules/thirdparty/org.apache.ant/1.10.5.0.0/apache-ant-1.10.5"
fi

# Set up Ant contrib
ANT_CONTRIB="${MW_HOME}/oracle_common/modules/thirdparty"

#JAVA_USE_64BIT, true if JVM uses 64 bit operations
if [ ${JAVA_USE_64BIT:=@JAVA_USE_64BIT@} != true ]; then
  JAVA_USE_64BIT=false
fi

ENV_JAVA_HOME="${JAVA_HOME}"
# Reset JAVA_HOME, JAVA_VENDOR and PRODUCTION_MODE unless JAVA_HOME
# and JAVA_VENDOR are pre-defined.
if [ -z "${JAVA_HOME}" -o -z "${JAVA_VENDOR}" ]; then
  # Set up JAVA HOME
  JAVA_HOME=`${MW_HOME}/oui/bin/getProperty.sh JAVA_HOME`
  # There are tests which are run without string substitution but only setting JAVA_HOME in the env.
  #This check is for that
  if [ ! -d "${JAVA_HOME}" ]; then
    JAVA_HOME="${ENV_JAVA_HOME}"
  fi 
  # Set up JAVA VENDOR, possible values are
  #Oracle, HP, IBM, Sun ...
  JAVA_VENDOR=@JAVA_VENDOR@
  # PRODUCTION_MODE, default to the development mode
  PRODUCTION_MODE=""
fi
JRE_HOME="${JAVA_HOME}"
if [ -d "${JAVA_HOME}"/jre ]; then
  JRE_HOME="${JAVA_HOME}/jre"
fi 
export JRE_HOME
if [ -z "${VM_TYPE}" ]; then
  case $JAVA_VENDOR in
   Oracle)
    if [ -d "${JRE_HOME}/bin/jrockit" ]; then
      VM_TYPE=JRockit
    else
      for jrpath in "${JRE_HOME}"/lib/*
      do
       if [ -d "${jrpath}/jrockit" ]; then
        VM_TYPE=JRockit
       fi
      done
    fi
   ;;
   Sun)
    VM_TYPE=HotSpot
   ;;
   HP)
    VM_TYPE=HotSpot
   ;;
   *)
   ;;
  esac
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

FMWCONFIG_CLASSPATH="${JAVA_HOME}/lib/tools.jar"

if [ -f ${MW_HOME}/oracle_common/modules/features/wlst.cam.classpath.jar ]; then
 # This is for CAM Standalone, ODI Standalone (Hybrid)
 FMWCONFIG_CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${MW_HOME}/oracle_common/modules/features/wlst.cam.classpath.jar"
else
 if [ -f ${MW_HOME}/oracle_common/modules/features/cieCfg_cam_lib.jar ]; then
  # This is for Enterprise CAM
  FMWCONFIG_CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${MW_HOME}/oracle_common/modules/features/cieCfg_cam_lib.jar"
 else
  # This is for Federated Enterprise CAM
  MW_HOME_PARENT=`cd $MW_HOME/..;pwd`
  CAM_LIB_FOUND="false"
  for OH in "${MW_HOME_PARENT}"/* ; do
    ocModulesDir="${OH}"/oracle_common/modules
    if [ -f "${ocModulesDir}"/features/cieCfg_cam_lib.jar -a -f "${OH}"/inventory/federated  ] ; then
      config_wls_path="${MW_HOME}"/oracle_common/modules/com.oracle.cie.config-wls_
      for config_wls_module in ${config_wls_path}* ; do
        saveIFS=$IFS
        IFS="_"
        for arg in ${config_wls_module}; do
         version_with_jar_ext=$arg		
        done   
        IFS=$saveIFS
        if [ -f "${ocModulesDir}"/com.oracle.cie.config-cam_${version_with_jar_ext} ] ; then
          FMWCONFIG_CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${ocModulesDir}/features/cieCfg_cam_lib.jar"
          CAM_LIB_FOUND="true"
          break
        fi
      done
    fi
    if [ "${CAM_LIB_FOUND}" = "true" ] ; then
      break
    fi
  done
 fi
fi
if [ -f ${WL_HOME}/modules/features/wlst.wls.classpath.jar ]; then
  # This is for Full WLS, ODI Standalone (Hybrid), Enterprise CAM
  FMWCONFIG_CLASSPATH="${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${WL_HOME}/modules/features/wlst.wls.classpath.jar"
fi

SECURITY_JVM_ARGS="-Dweblogic.alternateTypesDirectory='${MW_HOME}'/oracle_common/modules/oracle.oamprovider,'${MW_HOME}'/oracle_common/modules/oracle.jps"

export FMWCONFIG_CLASSPATH BEA_HOME MW_HOME WL_HOME MODULES_DIR FEATURES_DIR COHERENCE_HOME ANT_HOME ANT_CONTRIB JAVA_HOME JAVA_VENDOR PRODUCTION_MODE JAVA_USE_64BIT VM_TYPE SECURITY_JVM_ARGS

# Set the path separator
case `uname -s` in
Windows_NT*)
  PATHSEP=\;
;;
CYGWIN*)
;;
esac

if [ "${PATHSEP}" = "" ]; then
  PATHSEP=:
fi
export PATHSEP

# Set up JVM options base on value of JAVA_VENDOR
if [ "$PRODUCTION_MODE" = "true" ]; then
  case $JAVA_VENDOR in
  Oracle)
    if [ "${VM_TYPE}" = "JRockit" ]; then
     JAVA_VM=-jrockit
     MEM_ARGS="-Xms128m -Xmx256m"
     UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
    else
     JAVA_VM=-server
     MEM_ARGS="-Xms32m -Xmx200m"    
     UTILS_MEM_ARGS="-Xms32m -Xmx1024m"    
    fi
  ;;
  HP)
    JAVA_VM=-server
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  IBM)
    JAVA_VM=
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  Sun)
    JAVA_VM=-server
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  Apple)
    JAVA_VM=-server
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  *)
    JAVA_VM=
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  esac
else
  case $JAVA_VENDOR in
  Oracle)
    if [ "${VM_TYPE}" = "JRockit" ]; then
     JAVA_VM=-jrockit
     MEM_ARGS="-Xms128m -Xmx256m"
     UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
    else
     JAVA_VM=-server
     MEM_ARGS="-Xms32m -Xmx200m"    
     UTILS_MEM_ARGS="-Xms32m -Xmx1024m"    
    fi
  ;;
  HP)
    JAVA_VM=-server
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  IBM)
    JAVA_VM=
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  Sun)
    JAVA_VM=-server
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  Apple)
    JAVA_VM=-server
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  *)
    JAVA_VM=
    MEM_ARGS="-Xms32m -Xmx200m"
    UTILS_MEM_ARGS="-Xms32m -Xmx1024m"
  ;;
  esac
fi

if [ "${USE_JVM_SYSTEM_LOADER}" != "true" ] ; then
  CIE_JAVA_OPTIONS="-Djava.system.class.loader=com.oracle.classloader.weblogic.LaunchClassLoader"
fi 

if [ "${USER_MEM_ARGS}" != "" ] ; then
  MEM_ARGS="${USER_MEM_ARGS}"
  UTILS_MEM_ARGS="${USER_MEM_ARGS}"
fi

case `uname -s` in
AIX)
  CIE_JAVA_OPTIONS="${CIE_JAVA_OPTIONS}  -Djavax.xml.validation.SchemaFactory:http://www.w3.org/2001/XMLSchema=org.apache.xerces.jaxp.validation.XMLSchemaFactory"
  CIE_JAVA_OPTIONS="${CIE_JAVA_OPTIONS}  -Dcom.sun.xml.namespace.QName.useCompatibleSerialVersionUID=1.0"
  CONFIG_JVM_ARGS=" -Djavax.xml.transform.TransformerFactory=org.apache.xalan.processor.TransformerFactoryImpl ${CONFIG_JVM_ARGS} "
;;
esac

case "${JAVA_OPTIONS}" in
  *${CIE_JAVA_OPTIONS}*) ;;
                      *) JAVA_OPTIONS="$JAVA_OPTIONS $CIE_JAVA_OPTIONS" ;;
esac
  
export JAVA_VM MEM_ARGS UTILS_MEM_ARGS JAVA_OPTIONS CONFIG_JVM_ARGS


# Figure out how to load java native libraries, also add -d64 for hpux and solaris 64 bit arch.
case `uname -s` in
AIX)
  if [ "${JAVA_USE_64BIT}" = "true" ]; then
    CIE_LIBPATH=${WL_HOME}/server/native/aix/ppc64
  else
    CIE_LIBPATH=${WL_HOME}/server/native/aix/ppc
  fi
  
  case "${LIBPATH}" in
   *${CIE_LIBPATH}*) ;;
                  *) LIBPATH=${LIBPATH}:${CIE_LIBPATH};;
  esac

  LIBPATH=${PATCH_LIBPATH}:${LIBPATH}
  export LIBPATH
;;
HP-UX)
  arch=`uname -m`
  if [ "${arch}" = "ia64" ]; then
    if [ "${JAVA_USE_64BIT}" = "true" ]; then
      CIE_SHLIB_PATH=${WL_HOME}/server/native/hpux11/IPF64:${WL_HOME}/server/native/hpux11/IPF64/oci920_8
    else
      CIE_SHLIB_PATH=${WL_HOME}/server/native/hpux11/IPF32:${WL_HOME}/server/native/hpux11/IPF32/oci920_8
    fi
  else
    if [ "${JAVA_USE_64BIT}" = "true" ]; then
      CIE_SHLIB_PATH=${WL_HOME}/server/native/hpux11/PA_RISC64:${WL_HOME}/server/native/hpux11/PA_RISC64/oci920_8
    else
      CIE_SHLIB_PATH=${WL_HOME}/server/native/hpux11/PA_RISC:${WL_HOME}/server/native/hpux11/PA_RISC/oci920_8
    fi
  fi
  case "${SHLIB_PATH}" in
   *${CIE_SHLIB_PATH}*) ;;
                     *) SHLIB_PATH=${SHLIB_PATH}:${CIE_SHLIB_PATH};;
  esac

  SHLIB_PATH=${PATCH_LIBPATH}:${SHLIB_PATH}
  export SHLIB_PATH
  if [ "${JAVA_USE_64BIT}" = "true" ] && [ "${VM_TYPE}" != "JRockit" ]
  then
     JVM_D64="-d64"
     export JVM_D64
     JAVA_VM="${JAVA_VM} ${JVM_D64}"
     export JAVA_VM
  fi
;;
LINUX|Linux)
  arch=`uname -m`
  if [ "${arch}" = "ia64" ]; then
    CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/linux/ia64:${WL_HOME}/server/native/linux/ia64/oci920_8
  else
    if [ "${arch}" = "x86_64" -a "${JAVA_USE_64BIT}" = "true" ]; then
      CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/linux/${arch}:${WL_HOME}/server/native/linux/${arch}/oci920_8
      if [ "$SIP_ENABLED" = "true" ]; then
        CIE_LD_LIBRARY_PATH=${CIE_LD_LIBRARY_PATH}:${WLSS_HOME}/server/native/linux/${arch}:${WLSS_HOME}/server/native/linux/${arch}/oci920_8
      fi
    else
      if [ "${arch}" = "s390x" ]; then
        CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/linux/s390x
      else
        CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/linux/i686:${WL_HOME}/server/native/linux/i686/oci920_8
      fi
      if [ "$SIP_ENABLED" = "true" ]; then
        CIE_LD_LIBRARY_PATH=${CIE_LD_LIBRARY_PATH}:${WLSS_HOME}/server/native/linux/i686:${WLSS_HOME}/server/native/linux/i686/oci920_8
      fi
    fi
  fi

  case "${LD_LIBRARY_PATH}" in 
   *${CIE_LD_LIBRARY_PATH}*) ;;
                          *) LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CIE_LD_LIBRARY_PATH};; 
  esac   
  
  LD_LIBRARY_PATH=${PATCH_LIBPATH}:${LD_LIBRARY_PATH}
  export LD_LIBRARY_PATH
;;
OSF1)
  CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/tru64unix

  case "${LD_LIBRARY_PATH}" in 
   *${CIE_LD_LIBRARY_PATH}*) ;;
                          *) LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CIE_LD_LIBRARY_PATH};;
  esac
  
  LD_LIBRARY_PATH=${PATCH_LIBPATH}:${LD_LIBRARY_PATH}
  export LD_LIBRARY_PATH
;;
SunOS)
  arch=`uname -m`
  if [ "${arch}" = "i86pc" ]; then
    if [ "${JAVA_USE_64BIT}" = "true" ]; then
      CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/solaris/x64
    else
      CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/solaris/x86
    fi
  else
    if [ "${JAVA_USE_64BIT}" = "true" ]; then
      CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/solaris/sparc64:${WL_HOME}/server/native/solaris/sparc64/oci920_8
      if [ "$SIP_ENABLED" = "true" ]; then
        CIE_LD_LIBRARY_PATH=${CIE_LD_LIBRARY_PATH}:${WLSS_HOME}/server/native/solaris/sparc64:${WLSS_HOME}/server/native/solaris/sparc64/oci920_8
      fi
    else
      CIE_LD_LIBRARY_PATH=${WL_HOME}/server/native/solaris/sparc:${WL_HOME}/server/native/solaris/sparc/oci920_8
      if [ "$SIP_ENABLED" = "true" ]; then
        CIE_LD_LIBRARY_PATH=${CIE_LD_LIBRARY_PATH}:${WLSS_HOME}/server/native/solaris/sparc:${WLSS_HOME}/server/native/solaris/sparc/oci920_8
      fi
    fi
  fi

  case "${LD_LIBRARY_PATH}" in 
   *${CIE_LD_LIBRARY_PATH}*) ;;
                          *) LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CIE_LD_LIBRARY_PATH};;
  esac

  LD_LIBRARY_PATH=${PATCH_LIBPATH}:${LD_LIBRARY_PATH}
  export LD_LIBRARY_PATH
  if [ "${JAVA_USE_64BIT}" = "true" ] && [ "${VM_TYPE}" != "JRockit" ]
  then
    JVM_D64="-d64"
    export JVM_D64
    JAVA_VM="${JAVA_VM} ${JVM_D64}"
    export JAVA_VM
  fi
;;
Darwin)
  if [ -n "${DYLD_LIBRARY_PATH}" ]; then
    DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${WL_HOME}/server/native/macosx
  else
    DYLD_LIBRARY_PATH=${WL_HOME}/server/native/macosx
  fi
  DYLD_LIBRARY_PATH=${PATCH_LIBPATH}:${DYLD_LIBRARY_PATH}
  export DYLD_LIBRARY_PATH
;;
Windows_NT*) ;;
CYGWIN*) ;;
*)
  echo "$0: Don't know how to set the shared library path for `uname -s`.  "
esac

# setup bootstrap options
SYSTEM_LOADER=SystemClassLoader
LAUNCH_COMPLETE=weblogic.store.internal.LockManagerImpl
PCL_JAR=${WL_HOME}/server/lib/pcl2.jar


# DERBY configuration
DERBY_HOME="${WL_HOME}/common/derby"
DERBY_SYSTEM_HOME=${DOMAIN_HOME}/common/db
DERBY_OPTS="-Dderby.system.home=$DERBY_SYSTEM_HOME"

export DERBY_HOME DERBY_SYSTEM_HOME DERBY_OPTS 

# Set up PATH
if [ `uname -s` = "CYGWIN32/NT" ]; then
# If we are on an old version of Cygnus we need to turn <letter>:/ in the path
# to //<letter>/
  WL_HOME_CYGWIN=`echo $WL_HOME | sed 's#\([a-zA-Z]\):#//\1#g'`
  ANT_HOME_CYGWIN=`echo $ANT_HOME | sed 's#\([a-zA-Z]\):#//\1#g'`
  ANT_CONTRIB_CYGWIN=`echo $ANT_CONTRIB | sed 's#\([a-zA-Z]\):#//\1#g'`
  JAVA_HOME_CYGWIN=`echo $JAVA_HOME | sed 's#\([a-zA-Z]\):#//\1#g'`
  JRE_HOME_CYGWIN=`echo $JRE_HOME | sed 's#\([a-zA-Z]\):#//\1#g'`
  PATCH_PATH_CYGWIN=`echo $PATCH_PATH | sed 's#\([a-zA-Z]\):#//\1#g'`
  if [ -d "${JRE_HOME}/lib/ia64" ]; then
   CIE_PATH="${PATCH_PATH_CYGWIN}${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/64${PATHSEP}${WL_HOME_CYGWIN}/server/bin${PATHSEP}${ANT_HOME_CYGWIN}/bin${PATHSEP}${JRE_HOME_CYGWIN}/bin${PATHSEP}${JAVA_HOME_CYGWIN}/bin${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/64/oci920_8"
  else
   if [ -d "${JRE_HOME}/lib/i386" ]; then
     CIE_PATH="${PATCH_PATH_CYGWIN}${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/32${PATHSEP}${WL_HOME_CYGWIN}/server/bin${PATHSEP}${ANT_HOME_CYGWIN}/bin${PATHSEP}${JRE_HOME_CYGWIN}/bin${PATHSEP}${JAVA_HOME_CYGWIN}/bin${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/32/oci920_8"
   else
    if [ -d "${JRE_HOME}/lib/amd64" ]; then
     CIE_PATH="${PATCH_PATH_CYGWIN}${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/x64${PATHSEP}${WL_HOME_CYGWIN}/server/bin${PATHSEP}${ANT_HOME_CYGWIN}/bin${PATHSEP}${JRE_HOME_CYGWIN}/bin${PATHSEP}${JAVA_HOME_CYGWIN}/bin${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/x64/oci920_8"
    fi
   fi
  fi 
else
  if [ -n "`uname -s |grep -i cygwin_`" ]; then
  # If we are on an new version of Cygnus we need to turn <letter>:/ in
  # the path to /cygdrive/<letter>/
    CYGDRIVE=`mount -ps | tail -1 | awk '{print $1}' | sed -e 's%/$%%'`
    WL_HOME_CYGWIN=`echo $WL_HOME | sed "s#\([a-zA-Z]\):#${CYGDRIVE}/\1#g"`
    ANT_HOME_CYGWIN=`echo $ANT_HOME | sed "s#\([a-zA-Z]\):#${CYGDRIVE}/\1#g"`
    PATCH_PATH_CYGWIN=`echo $PATCH_PATH | sed "s#\([a-zA-Z]\):#${CYGDRIVE}/\1#g"`
    JAVA_HOME_CYGWIN=`echo $JAVA_HOME | sed "s#\([a-zA-Z]\):#${CYGDRIVE}/\1#g"`
    JRE_HOME_CYGWIN=`echo $JRE_HOME | sed "s#\([a-zA-Z]\):#${CYGDRIVE}/\1#g"`
    if [ -d "${JRE_HOME}/lib/ia64" ]; then
     CIE_PATH="${PATCH_PATH_CYGWIN}${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/64${PATHSEP}${WL_HOME_CYGWIN}/server/bin${PATHSEP}${ANT_HOME_CYGWIN}/bin${PATHSEP}${JRE_HOME_CYGWIN}/bin${PATHSEP}${JAVA_HOME_CYGWIN}/bin${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/64/oci920_8"
    else
     if [ -d "${JRE_HOME}/lib/i386" ]; then
       CIE_PATH="${PATCH_PATH_CYGWIN}${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/32${PATHSEP}${WL_HOME_CYGWIN}/server/bin${PATHSEP}${ANT_HOME_CYGWIN}/bin${PATHSEP}${JRE_HOME_CYGWIN}/bin${PATHSEP}${JAVA_HOME_CYGWIN}/bin${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/32/oci920_8"
     else
      if [ -d "${JRE_HOME}/lib/amd64" ]; then
       CIE_PATH="${PATCH_PATH_CYGWIN}${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/x64${PATHSEP}${WL_HOME_CYGWIN}/server/bin${PATHSEP}${ANT_HOME_CYGWIN}/bin${PATHSEP}${JRE_HOME_CYGWIN}/bin${PATHSEP}${JAVA_HOME_CYGWIN}/bin${PATHSEP}${WL_HOME_CYGWIN}/server/native/win/x64/oci920_8"
      fi
     fi
    fi 
  else
  # set PATH for other shell environments
    CIE_PATH="${WL_HOME}/server/bin${PATHSEP}${ANT_HOME}/bin${PATHSEP}${JRE_HOME}/bin${PATHSEP}${JAVA_HOME}/bin"
    # On Windows, include WebLogic jDriver in PATH
    if [ -n "`uname -s |grep -i windows_nt`" ]; then
     if [ -d "${JRE_HOME}/lib/ia64" ]; then
       CIE_PATH="${PATCH_PATH}${PATHSEP}${WL_HOME}/server/native/win/64${PATHSEP}${WL_HOME}/server/native/win/64/oci920_8"
     else
      if [ -d "${JRE_HOME}/lib/i386" ]; then
        CIE_PATH="${PATCH_PATH}${PATHSEP}${WL_HOME}/server/native/win/32${PATHSEP}${WL_HOME}/server/native/win/32/oci920_8"
      else
       if [ -d "${JRE_HOME}/lib/amd64" ]; then
         CIE_PATH="${PATCH_PATH}${PATHSEP}${WL_HOME}/server/native/win/x64${PATHSEP}${WL_HOME}/server/native/win/x64/oci920_8"
       fi
      fi
     fi 
    fi
  fi
fi
case "$PATH" in
  *${CIE_PATH}*);;
              *)PATH="${CIE_PATH}${PATHSEP}${PATH}";; 
esac

export PATH

resetFd

