import sys
from java.lang import System
import getopt

def printUsage():
  print ' '
  print 'This online (connected mode) WLST script is for creating resources required for WLS JAX-WS advanced features in the MT mode.'
  print 'Domain partition and a resource group within it need to exist before this script can be used.'
  print 'You will need to create userConfigFile and userKeyFile before using this script. Refer to WLST storeUserConfig command.'
  print '-----'
  print 'Usage'
  print '-----'
  print '<JAVA_HOME>/bin/java -classpath <weblogic.jar_location> weblogic.WLST ./wlsws-advanced-jaxws-mt-config.py --myUserConfigFile <userConfigFile> --myUserKeyFile <userKeyFile> --myURL <AdminServer_t3_url> --partitionName <partitionName> --rgName <resourceGroupName> --isCluster <true_or_false> --middlewareHome <middlewareHomeDir>'
  print ' '

try:
  options,remainder = getopt.getopt(sys.argv[1:],'', ['help', 'myUserConfigFile=', 'myUserKeyFile=', 'myURL=', 'partitionName=', 'rgName=', 'isCluster=', 'middlewareHome='])
except getopt.error, msg:
  printUsage()
  sys.exit(2)

for opt, arg in options:
  if opt == '--help':
    printUsage()
    sys.exit()
  elif opt == '--myUserConfigFile':
    myUserConfigFile = arg
  elif opt == '--myUserKeyFile':
    myUserKeyFile = arg
  elif opt == '--myURL':
    myURL = arg
  elif opt == '--partitionName':
    partitionName = arg
  elif opt == '--rgName':
    rgName = arg
  elif opt == '--isCluster':
    isCluster = arg
  elif opt == '--middlewareHome':
    middlewareHome = arg

if myUserConfigFile.isspace():
 print "Error: myUserConfigFile argument not found."
 printUsage()
 sys.exit(2)

if myUserKeyFile.isspace():
 print "Error: myUserKeyFile argument not found."
 printUsage()
 sys.exit(2)

if myURL.isspace():
 print "Error: myURL argument not found."
 printUsage()
 sys.exit(2)

if partitionName.isspace():
 print "Error: partitionName argument not found."
 printUsage()
 sys.exit(2)

if rgName.isspace():
 print "Error: rgName argument not found."
 printUsage()
 sys.exit(2)

if isCluster.isspace():
 print "Error: isCluster argument not found."
 printUsage()
 sys.exit(2)

if middlewareHome.isspace():
 print "Error: middlewareHome argument not found."
 printUsage()
 sys.exit(2)

print ' '
print 'myUserConfigFile: ',myUserConfigFile
print 'myUserKeyFile: ',myUserKeyFile
print 'myURL: ',myURL
print 'partitionName: ',partitionName
print 'rgName: ',rgName
print 'isCluster: ',isCluster
print 'middlewareHome: ',middlewareHome
print ' '

fileStore = "WseeJaxwsFileStore_" + partitionName
safAgent = "WseeJaxwsSAFAgent_" + partitionName
safAgentFileStore = "WseeJaxwsSafAgentFileStore_" + partitionName
jmsServer = "WseeJaxwsJmsServer_" + partitionName
jmsSystemResource = "WseeJaxwsJmsSystemResource_" + partitionName
jmsSubDeployment = "WseeJaxwsSubDeployment_" + partitionName

requestQueue = "WseeBufferedRequestQueue"
requestQueueJNDI = "weblogic.wsee.BufferedRequestQueue"
responseQueue = "WseeBufferedResponseQueue"
responseQueueJNDI = "weblogic.wsee.BufferedResponseQueue"
requestErrorQueue = "WseeBufferedRequestErrorQueue"
requestErrorQueueJNDI = "weblogic.wsee.BufferedRequestErrorQueue"
responseErrorQueue = "WseeBufferedResponseErrorQueue"
responseErrorQueueJNDI = "weblogic.wsee.BufferedResponseErrorQueue"
wseeStoreName = "WseeStore"
workManagerName = "weblogic.wsee.jaxws.mdb.DispatchPolicy"

print "Connecting to AdminSever"

