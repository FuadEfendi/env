Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved.
Rem
Rem    NAME
Rem      checkpoint_data_ddl.sql - Create and/or upgrade an editioned JOBSTATUS view
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      Creates an internal JOBSTATUS table and supporting objects, then
Rem      creates an editioning view for JOBSTATUS.
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
    WHERE table_name = 'JOBSTATUS_';
 
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating JOBSTATUS_ table');
    vSQL := 'CREATE TABLE JOBSTATUS_
    (	
         id            NUMBER(19,0) PRIMARY KEY,
         obj           BLOB,
         CONSTRAINT JOBSTATUS_JOBINST_FK FOREIGN KEY (id) REFERENCES JOBINSTANCEDATA_ (jobinstanceid) ON DELETE CASCADE
    )';  
   EXECUTE IMMEDIATE vSQL;   
   changed := 1;
  END IF;

  -- check if we need to update the editioning view
  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'JOBSTATUS' AND EDITION_NAME = vEdition;

  IF vCtr = 0 AND changed > 0 THEN
      vSQL := 'CREATE OR REPLACE EDITIONING VIEW JOBSTATUS AS SELECT
         id,
         obj
      FROM JOBSTATUS_';
      EXECUTE IMMEDIATE vSQL;   
  ELSE
      dbms_output.put_line('JOBSTATUS View not modified, editioning view not updated ' || vEdition);
  END IF;


    
END;
/
