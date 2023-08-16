Rem
Rem Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      create_user.sql - Create user for EBR-enabled WebLogic Services
Rem                        Repository
Rem
Rem    DESCRIPTION
Rem      The file is used to create EBR-enabled schema user for WebLogic 
Rem      Services Repository.  To be used only by RCU.
Rem
Rem    NOTES
Rem      The first 4 parameters are passed to the general create_user.sql for 
Rem      creating the user on Oracle database. The fifth and sixth parameters
Rem      are additional runtime schema user and password. The seventh parameter 
Rem      is the edition name which must already exist in the database.
Rem      Enables the edition after creating the schema user. 
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

@@../sql/create_user.sql &&1 &&2 &&3 &&4 &&5 &&6

ALTER USER &&1 ENABLE EDITIONS;
GRANT USE ON EDITION &&7 TO &&1;
GRANT CREATE VIEW to &&1;

ALTER USER &&5 ENABLE EDITIONS;
GRANT USE ON EDITION &&7 TO &&5;
GRANT CREATE VIEW to &&5; 

EXIT;
