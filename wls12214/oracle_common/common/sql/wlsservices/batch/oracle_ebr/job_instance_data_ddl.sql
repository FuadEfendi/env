Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved.
Rem
Rem    NAME
Rem      checkpoint_data_ddl.sql - Create and/or upgrade an editioned JOBINSTANCEDATA_ view
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      Creates an internal JOBINSTANCEDATA_ table and supporting objects, then
Rem      creates an editioning view for JOBINSTANCEDATA.
Rem

SET SERVEROUTPUT ON;

DECLARE
 vCtr     Number;
 vSQL     VARCHAR2(1000); 
 vcurrSchema VARCHAR2(256);
 vEdition        VARCHAR2(256);
 changed         Number;
 TOO_MANY_TABLES EXCEPTION;
BEGIN

  SELECT sys_context( 'userenv', 'current_schema' ) into vcurrSchema from dual;
  dbms_output.put_line('Current Schema: '||vcurrSchema);

  SELECT SYS_CONTEXT('USERENV', 'CURRENT_EDITION_NAME') INTO vEdition FROM DUAL;
  dbms_output.put_line('Current edition: '|| vEdition);

  SELECT COUNT(*)  
    INTO vCtr  
    FROM user_tables  
    WHERE table_name = 'JOBINSTANCEDATA_';
 
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating JOBINSTANCEDATA_ table');
    vSQL := 'CREATE TABLE JOBINSTANCEDATA_
    (	
      jobinstanceid        NUMBER(19,0) PRIMARY KEY,
      name                 VARCHAR2(512),
      apptag               VARCHAR(512)
    )';  
   EXECUTE IMMEDIATE vSQL;   
   changed := 1;
  END IF;

  -- create the sequence if necessary
  SELECT COUNT(*) INTO vCtr FROM user_sequences
  WHERE sequence_name = 'JOBINSTANCEDATA_SEQ';
  IF vCtr = 0 THEN
    vSQL := 'CREATE SEQUENCE JOBINSTANCEDATA_SEQ';
    EXECUTE IMMEDIATE vSQL;
  END IF;

  -- create index trigger if necessary 
  SELECT COUNT(*) INTO vCtr FROM user_triggers
  WHERE table_name = 'JOBINSTANCEDATA_';
  IF vCtr = 0 THEN  
    vSQL := 'CREATE OR REPLACE TRIGGER JOBINSTANCEDATA_TRG
                 BEFORE INSERT ON JOBINSTANCEDATA_
                 FOR EACH ROW
                 BEGIN
                   SELECT JOBINSTANCEDATA_SEQ.nextval INTO :new.jobinstanceid FROM dual;
                 END;';
    EXECUTE IMMEDIATE vSQL;    
  END IF;  

  -- check if we need to update the editioning view
  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'JOBINSTANCEDATA' AND EDITION_NAME = vEdition;

  IF vCtr = 0 AND changed > 0 THEN
      vSQL := 'CREATE OR REPLACE EDITIONING VIEW JOBINSTANCEDATA AS SELECT
         jobinstanceid,
         name,
         apptag
      FROM JOBINSTANCEDATA_';
      EXECUTE IMMEDIATE vSQL;   
  ELSE
      dbms_output.put_line('JOBINSTANCEDATA View not modified, editioning view not updated ' || vEdition);
  END IF;


    
END;
/
