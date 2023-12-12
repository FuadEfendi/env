#!/bin/sh
# *************************************************************************
# This script can be used to stop the NodeManager
#
#
# This script sets the following variables before stopping the NodeManager:
# 
# WL_HOME        - The root directory of your WebLogic installation.
# NODEMGR_HOME   - The root directory for this NodeManagerInstance.
# JAVA_OPTIONS   - This must be the same set of JAVA_OPTIONS as used to start
#                  the target NodeManager
# *************************************************************************
# Important internal variables:
#  srvr_pid      - This will usually be the single process id for the
#                  NodeManager being operated upon. However, in erroneous 
#                  situations, the possibility exists that multiple pids 
#                  will need to be managed at a time, thus it is treated
#                  as a list internally. Functions called from <main> 
#                  will work from this list and update it as needed
#

umask 027

WL_HOME="c:/Users/xiaol/Downloads/wls/wls12214/wlserver"
KILL=kill
EXIT=exit
OS=`uname -sr`
PS=ps
#REVIEW: should this be changed to include --no-headers now?
#solaris 5.10 does not allow --no-headers option
PS_OPTS=-ef

case $OS in
  SunOS*) PS=/usr/ucb/ps
          PS_OPTS=-auxw
          ;;
  *)
  ;;
esac

# In order to ensure that overall formatting and date formatting are 
# consistent, all output should be funneled through here and this 
# should only be called by functions such as 'info' and 'error' 
# $1   - type of message (e.g. 'info')
# $2-N - message to output
_msg() {
    msgType="$1"
    shift
    # AIX/HPIA/Solaris 5.10 do not allow space in date format string
    msg="<`date  "+%Y-%m-%d%t%Z%t%H:%M:%S"`> <$msgType> <StopNodeManager> <$@>"
    echo $msg
    writeToNMLog $msg
}
info() {
    _msg Info "$@"
}
error() {
    _msg Error "$@"
}
finish() {
    if [ "$TEMPLOGFILE" ] && [ -f "$TEMPLOGFILE" ] && [ "$NMLogFile" ] && [ -w "$NMLogFile" ]; then
        cat $TEMPLOGFILE >> $NMLogFile
        echo "$TEMPLOGFILE was copied to $NMLogFile"
    else 
        echo "Could not append $TEMPLOGFILE to $NMLogFile"
    fi
}
# write to NodeManager log file also if it is defined
writeToNMLog() {
    if [ "$TEMPLOGFILE" ]; then
        echo $@ >> $TEMPLOGFILE
    fi
}
# $1 - the process id to test
# returns true if ps can list the process id
pidExists() {
    # kill -0 is a quick test that the process is still running
    $KILL -0 $1 >/dev/null 2>&1
}

listProcesses() {
    $PS $PS_OPTS
}
killSignal() {
    signal=$1
    shift
    killPids="$@"
    info "Sending signal $signal to $killPids"
    # just in case we're in an oddball scenario with multiple, "valid" nodemanagers to kill
    for pid in $killPids; do
        pidExists $pid && $KILL -$signal $pid
    done
}
removeDeadPids() {
    livePids=''
    killPids="$@"
    srvr_pid=
    for pid in $killPids; do
        if pidExists $pid; then
            # AIX does not allow sleep < 1 second
            sleep 1
        fi
        
        if pidExists $pid; then
            info "Process $pid is still alive"
            srvr_pid="$pid $srvr_pid"
        fi
    done
    if [ "$srvr_pid" ]; then
        return 1
    fi
    return 0
}
sendTerm() {
    killSignal TERM $srvr_pid
    removeDeadPids $srvr_pid
    return 
}
sendKill() {
    killSignal KILL $srvr_pid
    removeDeadPids $srvr_pid
    return 
}
logTheLiving() {
    living=''
    for pid in $srvr_pid; do
        if pidExists $pid; then
            if [ "$living" ]; then
                living="$pid $living"
            else
                living=$pid
            fi
        fi
    done
    if [ "$living" ]; then
        info "It is possible that the current user '$USER' has insufficient permissions for operations on: $living. Try running this again as a user with confirmed, adequate permissions to successfully issue 'kill' commands to any listed surviving process."
    fi
}
# NOTE: it is possible, though not likely, to return more than one value from this
nmPid() {
    AWK_MATCH="`echo "-Dweblogic.RootDirectory=$ROOT_DIRECTORY" | sed 's#/#\\\\/#g'`"
    listProcesses | awk "!/awk/ && /java.*$AWK_MATCH.* weblogic.NodeManager/ {OFS=\" \";printf \$2}"
}

