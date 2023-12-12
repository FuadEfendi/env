NAME

operr

SYNOPSIS

operr  <opatch error code> [-f <message file>] [-help] [-version] 
                           [-jdk <JDK home>] [-jre <JRE home>]

opatch error code: the error code printed to the console when you invoke
OPatch.

[message file]: this argument is optional. If you don't specify the message
file, 
OPatch will use the built-in message file bundled inside the Java package 
$ORACLE_HOME/OPatch/jlib/opatch.jar (package oracle/opatch/diag/operr.txt).

The message file is a file that contains probable causes and recommended 
actions for all OPatch error code. OPatch team also puts the latest message 
file on My Oracle Support. You can download the latest patch 16609471 that has 
the latest message file, and run operr with the "-f" option to retrieve latest 
probable causes and recommended actions.

[-version]: "operr version" will print out the version of the operr utility
and 
the built-in message file. "operr -f/latest_message_file -version will print 
out the version of the operr utility and the message file specified by -f 
argument.

[jdk] or [jre]: operr is a Java utility. If there is no JRE or JDK in the 
Oracle Home, you can use these arguments to launch operr.

Overview

operr is a troubleshooting utility for OPatch. When OPatch errors out with an 
error code, you can invoke operr on that  error code to get a probable cause 
and recommended actions.

For example, let's say OPatch errors out as following

"OPatch failed with error code 2"

Then you can invoke operr as following

setenv ORACLE_HOME /path to OH

$ORACLE_HOME/OPatch/operr  2

Use cases

1/ "opatch apply" fails with error code 16. Users want to know what to do.

$ORACLE_HOME/OPatch/operr 16 -/tmp/operr.txt
Error code: 16

Error message: The Oracle Home may be locked by other OPatch/OUI processes.

Recommended actions: Please contact Oracle Support.

2/ Users want to run with the latest message file

Go to My Oracle Support and download patch 16609471. Follow the patch 
instruction to get the latest message file operr.txt.  Put the file in 
/tmp/operr.txt.

Run operr with -f option.

$ORACLE_HOME/OPatch/operr 16 -/tmp/operr.txt
Error code: 16

Error message: The Oracle Home may be locked by other OPatch/OUI processes. 
Maybe you are installing some Oracle products or you are using OPatch to
patch some Oracle products on this machine.

Recommended actions: You can check whether there is OPatch or OUI process 
running by running $ORACLE_HOME/oui/bin/runInstaller. If this command fails, 
that means there is other OPatch or OUI process running. Please kill those 
processes, remove the file $ORACLE_HOME/.patch_storage/patch_locked and 
then retry.

3/ Users want to see if they have the latest message file

$ORACLE_HOME/OPatch/operr  -version

operr version is 12.1.0.1.1

Message file version is 12.1.0.1.1

Users go to My Oracle Support and download patch 16609471. Users then run 
"operr -version -f"

$ORACLE_HOME/OPatch/operr -version -f /tmp/operr.txt

operr version is 12.1.0.1.1

Message file version is 12.1.0.2.3

Or users can look at the patch 16609471 README on My Oracle Support and see 
if it is a later version w/o having to download.