#connect(userName, passWord, myURL)
connect(userConfigFile = myUserConfigFile, userKeyFile = myUserKeyFile, url = myURL)

print "Connected to " + myURL

try: 
  edit()
  startEdit()

  pBean = cmo.lookupPartition(partitionName)
  if pBean == None:
    print "[ERROR] Cannot continue. Partition by name" + partitionName + " not found"
    stopEdit('y')
    disconnect()
    sys.exit(-1)
  else:
    print "Found partition " + pBean.getName()

  rgBean = pBean.lookupResourceGroup(rgName)
  if rgBean == None:
    print "[ERROR] Cannot continue. ResourceGroup by name " + rgName + " not found in partition " + partitionName
    stopEdit('y')
    disconnect()
    sys.exit(-1)
  else:
    print "Found ResourceGroup " + rgBean.getName()

  fsBean = rgBean.lookupFileStore(fileStore)
  if fsBean == None:
    fsBean = rgBean.createFileStore(fileStore)
    print "Created file store: "+fileStore
  else:
    print "[WARNING] FileStore by name " + fileStore +" already exists"
  if isCluster == "true":
    fsBean.setDistributionPolicy("Distributed")
    print "Set distribution policy as Distributed on file store "+fileStore
  else:
    fsBean.setDistributionPolicy("Singleton")
    print "Set distribution policy as Singleton on file store "+fileStore
    fsBean.setMigrationPolicy("Always")
    print "Set migration policy as Always on file store "+fileStore
  fsBean.setDirectory(fileStore)

  safBean = rgBean.lookupSAFAgent(safAgent)
  if safBean == None:
    saffsBean = rgBean.lookupFileStore(safAgentFileStore)
    if saffsBean == None:
      saffsBean = rgBean.createFileStore(safAgentFileStore)
      print "Created file store for SAF agent: "+safAgentFileStore
    else:
      print "[WARNING] SAF agent FileStore by name " + safAgentFileStore + " already exists"
    saffsBean.setDirectory(safAgentFileStore)
    safBean = rgBean.createSAFAgent(safAgent)
    safBean.setStore(saffsBean)
    print "Created SAF agent: "+safAgent
  else:
    print "[WARNING] SAF agent by name " + safAgent + " already exists"
  safBean.setServiceType("Both")

  jsBean = rgBean.lookupJMSServer(jmsServer)
  if jsBean == None:
    jsBean = rgBean.createJMSServer(jmsServer)
    print "Created JMS server: "+jmsServer
  else:
    print "[WARNING] JMSServer by name " + jmsServer + " already exists"
  jsBean.setPersistentStore(fsBean)

  jmsRBean = rgBean.lookupJMSSystemResource(jmsSystemResource)
  if jmsRBean == None:
    jmsRBean = rgBean.createJMSSystemResource(jmsSystemResource)
    print "Created JMS system resource: "+jmsSystemResource
  else:
    print "[WARNING] JMSSystemResource by name " + jmsSystemResource + " already exists"

  subdBean = jmsRBean.lookupSubDeployment(jmsSubDeployment)
  if subdBean == None:
    subdBean = jmsRBean.createSubDeployment(jmsSubDeployment)
    print "Created JMS sub deployment: "+jmsSubDeployment
  else:
     print "[WARNING] SubDeployment by name " + jmsSubDeployment + " already exists"
  subdBean.addTarget(jsBean)

  jmsResource = jmsRBean.getJMSResource()

  dBean = None
  if isCluster == "true":
    dBean = jmsResource.lookupUniformDistributedQueue(requestQueue)
  else:
     dBean = jmsResource.lookupQueue(requestQueue)
  if dBean == None:
    if isCluster=="true":
      dBean = jmsResource.createUniformDistributedQueue(requestQueue)
      print "Created UDD: "+requestQueue
    else:
      dBean = jmsResource.createQueue(requestQueue)
      print "Created regular destination: "+requestQueue
  else:
    print "[WARNING] Request queue by name " + requestQueue + " already exists"
  dBean.setJNDIName(requestQueueJNDI)
  dBean.setSubDeploymentName(jmsSubDeployment)

  dBean = None
  if isCluster == "true":
    dBean = jmsResource.lookupUniformDistributedQueue(requestErrorQueue)
  else:
    dBean = jmsResource.lookupQueue(requestErrorQueue)
  if dBean == None:
    if isCluster == "true":
      dBean = jmsResource.createUniformDistributedQueue(requestErrorQueue)
      print "Created UDD: "+requestErrorQueue
    else:
      dBean = jmsResource.createQueue(requestErrorQueue)
      print "Created regular destination: "+requestErrorQueue
  else:
    print "[WARNING] Request error queue by name " + requestErrorQueue + " already exists"
  dBean.setJNDIName(requestErrorQueueJNDI)
  dBean.setSubDeploymentName(jmsSubDeployment)

  dBean = None
  if isCluster == "true":
    dBean = jmsResource.lookupUniformDistributedQueue(responseQueue)
  else:
    dBean = jmsResource.lookupQueue(responseQueue)
  if dBean == None:
    if isCluster == "true":
      dBean = jmsResource.createUniformDistributedQueue(responseQueue)
      print "Created UDD: "+responseQueue
    else:
      dBean = jmsResource.createQueue(responseQueue)
      print "Created regular destination: "+responseQueue 
  else:
    print "[WARNING] Response queue by name " + responseQueue + " already exists"
  dBean.setJNDIName(responseQueueJNDI)
  dBean.setSubDeploymentName(jmsSubDeployment)

  dBean = None
  if isCluster=="true":
    dBean = jmsResource.lookupUniformDistributedQueue(responseErrorQueue)
  else:
    dBean = jmsResource.lookupQueue(responseErrorQueue)
  if dBean == None:
    if isCluster == "true":
      dBean = jmsResource.createUniformDistributedQueue(responseErrorQueue)
      print "Created UDD: "+responseErrorQueue
    else:
      dBean = jmsResource.createQueue(responseErrorQueue)
      print "Created regular destination: "+responseErrorQueue
  else:
    print "[WARNING] Response error queue by name " + responseErrorQueue + " already exists"
  dBean.setJNDIName(responseErrorQueueJNDI)
  dBean.setSubDeploymentName(jmsSubDeployment)

  # Add wsee logical store
  wsBean = pBean.getWebService()
  wspBean = wsBean.getWebServicePersistence()
  wslsBean = wspBean.createWebServiceLogicalStore(wseeStoreName)
  wslsBean.setRequestBufferingQueueJndiName(requestQueueJNDI)
  wslsBean.setResponseBufferingQueueJndiName(responseQueueJNDI)

  # Create and configure WorkManager
  cd ('/Partitions/' + partitionName + '/SelfTuning/' + partitionName)
  maxThreads = cmo.createMaxThreadsConstraint('WseeMaxThreadsPartition')
  maxThreads.setCount(100)
  minThreads = cmo.createMinThreadsConstraint('WseeMinThreadsPartition')
  minThreads.setCount(40)
  capacity = cmo.createCapacity('WseeCapacityPartition')
  capacity.setCount(200)
  wseeWm = cmo.createWorkManager(workManagerName)
  cd('WorkManagers/'+workManagerName)
  wseeWm.setMaxThreadsConstraint(maxThreads)
  wseeWm.setMinThreadsConstraint(minThreads)
  wseeWm.setCapacity(capacity)

  # Deploy state management RAR application if valid middlewareHome is found
  appName = "state-management-provider-memory-rar"
  if middlewareHome != None:
    sourcePath = middlewareHome + "/oracle_common/modules/com.oracle.state-management.state-management-provider-memory-rar-impl.rar"
    print "RAR application sourcePath resolved to: " + sourcePath
    if os.path.isfile(sourcePath):
      deploy(appName=appName, partition=partitionName, resourceGroup=rgName, path=sourcePath)
      print "Deployed: "+appName
    else:
      print "Application RAR file not found. Make sure supplied middlewareHome is correct. Could not deploy " + appName
  else:
    print "middlewareHome not found. Could not deploy " + appName

  save()
  activate()
  print "Script completed successfully"
  disconnect('true')
  exit()
except:
  print "Script did not complete successfully"
  dumpStack()
  stopEdit('y')
  disconnect('true')
  sys.exit(-1)
