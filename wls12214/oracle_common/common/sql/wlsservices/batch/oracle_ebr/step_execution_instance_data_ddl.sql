Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved.
Rem
Rem    NAME
Rem      checkpoint_data_ddl.sql - Create and/or upgrade an editioned STEPEXECUTIONINSTANCEDATA_ view
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      Creates an internal STEPEXECUTIONINSTANCEDATA_ table and supporting objects, then
Rem      creates an editioning view for STEPEXECUTIONINSTANCEDATA.
Rem

SET SERVEROUTPUT ON;

DECLARE
 vCtr     Number;
 vSQL     VARCHAR2(3000); 
 vcurrSchema VARCHAR2(256);
 vEdition        VARCHAR2(256);
 changed         Number;
 TOO_MANY_TABLES EXCEPTION;
BEGIN

  SELECT sys_context( 'userenv', 'current_schema' ) into vcurrSchema from dual;
  dbms_output.put_line('Current Schema: '||vcurrSchema);

  SELECT COUNT(*)  
    INTO vCtr  
    FROM user_tables  
    WHERE table_name = 'STEPEXECUTIONINSTANCEDATA_';
 
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating STEPEXECUTIONINSTANCEDATA_ table');
    vSQL := 'CREATE TABLE STEPEXECUTIONINSTANCEDATA_
    (	
        stepexecid                      NUMBER(19,0) PRIMARY KEY,
        jobexecid                       NUMBER(19,0),
        batchstatus                     VARCHAR2(512),
        exitstatus                      VARCHAR2(512),
        stepname                        VARCHAR2(512),
        readcount                       NUMBER(11, 0),
        writecount                      NUMBER(11, 0),
        commitcount                     NUMBER(11, 0),
        rollbackcount                   NUMBER(11, 0),
        readskipcount                   NUMBER(11, 0),
        processskipcount                NUMBER(11, 0),
        filtercount                     NUMBER(11, 0),
        writeskipcount                  NUMBER(11, 0),
        startTime                       TIMESTAMP,
        endTime                         TIMESTAMP,
        persistentData                  BLOB,
        CONSTRAINT JOBEXEC_STEPEXEC_FK FOREIGN KEY (jobexecid) REFERENCES EXECUTIONINSTANCEDATA_ (jobexecid)
    )';  
   EXECUTE IMMEDIATE vSQL;   
   changed := 1;
  END IF;

  -- create the sequence if necessary
  SELECT COUNT(*) INTO vCtr FROM user_sequences
  WHERE sequence_name = 'STEPEXECUTIONINSTANCEDATA_SEQ';
  IF vCtr = 0 THEN
    vSQL := 'CREATE SEQUENCE STEPEXECUTIONINSTANCEDATA_SEQ';
    EXECUTE IMMEDIATE vSQL;
  END IF;

  -- create index trigger if necessary 
  SELECT COUNT(*) INTO vCtr FROM user_triggers
  WHERE table_name = 'STEPEXECUTIONINSTANCEDATA_';
  IF vCtr = 0 THEN  
    vSQL := 'CREATE OR REPLACE TRIGGER STEPEXECUTIONINSTANCEDATA_TRG
                 BEFORE INSERT ON STEPEXECUTIONINSTANCEDATA_
                 FOR EACH ROW
                 BEGIN
                   SELECT STEPEXECUTIONINSTANCEDATA_SEQ.nextval INTO :new.stepexecid FROM dual;
                 END;';
    EXECUTE IMMEDIATE vSQL;    
  END IF;  

  -- check if we need to update the editioning view
  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'STEPEXECUTIONINSTANCEDATA' AND EDITION_NAME = vEdition;

  IF vCtr = 0 AND changed > 0 THEN
      vSQL := 'CREATE OR REPLACE EDITIONING VIEW STEPEXECUTIONINSTANCEDATA AS SELECT
        stepexecid,
        jobexecid,
        batchstatus,
        exitstatus,
        stepname,
        readcount,
        writecount,
        commitcount,
        rollbackcount,
        readskipcount,
        processskipcount,
        filtercount,
        writeskipcount,
        startTime,
        endTime,
        persistentData
      FROM STEPEXECUTIONINSTANCEDATA_';
      EXECUTE IMMEDIATE vSQL;   
  ELSE
      dbms_output.put_line('STEPEXECUTIONINSTANCEDATA View not modified, editioning view not updated ' || vEdition);
  END IF;

END;
/
