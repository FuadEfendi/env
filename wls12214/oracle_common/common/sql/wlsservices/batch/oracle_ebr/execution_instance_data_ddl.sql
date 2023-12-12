Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved.
Rem
Rem    NAME
Rem      checkpoint_data_ddl.sql - Create and/or upgrade an editioned EXECUTIONINSTANCEDATA_ view
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      Creates an internal EXECUTIONINSTANCEDATA_ table and supporting objects, then
Rem      creates an editioning view for EXECUTIONINSTANCEDATA.
Rem

SET SERVEROUTPUT ON;

DECLARE
 vCtr     Number;
 vSQL     VARCHAR2(2000); 
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
    WHERE table_name = 'EXECUTIONINSTANCEDATA_';
 
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating EXECUTIONINSTANCEDATA_ table');
    vSQL := 'CREATE TABLE EXECUTIONINSTANCEDATA_
    (	
         jobexecid                     NUMBER(19,0) PRIMARY KEY,
         jobinstanceid                 NUMBER(19,0),
         createtime                    TIMESTAMP,
         starttime                     TIMESTAMP,
         endtime                       TIMESTAMP,
         updatetime                    TIMESTAMP,
         parameters                    BLOB,
         batchstatus                   VARCHAR2(512),
         exitstatus                    VARCHAR2(512),
         CONSTRAINT JOBINST_JOBEXEC_FK FOREIGN KEY (jobinstanceid) REFERENCES JOBINSTANCEDATA_ (jobinstanceid)
    )';  
   EXECUTE IMMEDIATE vSQL;   
   changed := 1;
  END IF;

  -- create the sequence if necessary
  SELECT COUNT(*) INTO vCtr FROM user_sequences
  WHERE sequence_name = 'EXECUTIONINSTANCEDATA_SEQ';
  IF vCtr = 0 THEN
    vSQL := 'CREATE SEQUENCE EXECUTIONINSTANCEDATA_SEQ';
    EXECUTE IMMEDIATE vSQL;
  END IF;

  -- create index trigger if necessary 
  SELECT COUNT(*) INTO vCtr FROM user_triggers
  WHERE table_name = 'EXECUTIONINSTANCEDATA_';
  IF vCtr = 0 THEN  
    vSQL := 'CREATE OR REPLACE TRIGGER EXECUTIONINSTANCEDATA_TRG
                 BEFORE INSERT ON EXECUTIONINSTANCEDATA_
                 FOR EACH ROW
                 BEGIN
                   SELECT EXECUTIONINSTANCEDATA_SEQ.nextval INTO :new.jobexecid FROM dual;
                 END;';
    EXECUTE IMMEDIATE vSQL;    
  END IF;  
    
  -- check if we need to update the editioning view
  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'EXECUTIONINSTANCEDATA' AND EDITION_NAME = vEdition;

  IF vCtr = 0 AND changed > 0 THEN
      vSQL := 'CREATE OR REPLACE EDITIONING VIEW EXECUTIONINSTANCEDATA AS SELECT
         jobexecid,
         jobinstanceid,
         createtime,
         starttime,
         endtime,
         updatetime,
         parameters,
         batchstatus,
         exitstatus
      FROM EXECUTIONINSTANCEDATA_';
      EXECUTE IMMEDIATE vSQL;   
  ELSE
      dbms_output.put_line('EXECUTIONINSTANCEDATA View not modified, editioning view not updated ' || vEdition);
  END IF;


END;
/
