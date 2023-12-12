#!/bin/sh
#
# $Header: asinst/dist/oracle.as.install.ui.framework/bin/config.sh /main/2 2018/08/30 23:24:37 ambalakr Exp $
#
# config.sh
#
# Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      config.sh - <one-line expansion of the name>
#
#    DESCRIPTION
#      <short description of component this file declares/defines>
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    ambalakr    05/17/18 - Creation
#

CMD=config.sh
USAGE="Usage: $CMD [ -oh <Oracle Home absolute path> ] [ -oracle.as.install.engine.install.properties.location <Install properties file absolute path> ] "

# for identifying unsubbed tokens
AT='@'

PLATFORM_NAME="Linux_AMD64"

JAVA_OPTIONS=""
HOTSPOT_JAVA_OPTIONS=""
IBM_JAVA_OPTIONS=""
JROCKIT_JAVA_OPTIONS=""

config_path="`dirname $0`"

if [ "$config_path" = "." ]; then
    config_path=`pwd`;
fi

# Replace relative path with fully qualified path.
if [ ! "`echo $config_path|/bin/grep '^/'`" ]; then
    config_path=`pwd`/$config_path;
fi


#Parse arguments
upper=`echo $1|tr '[a-z]' '[A-Z]'`

if [ -z "$1" -o x"$upper" = "x-HELP" ] ; then
  echo "$USAGE"
  exit 1
fi

echo config_path : $config_path
cd $config_path/../../..
glcm_home_bin=`pwd`/bin;
echo glcm_home_bin : $glcm_home_bin

# Determine the default Java Home location
# 1) if "getProperty LCM_JAVA_HOME" provides a value, use it
# 2) else use env variable JAVA_HOME
# Later, this default may be overridden by -jreLoc option

JRELOC=""
if [ -x "$glcm_home_bin/getProperty.sh" ] ; then
        JRELOC="`$glcm_home_bin/getProperty.sh RUNTIME_JAVA_8_HOME 2>/dev/null`"
fi

if [ -z "$JRELOC" -o ! -d "$JRELOC" ] ; then
        JRELOC="`$glcm_home_bin/getProperty.sh LCM_JAVA_8_HOME 2>/dev/null`"
fi

if [ -z "$JRELOC" -o ! -d "$JRELOC" ] ; then
        JRELOC="$JAVA_HOME"
fi

# fail if executed as ". setRehydratedEnvVars.sh"
b="`basename $0 2>/dev/null`"
echo "b : $b"
echo "CMD : $CMD"
if [ "$b" != "$CMD" ] ; then
        echo "$USAGE"
        exit 1
fi

echo "JRELOC : $JRELOC"
if [ -z "$JRELOC" ] ; then
        echo "ERROR: Cannot determine the Java Home"
        echo "ERROR: Specify the -jreLoc option or export JAVA_HOME"
        exit 1
fi

if [ ! -d "$JRELOC" ] ; then
        echo "ERROR: Java Home directory \"$JRELOC\" does not exist"
        exit 1
fi
case `uname -s` in
Windows*|CYGWIN*)
        AOUT="java.exe"
        ;;
*)
        AOUT="java"
        ;;
esac

if [ ! -f "$JRELOC/bin/$AOUT" ] ; then
        echo "ERROR: Java Home directory \"$JRELOC\" does not contain bin/$AOUT"
        exit 1
fi

if [ "$JAVA_OPTIONS" = "${AT}JAVA_OPTIONS${AT}" ] ; then
        unset JAVA_OPTIONS
fi

# determine VM_TYPE and JVM options
version=`$JRELOC/bin/$AOUT -version 2>&1`
echo java version : $version
case "$version" in
*HotSpot*)
        VM_TYPE=HotSpot
        if [ "$HOTSPOT_JAVA_OPTIONS" != "${AT}HOTSPOT_JAVA_OPTIONS${AT}" ] ; then
                JAVA_OPTIONS="$HOTSPOT_JAVA_OPTIONS $JAVA_OPTIONS"
        fi
        ;;
*JRockit*)
        VM_TYPE=JRockit
        if [ "$JROCKIT_JAVA_OPTIONS" != "${AT}JROCKIT_JAVA_OPTIONS${AT}" ] ; then
                JAVA_OPTIONS="$JROCKIT_JAVA_OPTIONS $JAVA_OPTIONS"
        fi
        ;;
*IBM*)
        VM_TYPE=IBM
        if [ "$IBM_JAVA_OPTIONS" != "${AT}IBM_JAVA_OPTIONS${AT}" ] ; then
                JAVA_OPTIONS="$IBM_JAVA_OPTIONS $JAVA_OPTIONS"
        fi
        ;;
*)      VM_TYPE=
        ;;
esac

# add -d64 if the install-time platform was Solaris_SPARC64, etc.
# assume -d32 is the default, therefore not needed explicitly
case "$PLATFORM_NAME" in
Solaris_SPARC64|Intel_Solaris|MAC-OS-IN64|HP_IA64)
        JAVA_OPTIONS="-d64 $JAVA_OPTIONS"
        ;;
esac

echo JAVA_OPTIONS : $JAVA_OPTIONS
# change to directory containing this script
cd $glcm_home_bin