# populates srvr_pid with the list of NodeManager process id's that match JAVA_OPTIONS contents
scan_nodemanager_pids() {
    info "Scanning for appropriate NodeManager process to shutdown."
    srvr_pid="`nmPid`"
    if [ ! "$srvr_pid" ]; then 
        NMProcesses="`listProcesses | awk '!/awk/ && / weblogic.NodeManager /'`" 
        if [ "$NMProcesses" ]; then
            info "Could not find the correct NodeManager process from this list: $NMProcesses"
        else
            info "No candidate processes were available for consideration."
        fi
        return 1
    fi
}
# populates srvr_pid based on the content the lck file
read_nodemanager_pids() {
    if [ -f "$PidFile" ]; then
        read REPLY <"$PidFile" 2>/dev/null
        if [ -n "$REPLY" ]; then
            if [ "$REPLY" != "-1" ]; then
                srvr_pid=$REPLY
                info "Found process id from $PidFile: $srvr_pid"
            else
                info "NodeManager process id not available in file: $PidFile, possibly because the NodeManager process failed to write out its PID due to lack of native library."
            fi
        else
            info "NodeManager process id not found in file: $PidFile"
        fi
    else
        info "NodeManager process id file not found: $PidFile"
    fi
}

# Default settings
configureDefaultValues() {
    NMLogFile="$NODEMGR_HOME/nodemanager.log"

    #JWM-- so, if we get a value for NODEMGR_HOME and then figure out that it's not a directory, we 
    #JWM-- **silently** switch to using whatever the PWD happens to be? -- this just seems wrong
    #WITIAN: agreed. I prefer to log error and exit, since it is either because NM has never been started or wrong NM HOME is provided.
    if [ ! -d $NODEMGR_HOME ] ; then
        error "NODEMGR_HOME is not a directory: $NODEMGR_HOME. Cannot proceed."
        finish
        $EXIT 1
    fi
    # JWM -- Granted, this is included as a 'last resort' for determining the nmPid, 
    #        but I don't feel like we have an adequate handle on how to determine the 
    #        correct NM pid based on "JAVA_OPTIONS" content. In *nix systems, we
    #        could also examine its open file descriptors or some other deep system
    #        activity that we know should be particular to the NM we are seeking.
    #        However, I'm not aware of a generally available corollary to that 
    #        in a 'lowest common denominator' windows environment. With that said, 
    #        it would seem to better serve our users if we exercised the best 
    #        approaches possible where they are possible rather than provide less
    #        utility on all platforms because of the limitations of the most limited
    #        platform. I.e. *nix users should be allowed to reap the benefits of their
    #        platform of choice rather than be artificially limited by the limitations
    #        found on other platforms they may have avoided choosing to start with 
    #        because they are so limited.
    case "$JAVA_OPTIONS" in
        *-DNodeManagerHome=*)  
        # do nothing, critical value is already set
            info "NodeManagerHome already set in JAVA_OPTIONS"
            ;;
        *)        
            info "Adding NodeManagerHome entry to JAVA_OPTIONS: -DNodeManagerHome=$NODEMGR_HOME"
            if [ "${JAVA_OPTIONS}" ]; then
                JAVA_OPTIONS="-DNodeManagerHome=$NODEMGR_HOME ${JAVA_OPTIONS}"
            else
                JAVA_OPTIONS="-DNodeManagerHome=$NODEMGR_HOME"
            fi
            ;;
    esac

    if [ "${ROOT_DIRECTORY}" = "" ]; then
        info "Setting ROOT_DIRECTORY: $NODEMGR_HOME"
        ROOT_DIRECTORY="$NODEMGR_HOME"
    else
        info "Root Directory already set $ROOT_DIRECTORY"
    fi

    PidFile="$NODEMGR_HOME/nodemanager.process.id"
    LckFile="$NODEMGR_HOME/nodemanager.process.lck"
}
errorOutIfEmpty() {
    [ "$srvr_pid" ] && return
    error "Could not locate a NodeManager process id that matched required content of RootDirectory=$ROOT_DIRECTORY"
    finish
    $EXIT 1        
}
removeLock() {
    rm $PidFile && info "Removed NodeManager process id file: $PidFile"
    rm $LckFile && info "Removed NodeManager process lock file: $LckFile"
}
stopNM() {
    # Default NM Home
    if [ "${NODEMGR_HOME}" = "" ]; then
        NODEMGR_HOME="${WL_HOME}/../oracle_common/common/nodemanager" 
    else
        # in case NODEMGR_HOME is relative, make it absolute
        # AIX/HPIA/Solaris 5.10 platform does not allow readlink
        NODEMGR_HOME="`cd "$NODEMGR_HOME"; pwd -P`"
        info "NODEMGR_HOME is already set to $NODEMGR_HOME"
    fi

    TEMPLOGFILE="$NODEMGR_HOME/stopnodemanager.log"
    if [ -f "$TEMPLOGFILE" ]; then
        rm $TEMPLOGFILE
    fi
    if [ -f "$TEMPLOGFILE" ]; then
        _msg Warning "can't delete $TEMPLOGFILE Please delete it manually and then run this script again."
    fi

    # configureDefaultValues may need to be called before this if
    # it affects where 'info' content goes.
    info "Begin"
    configureDefaultValues

    # JWM --- Why do we change to this directory? If this cannot be supported, it should be removed.
    #         If it can be supported, we should either do it in a subshell or use something like pushd.
    cd "$NODEMGR_HOME"

    # This is the ordered list of functions to call to seek out the node manager process id
    # The first one to find an ID wins.
    # Note: when CLI input is allowed, insert the call to it here as appropriate
    populateActions="read_nodemanager_pids scan_nodemanager_pids errorOutIfEmpty"
    for action in $populateActions; do
        $action
        # break once we find any pids at all (last action should exit if no pids are found)
        [ "$srvr_pid" ] && break
    done
    # remember that we found something to attempt to kill
    foundPid="$srvr_pid"
    # This is the ordered list of functions to call to kill (or otherwise operate upon) the 
    # found node manager process id(s)
    killActions="sendTerm sendKill logTheLiving"
    for action in $killActions; do
        $action
        # break when there are no pids to operate upon (last action should log that we couldn't
        # terminate all pids initially found)
        [ "$srvr_pid" ] || break
    done
    
    # JWM --- It might make more sense to only remove the lck file in the event that we 
    #         successfully found a pid and now that pid is no more. Here's why:
    #         what if, for whatever reason, this script needed to be executed
    #         again as a different user, we may have removed the best source of information
    #         with the first run making subsequent executions that much more tenuous. Not that
    #         it makes sense for us to be able to remove a lock file but not kill a process,
    #         but it seems to be semi-plausible though logically non-sensible scenario that
    #         should be covered if only for the sake of completeness.
    if [ "$foundPid" ] && [ ! "$srvr_pid" ] && [ -f "$PidFile" ] ; then
        removeLock
    fi

    info "End"

    finish
}

# Small set of scenarios to cover: 
# pid pulled from lck file or 1-n pids pulled from '$PS $PS_OPTS'
# for every pid gathered (regardless of source):
#  send TERM signal
#  test and remove all dead pids from futher consideration
#  send KILL signal
#  test and remove all dead pids from futher consideration
#  issue warning, list surviving pids, exit
#
# TODO: allow for specified pid(s)

#Stop operation details
srvr_pid=
NMLogFile=
TEMPLOGFILE=
stopNM
