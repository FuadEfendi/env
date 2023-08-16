-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--
-- crelstbs.sql - create leasing tables
-- 
-- NOTES
--    Any changes made to this script should be replicated to the same file
--    under the oracle_ebr folder for creating the EBR-enabled schema tables.
--

SET VERIFY OFF


REM Create weblogic services tables for cluster leasing feature

SET SERVEROUTPUT ON;

DECLARE
    CNT           NUMBER;
    vcurrSchema VARCHAR2(256);
BEGIN

  SELECT sys_context( 'userenv', 'current_schema' ) into vcurrSchema from dual;
  dbms_output.put_line('Current Schema: '||vcurrSchema);

  CNT := 0;
  SELECT COUNT(*) INTO CNT FROM USER_TABLES WHERE TABLE_NAME = 'ACTIVE';

  IF (CNT > 0) THEN
    EXECUTE IMMEDIATE 'drop table ACTIVE';
  END IF;

END;
/

CREATE TABLE &&1..ACTIVE (
  SERVER VARCHAR2(255) NOT NULL,
  INSTANCE VARCHAR2(255) NOT NULL,
  DOMAINNAME VARCHAR2(255) NOT NULL,
  CLUSTERNAME VARCHAR2(255) NOT NULL,
  TIMEOUT DATE,
  PRIMARY KEY (SERVER, DOMAINNAME, CLUSTERNAME)
);



