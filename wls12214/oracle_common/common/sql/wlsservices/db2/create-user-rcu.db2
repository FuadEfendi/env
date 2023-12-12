--
--
-- create-user-rcu.db2
--
-- Copyright (c) 2012,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--    NAME
--     create-user-rcu.db2 - Create schema for Weblogic Services user on DB2. 
--
--    DESCRIPTION
--    This file creates db schema for Weblogic Services on IBM db2. To
--    be used only by RCU.
--

-- Assign schema name which is passed in as $1 to SCHEMA_USER
CREATE SCHEMA $1 AUTHORIZATION $3@
GRANT USE OF TABLESPACE $2 TO USER $3@
TRANSFER OWNERSHIP OF TABLESPACE $2 TO USER $3 PRESERVE PRIVILEGES@
GRANT DBADM ON DATABASE TO USER $3@

-- Create additional schema which is passed in as $4
CREATE SCHEMA $4 AUTHORIZATION $3@
GRANT USE OF TABLESPACE $2 TO USER $4@
GRANT DBADM ON DATABASE TO USER $4@
