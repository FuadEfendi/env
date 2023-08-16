@rem *************************************************************************
@rem This script is used to initialize common environment to start WebLogic
@rem Server, as well as WebLogic development.
@rem
@rem It sets the following variables:
@rem
@rem BEA_HOME   - The home directory of all your BEA installation.
@rem MW_HOME    - The home directory of all your Oracle installation.
@rem WL_HOME    - The root directory of your WebLogic installation.
@rem COHERENCE_HOME    - The root directory of your Coherence installation.
@rem ANT_HOME   - The Ant Home directory.
@rem ANT_CONTRIB
@rem            - The Ant contrib directory
@rem JAVA_HOME  - Location of the version of Java used to start WebLogic
@rem              Server. See the Oracle Fusion Middleware Supported System Configurations page at
@rem              (http://www.oracle.com/technology/software/products/ias/files/fusion_certification.html) for an
@rem              up-to-date list of supported JVMs on your platform.
@rem JAVA_VENDOR
@rem            - Vendor of the JVM (i.e. BEA, HP, IBM, Sun, etc.)
@rem JAVA_USE_64BIT
@rem            - Indicates if JVM uses 64 bit operations
@rem PATH       - JDK and WebLogic directories are added to the system path.
@rem WEBLOGIC_CLASSPATH
@rem            - Classpath required to start WebLogic server.
@rem FMWCONFIG_CLASSPATH
@rem            - Classpath required to start config tools such as config wizard, pack, and unpack..
@rem FMWLAUNCH_CLASSPATH
@rem            - Additional classpath needed for WLST start script
@rem JAVA_VM    - The java arg specifying the JVM to run.  (i.e.
@rem              -server, -hotspot, -jrocket etc.)
@rem MEM_ARGS   - The variable to override the standard memory arguments
@rem              passed to java
@rem UTILS_MEM_ARGS   - The variable to override the standard memory arguments
@rem              passed to java for configuration utilities
@rem
@rem DERBY_HOME
@rem            - Derby home directory.
@rem DERBY_CLASSPATH
@rem            - Classpath needed to start Derby.
@rem DERBY_TOOLS
@rem            - Derby tools jar file.
@rem PRODUCTION_MODE
@rem            - Indicates if WebLogic Server will be started in Production
@rem              mode.
@rem PATCH_CLASSPATH
@rem            - WebLogic Patch system classpath
@rem PATCH_LIBPATH  
@rem            - Library path used for patches
@rem PATCH_PATH     
@rem            - Path used for patches
@rem WEBLOGIC_EXTENSION_DIRS
@rem            - Extension dirs for WebLogic classpath patch
@rem
@rem *************************************************************************

IF NOT DEFINED MW_HOME (
  echo Please set MW_HOME  
  IF DEFINED USE_CMD_EXIT (
   EXIT 1
  ) ELSE (
   EXIT /B 1
  )
)

IF NOT DEFINED WL_HOME (
  echo Please set WL_HOME 
  IF DEFINED USE_CMD_EXIT (
   EXIT 1
  ) ELSE (
   EXIT /B 1
  )
)

@rem Set Middleware Home
set BEA_HOME=%MW_HOME%

@rem Set Coherence Home
set COHERENCE_HOME=%MW_HOME%\coherence

@rem Set Common Modules Directory
set MODULES_DIR=%MW_HOME%\oracle_common\modules

@rem Set Common Features Directory
set FEATURES_DIR=%MW_HOME%\oracle_common\modules\features

@rem Set Ant Home
IF EXIST %MW_HOME%\oracle_common\modules\thirdparty\org.apache.ant\1.10.5.0.0\apache-ant-1.10.5 (
  set ANT_HOME=%MW_HOME%\oracle_common\modules\thirdparty\org.apache.ant\1.10.5.0.0\apache-ant-1.10.5
) 

@rem Set Ant Contrib
set ANT_CONTRIB=%MW_HOME%\oracle_common\modules\thirdparty

SET SECURITY_JVM_ARGS=-Dweblogic.alternateTypesDirectory=%MW_HOME%\oracle_common\modules\oracle.oamprovider,%MW_HOME%\oracle_common\modules\oracle.jps

@rem shorten CLASSPATH and PATH
set UNSHORTENED_PATH=%PATH%
if exist "%MW_HOME%\oracle_common\common\bin\shortenPaths.cmd" call "%MW_HOME%\oracle_common\common\bin\shortenPaths.cmd"

set ENV_JAVA_HOME=%JAVA_HOME%

@rem Reset JAVA_HOME, JAVA_VENDOR and PRODUCTION_MODE unless JAVA_HOME and
@rem JAVA_VENDOR are defined already.
if   DEFINED JAVA_HOME   if  DEFINED JAVA_VENDOR goto noReset

@REM The call below sets JAVA_HOME
call "%MW_HOME%\oui\bin\getProperty.cmd" JAVA_HOME

if not exist "%JAVA_HOME%" if defined ENV_JAVA_HOME set JAVA_HOME=%ENV_JAVA_HOME%
FOR %%i IN ("%JAVA_HOME%") DO SET JAVA_HOME=%%~fsi

@rem JAVA VENDOR, possible values are:
@rem Oracle, HP, IBM, Sun, etc.
if NOT DEFINED JAVA_VENDOR set  JAVA_VENDOR=@JAVA_VENDOR@

@rem PRODUCTION_MODE, default to the development mode
set  PRODUCTION_MODE=

:noReset
set JRE_HOME=%JAVA_HOME%
IF EXIST %JAVA_HOME%\jre set JRE_HOME=%JAVA_HOME%\jre
@rem JAVA_USE_64BIT, true if JVM uses 64 bit operations 
set JAVA_USE_64BIT=false
IF EXIST %JRE_HOME%\lib\ia64 ( set JAVA_USE_64BIT=true
) ELSE (
 IF EXIST %JRE_HOME%\lib\amd64 set JAVA_USE_64BIT=true
)

@rem set up JVM options
if "%JAVA_VENDOR%" == "Oracle" goto oracle
if "%JAVA_VENDOR%" == "Sun" goto sun

goto continue

:oracle
if "%VM_TYPE%" == "HotSpot" goto sun
set VM_TYPE=HotSpot
if exist %JRE_HOME%\bin\jrockit (
  set VM_TYPE=JRockit
) else (
  for /d %%I in (%JRE_HOME%\lib\*) do if exist %%I\jrockit set VM_TYPE=JRockit
)    

if NOT "%VM_TYPE%" == "JRockit" goto sun
if "%PRODUCTION_MODE%" == "true" goto oracle_prod_mode
set JAVA_VM=-jrockit
set MEM_ARGS=-Xms128m -Xmx256m
set UTILS_MEM_ARGS=-Xms32m -Xmx1024m
goto continue

:oracle_prod_mode
set JAVA_VM=-jrockit
set MEM_ARGS=-Xms128m -Xmx256m
set UTILS_MEM_ARGS=-Xms32m -Xmx1024m
goto continue


:sun
set VM_TYPE=HotSpot
if "%PRODUCTION_MODE%" == "true" goto sun_prod_mode
set JAVA_VM=-server
set MEM_ARGS=-Xms32m -Xmx200m
set UTILS_MEM_ARGS=-Xms32m -Xmx1024m
goto continue

:sun_prod_mode
set JAVA_VM=-server
set MEM_ARGS=-Xms32m -Xmx200m
set UTILS_MEM_ARGS=-Xms32m -Xmx1024m
goto continue

:continue

if not "%USE_JVM_SYSTEM_LOADER%" == "true"  set JAVA_LOCAL_OPTIONS=-Djava.system.class.loader=com.oracle.classloader.weblogic.LaunchClassLoader

if not defined JAVA_LOCAL_OPTIONS goto after_java_options
if not defined JAVA_OPTIONS goto no_prior_java_options
if  "%IGNORE_DUPLICATE_SEARCH%" == "true" (
  set JAVA_OPTIONS=%JAVA_OPTIONS% %JAVA_LOCAL_OPTIONS%
  goto after_java_options
)

call set result=%%JAVA_OPTIONS:%JAVA_LOCAL_OPTIONS%=%%

@REM The lines below remove any double quote and/or | from the string before used in the comparison 
set result=%result:|=%
set result=%result:>=%
set result=%result:<=%
set result=%result:"=%

@REM The lines below first uses temporary variable and then remove any double quote and/or | from the temporary string before 
@REM used in the comparison 
set TEMP_JAVA_OPTIONS=%JAVA_OPTIONS%
set TEMP_JAVA_OPTIONS=%TEMP_JAVA_OPTIONS:|=%
set TEMP_JAVA_OPTIONS=%TEMP_JAVA_OPTIONS:<=%
set TEMP_JAVA_OPTIONS=%TEMP_JAVA_OPTIONS:>=%
set TEMP_JAVA_OPTIONS=%TEMP_JAVA_OPTIONS:"=%

if "%result%"=="%TEMP_JAVA_OPTIONS%" (
  set JAVA_LOCAL_OPTIONS_EXIST=FALSE
) else (
  set JAVA_LOCAL_OPTIONS_EXIST=TRUE
)
if "%JAVA_LOCAL_OPTIONS_EXIST%"=="FALSE"  set JAVA_OPTIONS=%JAVA_OPTIONS% %JAVA_LOCAL_OPTIONS%
goto after_java_options
:no_prior_java_options
set JAVA_OPTIONS=%JAVA_LOCAL_OPTIONS%

:after_java_options

if DEFINED USER_MEM_ARGS (
   set MEM_ARGS=%USER_MEM_ARGS%
   set UTILS_MEM_ARGS=%USER_MEM_ARGS%
)

SET FMWCONFIG_CLASSPATH=%JAVA_HOME%\lib\tools.jar
SET CHECK_FEDERATED_OH=
IF EXIST %MW_HOME%\oracle_common\modules\features\wlst.cam.classpath.jar (
 @rem This is for CAM Standalone, ODI Standalone Hybrid
 SET FMWCONFIG_CLASSPATH=%FMWCONFIG_CLASSPATH%;%MW_HOME%\oracle_common\modules\features\wlst.cam.classpath.jar
) ELSE (
 IF EXIST %MW_HOME%\oracle_common\modules\features\cieCfg_cam_lib.jar (
  @rem This is for Enterprise CAM
  SET FMWCONFIG_CLASSPATH=%FMWCONFIG_CLASSPATH%;%MW_HOME%\oracle_common\modules\features\cieCfg_cam_lib.jar
 ) ELSE (
  SET CHECK_FEDERATED_OH=true
 )
)

SET CONFIG_WLS_PATH=
SET CAM_ORACLE_HOME=
FOR %%i IN ("%MW_HOME%\..") DO SET MW_HOME_PARENT=%%~fsi
IF DEFINED CHECK_FEDERATED_OH FOR /D %%G IN (%MW_HOME_PARENT%\*) DO (
  IF EXIST %%G\oracle_common\modules\features\cieCfg_cam_lib.jar (
    IF EXIST %%G\inventory\federated (
      FOR %%H IN (%MW_HOME%\oracle_common\modules\com.oracle.cie.config-wls_*.jar) DO (
        SET CONFIG_WLS_PATH=%%H	
        SET CAM_ORACLE_HOME=%%G	
        GOTO :MODULE_SEARCH_BREAK	
      )	  
    )  
  )
)
:MODULE_SEARCH_BREAK
IF DEFINED CONFIG_WLS_PATH CALL :StripConfigWlsPath %CONFIG_WLS_PATH%
IF DEFINED CONFIG_WLS_PATH SET VERSION_WITH_JAR_EXT=%CONFIG_WLS_PATH:*config-wls_=%
IF DEFINED CAM_ORACLE_HOME CALL :StripCamOracleHome %CAM_ORACLE_HOME%

IF DEFINED CAM_ORACLE_HOME (
 IF EXIST %CAM_ORACLE_HOME%\oracle_common\modules\com.oracle.cie.config-cam_%VERSION_WITH_JAR_EXT%  (
   SET FMWCONFIG_CLASSPATH=%FMWCONFIG_CLASSPATH%;%CAM_ORACLE_HOME%\oracle_common\modules\features\cieCfg_cam_lib.jar
 )
)

IF EXIST %WL_HOME%\modules\features\wlst.wls.classpath.jar (
  @rem This is for ODI Standalone Hybrid, Full WLS, Enterprise CAM
  SET FMWCONFIG_CLASSPATH=%FMWCONFIG_CLASSPATH%;%WL_HOME%\modules\features\wlst.wls.classpath.jar
)


@rem setup bootstrap options
set SYSTEM_LOADER=SystemClassLoader
set LAUNCH_COMPLETE=weblogic.store.internal.LockManagerImpl
set PCL_JAR=%WL_HOME%\server\lib\pcl2.jar


IF NOT EXIST "%JRE_HOME%" goto cont_path

set WL_USE_X86DLL=false
set WL_USE_IA64DLL=false
set WL_USE_AMD64DLL=false
IF EXIST %JRE_HOME%\lib\i386  goto i386_path
IF EXIST %JRE_HOME%\lib\ia64  goto ia64_path
IF EXIST %JRE_HOME%\lib\amd64 goto amd64_path
goto cont_path

:i386_path
set SERVER_NATIVE_PATH=server\native\win\32
set SERVER_OCI_PATH=server\native\win\32\oci920_8
set LOCAL_PATH=%PATCH_PATH%;%WL_HOME%\%SERVER_NATIVE_PATH%;%WL_HOME%\server\bin;%ANT_HOME%\bin;%JRE_HOME%\bin;%JAVA_HOME%\bin;%WL_HOME%\%SERVER_OCI_PATH%
set WL_USE_X86DLL=true
goto cont_path

:ia64_path
set SERVER_NATIVE_PATH=server\native\win\64
set SERVER_OCI_PATH=server\native\win\64\oci920_8
set LOCAL_PATH=%PATCH_PATH%;%WL_HOME%\%SERVER_NATIVE_PATH%;%WL_HOME%\server\bin;%ANT_HOME%\bin;%JRE_HOME%\bin;%JAVA_HOME%\bin;%WL_HOME%\%SERVER_OCI_PATH%
set WL_USE_IA64DLL=true
goto cont_path

:amd64_path
set SERVER_NATIVE_PATH=server\native\win\x64
set SERVER_OCI_PATH=server\native\win\x64\oci920_8
set LOCAL_PATH=%PATCH_PATH%;%WL_HOME%\%SERVER_NATIVE_PATH%;%WL_HOME%\server\bin;%ANT_HOME%\bin;%JRE_HOME%\bin;%JAVA_HOME%\bin;%WL_HOME%\%SERVER_OCI_PATH%
set WL_USE_AMD64DLL=true

:cont_path
if not defined SERVER_NATIVE_PATH goto after_path
if not defined UNSHORTENED_PATH goto no_prior_path
if  "%IGNORE_DUPLICATE_SEARCH%" == "true" (
  set PATH=%LOCAL_PATH%;%PATH%
  goto after_path
)

call set path_result=%%UNSHORTENED_PATH:%SERVER_NATIVE_PATH%=%%
if "%path_result%"=="%UNSHORTENED_PATH%" (
  set LOCAL_PATH_EXIST=FALSE
) else (
  set LOCAL_PATH_EXIST=TRUE
)
if "%LOCAL_PATH_EXIST%"=="FALSE" set PATH=%LOCAL_PATH%;%PATH%
goto after_path

:no_prior_path
set PATH=%LOCAL_PATH%

:after_path

@rem set up DERBY configuration
set DERBY_HOME=%WL_HOME%\common\derby
set DERBY_SYSTEM_HOME=%DOMAIN_HOME%\common\db
set DERBY_OPTS="-Dderby.system.home=%DERBY_SYSTEM_HOME%"
goto end

:StripConfigWlsPath
SET CONFIG_WLS_PATH=%1
goto end
 
:StripCamOracleHome
SET CAM_ORACLE_HOME=%1

:end
