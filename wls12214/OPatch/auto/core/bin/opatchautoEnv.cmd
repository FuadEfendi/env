@ECHO OFF

SET SCRIPTPATH=%~dp0

FOR %%i IN ("%SCRIPTPATH%\..\..\..\..") DO SET ORACLE_HOME=%%~fsi

IF "%OPATCHAUTO_JAVA_HOME%"=="" (
  IF EXIST %ORACLE_HOME%\oui\bin\getVariable.cmd (
    CALL %ORACLE_HOME%\oui\bin\getVariable.cmd JAVA_HOME OPATCHAUTO_JAVA_HOME
  )
)

IF NOT "%OPATCHAUTO_JAVA_HOME%"=="" (
  IF NOT EXIST "%OPATCHAUTO_JAVA_HOME%" (
    ECHO The JAVA_HOME '%OPATCHAUTO_JAVA_HOME%' did not exist.
    SET OPATCHAUTO_JAVA_HOME=
  )
)

IF "%OPATCHAUTO_JAVA_HOME%"=="" (
  IF EXIST %ORACLE_HOME%\OPatch\jre (
    SET OPATCHAUTO_JAVA_HOME=%ORACLE_HOME%\OPatch\jre
  ) ELSE (
    IF EXIST %ORACLE_HOME%\jdk\bin\java.exe (
      SET OPATCHAUTO_JAVA_HOME=%ORACLE_HOME%\jdk
    ) ELSE (
      SET OPATCHAUTO_JAVA_HOME=%JAVA_HOME%
    )
  )
)

IF "%OPATCHAUTO_JAVA_HOME%"=="" (
  ECHO Unable to determine JAVA_HOME for opatchauto.  Please set JAVA_HOME in your environment.
  EXIT /B 1
)

FOR %%i IN ("%OPATCHAUTO_JAVA_HOME%") DO SET OPATCHAUTO_JAVA_HOME=%%~fsi
FOR %%i IN ("%SCRIPTPATH%\..\modules") DO SET OPATCHAUTO_MODULES_DIR=%%~fsi
FOR %%i IN ("%ORACLE_HOME%\OPatch\modules") DO SET OPATCH_COMMON_API_MODULES_DIR=%%~fsi
FOR %%i IN ("%ORACLE_HOME%\OPatch\auto\core") DO SET OPATCHAUTO_CORE_DIR=%%~fsi
FOR %%i IN ("%ORACLE_HOME%\oui\modules") DO SET OUI_MODULES_DIR=%%~fsi
FOR %%i IN ("%ORACLE_HOME%\OPatch\jlib") DO SET OPATCH_MODULES_DIR=%%~fsi
FOR %%i IN ("%ORACLE_HOME%\oracle_common\modules") DO SET ORACLE_COMMON_MODULES_DIR=%%~fsi
FOR %%i IN ("%ORACLE_HOME%\OPatch\modules") DO SET OPATCH_MODULES_LEGACY_DIR=%%~fsi

SET OPATCH_AUTO_WALLET_NON_NG_CLASSPATH=%OPATCH_MODULES_LEGACY_DIR%\features\orapki.lib.jar;%OPATCHAUTO_CORE_DIR%\modules\legacyoui\legacyoui.classpath.jar;%OPATCH_COMMON_API_MODULES_DIR%\features\oracle.glcm.opatchauto.core.wallet.classpath.jar

SET OPATCH_AUTO_WALLET_NG_CLASSPATH=%ORACLE_COMMON_MODULES_DIR%\features\orapki.lib.jar;%ORACLE_COMMON_MODULES_DIR%\features\orapki.lib_12.1.3.jar;%ORACLE_COMMON_MODULES_DIR%\features\glcm_encryption_lib.jar;%OPATCH_COMMON_API_MODULES_DIR%\features\oracle.glcm.opatchauto.core.wallet.classpath.jar

IF EXIST %ORACLE_HOME%\oracle_common (
 SET OPATCH_AUTO_WALLET_CLASSPATH=%OPATCH_AUTO_WALLET_NG_CLASSPATH%
) ELSE (
 SET OPATCH_AUTO_WALLET_CLASSPATH=%OPATCH_AUTO_WALLET_NON_NG_CLASSPATH%
)

SET OPATCHAUTO_CLASSPATH=%OPATCHAUTO_MODULES_DIR%\features\oracle.glcm.opatchauto.core.classpath.jar;%OPATCH_COMMON_API_MODULES_DIR%\features\oracle.glcm.opatch.common.api.classpath.jar;%OPATCHAUTO_MODULES_DIR%\features\oracle.glcm.opatchauto.core.binary.classpath.jar;%OUI_MODULES_DIR%\installer-launch.jar;%OPATCH_MODULES_DIR%\oracle.opatch.classpath.jar;%OPATCH_AUTO_WALLET_CLASSPATH%

