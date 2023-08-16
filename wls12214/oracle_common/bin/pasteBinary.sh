#!/bin/sh
#
# pasteBinary.sh
#
# Copyright (c) 2010, 2017, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      pasteBinary.sh - Script to paste Oracle Middleware Home binaries
#
#    DESCRIPTION
#      This script is used to paste the Middleware Home binaries.
#      This script invokes the t2p implementation and has one mandatory parameter
#      to call the implementation.
#
#      -javaHome   -java home location.
#
#    NOTES
#      Based on the pasteBinary.sh created by ASINST team
#

# Declare variables for use
args=$*
isccpresent="false"
isccpresentinjlib="false"
d64option=""
argsarray=""
argsarrayclone=""
isjavahomeprovided="false"
isexecutesysprereqs="false"
argsarrayPrereq=""
isclone="false"

case `uname -s` in
Windows*|CYGWIN*)
	AOUT="java.exe"
	;;
*)
	AOUT="java"
	;;
esac

# Help message for pasteBinary
help() {

	echo "usage:"
	echo "       Options in brackets [] are optional"
	echo ""
	echo "       pasteBinary.sh"
	echo ""
	echo "       -archiveLoc archive_location"
	echo "       -targetOracleHomeLoc target_Oracle_Home"
	echo ""
	echo "       [-targetOracleHomeName target_Oracle_Home_name]"
	echo "       [-javaHome java_home]"
	echo "       [-silent true|false]"
	echo "       [-ignoreDiskWarning false|true]"
	echo "       [-ignoreJavaVersion false|true]"
	echo "       [-ohAlreadyCloned false|true] * If true then -archiveLoc is optional"
	echo "       [-prereqConfigLoc prereqs_file_location]"
	echo "       [-entryPoint entry_point_name]"
	echo "       [-invPtrLoc orainst_loc_file]"
	echo "       [-executeSysPrereqs false|true]"
	echo ""
	echo "Try \"pasteBinary.sh -help\"  for more information."
	echo ""
	echo "If pasteBinary is not available it can also be invoked from package like:"
	echo ""
	echo "       java -jar archive_location -targetOracleHomeLoc target_Oracle_Home"
	echo ""
	echo "For more information you can also call:"
	echo ""
	echo "       java -jar archive_location -help"
	exit 1
	
}

# To validate javaHome value
validate_java_home() {

	java_home="$1"
	if [ ! -d "${java_home}" ];then
	
		echo "Java home location is invalid because \"${java_home}\" is not a directory."
		exit 1
	
	fi
	
	if [ ! -f "$java_home/bin/${AOUT}" ] ; then 
	
		echo "Java home location is invalid because  \"${java_home}/bin/${AOUT}\" does not exist."
		exit 1
		
	fi
	
}
 
# Iterate through the command line parameters to check the mandatory params required to execute the cloningclient

