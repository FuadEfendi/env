@ECHO OFF

@REM wallet-manager.cmd
@REM
@REM Copyright (c) 2014, 2017, Oracle and/or its affiliates. All rights reserved.
@REM
@REM    NAME
@REM      wallet-manager.cmd - FMWPlatform Wallet Manager
@REM
@REM    DESCRIPTION
@REM      Run "wallet-manager.cmd help" to see supported commands.
@REM
@REM

SET BASEDIR=%~dp0
@REM ECHO BASEDIR=%BASEDIR%
@REM ###########################################################
@REM # locate JRE
@REM #   If JAVA_HOME is set then we use it
@REM #   Otherwise we will try to use a JDK from ORACLE_HOME
@REM ###########################################################
if NOT DEFINED JAVA_HOME (
  if DEFINED ORACLE_HOME (
    if EXIST %ORACLE_HOME%/jdk/bin/java.exe (
      SET JAVA_HOME=%ORACLE_HOME%/jdk
    ) ELSE (
      ECHO JAVA_HOME is unset.
	  EXIT /B 1
	)
  ) ELSE (
      ECHO JAVA_HOME is unset. ORACLE_HOME is undefined.
	  EXIT /B 1
  )
)

SET JAVA="%JAVA_HOME%/bin/java.exe"
@REM ECHO "JAVA=%JAVA%"
if NOT EXIST %JAVA% (
  ECHO The Java executable $JAVA does not exist. 1>&2
  ECHO Set JAVA_HOME to reference a valid JRE. 1>&2
  EXIT /B 1
)

SET JRE_OPTIONS="-Xmx512m"
SET JRE_CP="%BASEDIR%../modules/features/oracle.fmwplatform.fmwprov_lib.jar"

@REM ECHO JRE_OPTIONS=%JRE_OPTIONS%
@REM ECHO JRE_CP=%JRE_CP%

%JAVA% %JRE_OPTION% -cp %JRE_CP% oracle.fmwplatform.credentials.wallet.WalletManager %*

SET EXIT_CODE=%ERRORLEVEL%
ECHO WALLET-MANAGER exited with code: %EXIT_CODE%.
EXIT /B %EXIT_CODE%