for arg in "$@"
do
	if [ $arg == "-oh" ]
	then
		ORACLE_HOME="<nextval>"
	elif [[ -n $ORACLE_HOME ]] && [[ $ORACLE_HOME == "<nextval>" ]]
	then
		ORACLE_HOME=$arg
	elif [ $arg == "-oracle.as.install.engine.install.properties.location" ]
	then
		install_prop_loc="<nextval>"

	elif [[ -n $install_prop_loc ]] && [[ $install_prop_loc == "<nextval>" ]]
	then
		install_prop_loc=$arg
	elif [ $arg == "-tmpDir" ]
	then
		tmpDir="<nextval>"

	elif [[ -n $tmpDir ]] && [[ $tmpDir == "<nextval>" ]]
	then
		tmpDir=$arg
	fi
done

if [[ -n $ORACLE_HOME ]] && [[ $ORACLE_HOME == "<nextval>" ]]
then
	ORACLE_HOME=""
fi

if [[ -n $install_prop_loc ]] && [[ $install_prop_loc == "<nextval>" ]]
then
	install_prop_loc=""
fi

if [[ -n $tmpDir ]] && [[ $tmpDir == "<nextval>" ]]
then
	tmpDir=""
fi

if [[ -f $install_prop_loc ]]
then
	if [[ -z $ORACLE_HOME ]] && [[ -f $install_prop_loc ]]
	then
		ORACLE_HOME=${install_prop_loc%/*}/../../../..
		if [[ ! -f "$ORACLE_HOME/oraInst.loc" ]] 
		then
			ORACLE_HOME=""
		fi
	fi
else
	echo "$USAGE"
	exit 1
fi

echo ORACLE_HOME : $ORACLE_HOME
echo "Install properties loc : $install_prop_loc"

if [[ -z $ORACLE_HOME ]]
then
	echo "$USAGE"
	exit 1
fi

oraInst_file=$ORACLE_HOME/oraInst.loc
while IFS='' read -r line || [[ -n "$line" ]];
do
	if [[ $line = "inventory_loc="* ]]
	then
		IFS='=' read -r -a array <<< "$line"
		inventory_loc=${array[${#array[@]} - 1]}

	fi
done < "$oraInst_file"

echo "Inventory Loc : $inventory_loc"

IS_NEXTGEN=`./isNextGen.sh -oh $ORACLE_HOME`
echo "IS_NEXTGEN : $IS_NEXTGEN"
if [ ! "$IS_NEXTGEN" = "Valid NextGen Home." ] 
then
	echo "Invalid NextGen Home !!!"
	exit 1
fi

INSTALLER_LAUNCHER_IN_GLCM="modules/installer-launch.jar"
OUI_LIB_FOLDER=`sh getOUILibFolder.sh -oh $ORACLE_HOME`
OUI_JAR="$OUI_LIB_FOLDER/$INSTALLER_LAUNCHER_IN_GLCM"

if [ ! -f "$OUI_JAR" ] || [ -z "$OUI_JAR" ] ; then
        echo "ERROR: Cannot locate the NextGen OUI Libraries.  Exiting"
        exit 1
fi

if [[ -n $tmpDir ]]
then
	echo "Setting temporary dir to $tmpDir for internal processing"
	echo mkdir -p $tmpDir
	mkdir -p $tmpDir
	mkdir_exit_code=$?
	if [ $mkdir_exit_code -eq 0 ]; then
		echo "Temp Directory Sucessfully created"
		TMP_DIR=`mktemp -d -p $tmpDir`
	fi 

fi

if [[ -z $TMP_DIR ]]
then
	#Default temp
	echo "Using default temp directory."
	#Default temp
	TMP_DIR=`mktemp -d`
fi

GLCM_NG_HOME="$OUI_LIB_FOLDER/.."
cp -rf $GLCM_NG_HOME/* $TMP_DIR/

ENGINE_CONFIG_LAUNCHER_JAR="$TMP_DIR/oui/mw/common/framework/jlib/ConfigLauncher.jar"
OUI_JAR="$TMP_DIR/oui/$INSTALLER_LAUNCHER_IN_GLCM"
JAR="$OUI_JAR:$ENGINE_CONFIG_LAUNCHER_JAR"
#MAIN_CLASS=oracle.as.install.configlauncher.ConfigLauncher
MAIN_CLASS=oracle.as.install.configlauncher.GLCMConfigLauncher

ORA_PARAM="$TMP_DIR/oui/mw/common/framework/metadata/oraparam.ini"


cd $ORACLE_HOME

echo "$JRELOC/bin/$AOUT" $JVM_ARGS $JAVA_OPTIONS -classpath "$JAR" $MAIN_CLASS -silent -oraparam $ORA_PARAM -scratchPath $TMP_DIR "$@"
"$JRELOC/bin/$AOUT" $JVM_ARGS $JAVA_OPTIONS -classpath "$JAR" $MAIN_CLASS -silent -oraparam $ORA_PARAM -scratchPath $TMP_DIR "$@"
exit_code=$?

# if inv is present, copy the log to $inventory logs and remove tmp files
if [[ -d "$inventory_loc" ]]
then
	if [[ ! -d "$inventory_loc/logs" ]]
	then
		mkdir $inventory_loc/logs
	fi
	log_file=`ls -t1 $TMP_DIR |  head -n 1`
	cp $TMP_DIR/$log_file $inventory_loc/logs/
	cp_exit_code=$?
	if [ $cp_exit_code -eq 0 ]
	then
		echo "Log file copied to $inventory_loc/logs/$log_file"
		rm -rf $TMP_DIR
	else
		echo "Unable to copy $log_file to  $inventory_loc/logs."
	fi 
else
	echo "Log : $TMP_DIR/$log_file"
fi

cd $config_path
exit $exit_code