# prevopt is non-empty only if previous opt is a valid
# pasteBinary-specific option
prevopt=""
for tempvar in "$@" ; do
	
	#convert the argument to a lower case to make the comparison case insensitive 
	lower=`echo ${tempvar}|tr '[A-Z]' '[a-z]'`

	case "x$lower" in
	x-archiveloc|x-targetoraclehomeloc|x-targetoraclehomename|x-javahome|x-silent|x-ignorediskwarning|x-ignorejavaversion|x-ohalreadycloned|x-executesysprereqs|x-invptrloc|x-prereqconfigloc|x-entrypoint)
		# set prevopt only if this is a valid pasteBinary-specific option
		if [ -n "${prevopt}" ] ; then
			# e.g. pasteBinary.sh -silent -archiveLoc /tmp/generic.jar ...
			echo "Invalid option sequence ${prevopt} ${tempvar} (${prevopt} must be followed by a value, not another dashed option)."
			help
		fi
		prevopt="${lower}"
		;;
	x-d64)
		# ignore -d64 because launch.sh determines the correct value
		if [ -n "${prevopt}" ] ; then
			# e.g. pasteBinary -silent -d64 -archiveLoc ...
			echo "Invalid option sequence ${prevopt} ${tempvar} (${prevopt} must be followed by a value, not another dashed option)."
			help
		fi
		prevopt=""
		;;
	x-help)
		# print usage message and exit
		help
		;;
	*)

		case "x${prevopt}" in
		x)
			# prevopt is empty, therefore not a recognized
			# pasteBinary-specific option
			# so pass on this opt without change
			# e.g. -debug, which will be accepted by Launcher
			# e.g. -nowait, also accepted by Launcher, valid with MKS
			# e.g. -bogus, which will be rejected by Launcher
			argsarray="${argsarray} ${tempvar}"
			argsarrayclone="${argsarrayclone} ${tempvar}"
			;;

		x-archiveloc)
			# Launcher must validate -archiveLoc
			argsarray="${argsarray} -archiveLoc ${tempvar}"
			isarchivelocprovided=true
			;;

		x-ohalreadycloned)
			if [ "$lower" = "true" ] ; then
				isclone="true"
			elif [ "$lower" != "false" ] ; then
				help
			fi
			;;

		x-javahome)
			# do not pass invalid Java Home to launch.sh
			validate_java_home ${tempvar}
			javaHome="`cd ${tempvar}; pwd`"
			argsarray="${argsarray} -jreLoc ${javaHome}"
			argsarrayclone="${argsarrayclone} -jreLoc ${javaHome}"
			;;

		x-targetoraclehomeloc)		
			argsarray="${argsarray} ORACLE_HOME=${tempvar}"
			argsarrayclone="${argsarrayclone} ORACLE_HOME=${tempvar}"
			isorahomeprovided=true
			;;

		x-targetoraclehomename)
			argsarray="${argsarray} ORACLE_HOME_NAME=${tempvar}"
			argsarrayclone="${argsarrayclone} ORACLE_HOME_NAME=${tempvar}"
			;;

		x-silent)
			# disallow -silent xyz but then ignore it
			# because -silent false is not supported
			if [ "$lower" != "true" -a "$lower" != "false" ] ; then
				echo "Invalid option ${prevopt} ${tempvar} (value must be true or false)"
				help
			fi
			;;

		x-invptrloc)
			argsarray="${argsarray} ${prevopt} ${tempvar}"
			argsarrayclone="${argsarrayclone} ${prevopt} ${tempvar}"			
			;;

		x-prereqconfigloc|x-entrypoint)
			argsarrayPrereq="${argsarrayPrereq} ${prevopt} ${tempvar}"
			;;

		x-ignorediskwarning|x-ignorejavaversion)
			if [ "$lower" = "true" ] ; then
				argsarray="${argsarray} ${prevopt}"
			elif [ "$lower" != "false" ] ; then
				echo "Invalid option sequence ${prevopt} ${tempvar} (${prevopt} must be followed by true or false)"
				help
			fi
			;;

		x-executesysprereqs)
			if [ "$lower" = "true" ] ; then
				isexecutesysprereqs="true"
			elif [ "$lower" != "false" ] ; then
				echo "Invalid option sequence ${prevopt} ${tempvar} (${prevopt} must be followed by true or false)"
				help
			fi
			;;

		*)
			# internal error? all valid pasteBinary-specific options
			# should be in the above case statement
			echo "Invalid option sequence ${prevopt} ${tempvar}"
			help
			;;
		esac

		prevopt=""
		;;
	esac
done

# Check if last argument was an option
if [ -n "${prevopt}" ];then
	echo "Invalid option ${prevopt} (requires a value)"
	help	
fi

if [ "${isorahomeprovided}" != "true" ];then
	echo "Option -targetOracleHomeLoc must be provided"
	help
fi

if [ "${isarchivelocprovided}" != "true" -a "$isclone" != "true" ];then
	echo "Option -archiveLoc must be provided"
	help
fi

if [ "${isexecutesysprereqs}" = "true" ];then
	argsarray="${argsarray} ${argsarrayPrereq}"
fi

SCRIPT_PATH=$(dirname "$0")
cd $SCRIPT_PATH

if [ "$isclone" = "true" ];then

	../../oui/bin/launch.sh -clone -silent ${argsarrayclone}
	
else

	../../oui/bin/launch.sh -applyCloneArchive ${argsarray}
	
fi

exit $?
