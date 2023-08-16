#!/bin/sh

# Convert the 1st arg to an absolute path.  OS specific
absolutePath() {
  case $OS in
  Windows_NT*)
    # for MKS Toolkit on Windows, an absolute path starts with a drive letter prefix or a UNC path.
    # Assume only forward slashes 
    case $1 in
      [a-zA-Z]:*)
        # Drive prefix
        echo $1
        ;;
      //*)
        # UNC path
        echo $1
        ;;
      /*)
        # path is absolute, but the drive is relative
        p=${mypwd##??}
        echo ${mypwd%%${p}}$1
        ;;
      *)
        # relative path
        echo ${mypwd}/$1
        ;;
    esac
    ;;
  *)
    # for everything else, an initial / indicates an absolute path
    case $1 in
      /*)
        # absolute path
        echo $1
        ;;
      *)
        # relative path
        echo ${mypwd}/$1
        ;;
    esac
    ;;
  esac
}

getMWH() {
  while [ "$#" -gt "0" ]
  do
    case $1 in
      "-mwh")
        MWH=$2
        shift
        ;;
      "-mwh="*)
        MWH=`echo $1 | cut -d'=' -f2`
        ;;
      *)
        ;;
    esac
    shift
  done
  echo $MWH
}

mypwd="`pwd`"

MWH_DIR=`getMWH "$@"`
if [ -z "${MWH_DIR}" ] ; then
  echo Location of original MW HOME not specified
  exit 1
fi
MW_HOME=`absolutePath $MWH_DIR`
export MW_HOME

# Determine the location of this script...
# Note: this will not work if the script is sourced (. ./config.sh)
SCRIPTNAME=`absolutePath $0`
case ${SCRIPTNAME} in
 /*)  SCRIPTPATH=`dirname "${SCRIPTNAME}"` ;;
  *)  SCRIPTPATH=`dirname "${mypwd}/${SCRIPTNAME}"` ;;
esac

# Set the home directories...
. "${MW_HOME}/oracle_common/common/bin/setHomeDirs.sh"

FMW_UTIL_MODULE=${SCRIPTPATH}/../modules/com.oracle.cie.template-repo_1.0.0.0.jar

OS=`uname -s`

umask 027

# set up common environment
. "${WL_HOME}/common/bin/commEnv.sh"
CLASSPATHSEP=:

case $OS in
Windows_NT*)
  CLASSPATHSEP=\;
;;
CYGWIN*)
  CLASSPATHSEP=\;
;;
esac
export CLASSPATHSEP
CLASSPATH="${FMW_UTIL_MODULE}${CLASSPATHSEP}${FMWCONFIG_CLASSPATH}${CLASSPATHSEP}${DERBY_CLASSPATH}"
export CLASSPATH

JVM_ARGS="-Dprod.props.file='${WL_HOME}/.product.properties' -DMW_HOME=${MW_HOME} -Dpython.cachedir=/tmp/cachedir ${JVM_D64} ${MEM_ARGS} ${CONFIG_JVM_ARGS}"
if [ -d "${JAVA_HOME}" ]; then
  eval '"${JAVA_HOME}/bin/java"' ${JVM_ARGS} com.oracle.cie.external.domain.ReconstructDomain '$@'
fi
