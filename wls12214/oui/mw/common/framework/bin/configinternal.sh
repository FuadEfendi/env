#!/bin/sh

CMD=configinternal.sh
USAGE="Usage: $CMD [ option ... ]"

# for identifying unsubbed tokens
AT='@'

# OUI platform name used at install time
PLATFORM_NAME=`uname -s`

# pre-install env: JAVA_HOME_LOCATION not stringsubbed
# post-install env: JAVA_HOME_LOCATION is stringsubbed
#JRELOC="/ade_autofs/gd29_3rdparty/nfsdo_generic/JDK7/MAIN/LINUX/130710.1.7.0.40.0B033/jdk7"
#Setting JRELOC
SCRIPT_PATH=`dirname $0`
ORACLE_HOME=$SCRIPT_PATH/../../../../..
JRELOC=`$ORACLE_HOME/oui/bin/getProperty.sh JAVA_HOME`

JAVA_OPTIONS=""
HOTSPOT_JAVA_OPTIONS="-mx512m -XX:MaxPermSize=512m -Doracle.installer.appendjre=true"
IBM_JAVA_OPTIONS="-mx512m -XX:MaxPermSize=512m -Xverify:none -Doracle.installer.appendjre=true"
JROCKIT_JAVA_OPTIONS="-mx512m -Doracle.installer.appendjre=true"

# fail if executed as ". configinternal.sh"
b="`basename $0`"
if [ "$b" != "$CMD" ] ; then
	#echo "$USAGE"
	return
fi

# help request handled by invoked class

getnext=no

# pick the 1st -jreLoc <arg>
for arg in "$@" ; do
	if [ "$getnext" = yes ] ; then
		JRELOC="$arg"
		break
	fi
	if [ x"$arg" = x-jreLoc ] ; then
		getnext=yes
	fi
done

# To determine Java Home:
# if -jreLoc is specified on the command line, use it
# else if the installer's Java Home was stringsubbed, use it
# else if environment variable JAVA_HOME is set, use it
# else fail
# WARNING: if the chosen value is invalid, we fail
# This could occur if a native installer did not actually install its
# JRE or JDK component but used it only to run the installer.

if [ "$JRELOC" = "${AT}JAVA_HOME_LOCATION${AT}" -o -z "$JRELOC" ] ; then
	if [ -z "$JAVA_HOME" ] ; then
		echo "ERROR: Must specify -jreLoc option or export JAVA_HOME"
		exit 1
	fi
	JRELOC="$JAVA_HOME"
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
version=`$JAVA_HOME/bin/java -version 2>&1`
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
*)	VM_TYPE=
	;;
esac

# add -d64 if the install-time platform was Solaris_SPARC64, etc.
# assume -d32 is the default, therefore not needed explicitly
case "$PLATFORM_NAME" in
SunOS|MAC-OS-IN64|HP-UX)
	JAVA_OPTIONS="-d64 $JAVA_OPTIONS"
	;;
esac

d="`dirname $0`"

# change to directory containing this script
cd "$d"
if [ -f "../jlib/ConfigLauncher.jar" ] ; then
	JAR="../jlib/ConfigLauncher.jar"
elif [ -f "../jlib/ConfigLauncher.jar" ] ; then
	JAR="../jlib/ConfigLauncher.jar"
else
	echo "ERROR: Cannot locate launcher"
	exit 1
fi

#CJ="../../../../modules/com.oracle.cie.comdev_7.1.0.0.jar:../../../../modules/com.oracle.cie.xmldh_2.7.0.0.jar:../../../../modules/com.oracle.cie.ora-installer_12.1.0.0.jar:../../../../modules/com.oracle.cie.oui-common_12.1.0.0.jar:$JAR"

CJ="../../../../modules/installer-launch.jar:$JAR"

#CLASSPATH_JARS="../../../../modules/*.jar"
echo $CJ
#"$JRELOC/bin/$AOUT" $JVM_ARGS $JAVA_OPTIONS -cp $CJ -jar "$JAR" "$@"
#"$JRELOC/bin/$AOUT" $JVM_ARGS $JAVA_OPTIONS -cp $CJ oracle.as.install.configlauncher.ConfigLauncher "$@"
"$JRELOC/bin/$AOUT" $JVM_ARGS $JAVA_OPTIONS -cp $CJ oracle.as.install.configlauncher.GLCMConfigLauncher "$@"

exit $?
