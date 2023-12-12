import sys
from java.lang import System
import getopt

def printUsage():
  print ' '
  print 'This online (connected mode) WLST script is for creating JMS resources required for WLS WS SOAP/JMS feature in the MT mode.'
  print 'Domain partition and a resource group within it need to exist before this script can be used.'
  print 'You will need to create userConfigFile and userKeyFile before using this script. Refer to WLST storeUserConfig command.'
  print '-----'
  print 'Usage'
  print '-----'
  print '<JAVA_HOME>/bin/java -classpath <weblogic.jar_location> weblogic.WLST ./wlsws-soapjms-mt-config.py --myUserConfigFile <userConfigFile> --myUserKeyFile <userKeyFile> --myURL <AdminServer_t3_url> --partitionName <partitionName> --rgName <resourceGroupName> --isCluster <true_or_false>'
  print ' '

try:
  options,remainder = getopt.getopt(sys.argv[1:],'', ['help','myUserConfigFile=', 'myUserKeyFile=', 'myURL=', 'partitionName=', 'rgName=', 'isCluster='])
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

print ' '
print 'myUserConfigFile: ',myUserConfigFile
print 'myUserKeyFile: ',myUserKeyFile
print 'myURL: ',myURL
print 'partitionName: ',partitionName
print 'rgName: ',rgName
print 'isCluster: ',isCluster
print ' '

fileStore = "WlsWsSoapJmsFileStore_" + partitionName
jmsServer = "WlsWsSoapJmsServer_" + partitionName
jmsSystemResource = "WlsWsSoapJmsModule_" + partitionName
jmsSubDeployment = "WlsWsSoapJmsSubDeployment_" + partitionName

connectionFactory = "com.oracle.webservices.api.jms.ConnectionFactory"
errorQueue = "com.oracle.webservices.api.jms.ErrorQueue"
requestQueue = "com.oracle.webservices.api.jms.RequestQueue"
responseQueue = "com.oracle.webservices.api.jms.ResponseQueue"

print "Connecting to AdminSever"

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
  else:
    print "[WARNING] FileStore by name " + fileStore +" already exists"
  if isCluster == "true":
    print "Setting DistributionPolicy as Distributed on file store: " + fileStore
    fsBean.setDistributionPolicy("Distributed")
  else:
    print "Setting DistributionPolicy as Singleton on file store: " + fileStore
    fsBean.setDistributionPolicy("Singleton")
    print "Setting MigrationPolicy as Always on file store: " + fileStore
    fsBean.setMigrationPolicy("Always")
  fsBean.setDirectory(fileStore) 

  jsBean = rgBean.lookupJMSServer(jmsServer)
  if jsBean == None:
    jsBean = rgBean.createJMSServer(jmsServer)
  else:
    print "[WARNING] JMSServer by name " + jmsServer + " already exists"
  jsBean.setPersistentStore(fsBean)

  jmsRBean = rgBean.lookupJMSSystemResource(jmsSystemResource)
  if jmsRBean == None:
    jmsRBean = rgBean.createJMSSystemResource(jmsSystemResource)
  else:
    print "[WARNING] JMSSystemResource by name " + jmsSystemResource + " already exists"
    
  subdBean = jmsRBean.lookupSubDeployment(jmsSubDeployment)
  if subdBean == None:
    subdBean = jmsRBean.createSubDeployment(jmsSubDeployment)
  else:
     print "[WARNING] SubDeployment by name " + jmsSubDeployment + " already exists"  
  subdBean.addTarget(jsBean)

  jmsResource = jmsRBean.getJMSResource()
  cfBean = jmsResource.lookupConnectionFactory(connectionFactory)
  if cfBean == None:
    cfBean = jmsResource.createConnectionFactory(connectionFactory)
  else:
    print "[WARNING] ConnectionFactory by name " + connectionFactory + " already exists"
  cfBean.setJNDIName(connectionFactory)
  cfBean.setSubDeploymentName(jmsSubDeployment)
  txp = cfBean.getTransactionParams()
  txp.setXAConnectionFactoryEnabled(true)

  dBean = None
  if isCluster == "true":
    dBean = jmsResource.lookupUniformDistributedQueue(errorQueue)
  else:
    dBean = jmsResource.lookupQueue(errorQueue)
  if dBean == None:
    if isCluster == "true":
      dBean = jmsResource.createUniformDistributedQueue(errorQueue)
      print "Created UDD: "+errorQueue
    else:
      dBean = jmsResource.createQueue(errorQueue)
      print "Created regular destination: " + errorQueue
  else:
    print "[WARNING] Error queue by name " + errorQueue + " already exists"  
  dBean.setJNDIName(errorQueue)
  dBean.setSubDeploymentName(jmsSubDeployment)
 
  dBean = None
  if isCluster == "true":
    dBean = jmsResource.lookupUniformDistributedQueue(requestQueue)
  else:
    dBean = jmsResource.lookupQueue(requestQueue)
  if dBean == None:
    if isCluster == "true":
      dBean = jmsResource.createUniformDistributedQueue(requestQueue)
      print "Created UDD: "+requestQueue
    else:
      dBean = jmsResource.createQueue(requestQueue)
      print "Created regular destination: " + requestQueue
  else:
    print "[WARNING] Request queue by name " + requestQueue + " already exists"
  dBean.setJNDIName(requestQueue)
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
  dBean.setJNDIName(responseQueue)
  dBean.setSubDeploymentName(jmsSubDeployment)

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
