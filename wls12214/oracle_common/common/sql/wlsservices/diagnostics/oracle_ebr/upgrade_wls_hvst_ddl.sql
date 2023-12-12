Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      upgrade_wls_hvst_ddl.sql - Upgrade a non-EBR WLS_HVST table to an editioned view
Rem
Rem    DESCRIPTION
Rem      Upgrade the WLS_HVST tables to use an EBR editioning view in the main
Rem      ORA$BASE edition.  
Rem
Rem    NOTES
Rem      If the WLS_HVST table exists, rename it to an internal WLS_HVST_ 
Rem      name, and create an editioning view for WLS_HVST.  Also re-create the
Rem      sequence trigger on the new table.
Rem

--SET ECHO OFF;
SET SERVEROUTPUT ON;

DECLARE
 vCtr            Number;
 vSQL            VARCHAR2(2048); 
 vcurrSchema     VARCHAR2(256);
 vEdition        VARCHAR2(256);
 changed         Number;
 TOO_MANY_TABLES EXCEPTION;
BEGIN

  changed := 0;
  
  SELECT sys_context( 'userenv', 'current_schema' ) into vcurrSchema from dual;
  dbms_output.put_line('Current Schema: '||vcurrSchema);

  SELECT SYS_CONTEXT('USERENV', 'CURRENT_EDITION_NAME') INTO vEdition FROM DUAL;
  dbms_output.put_line('Current edition: '|| vEdition);

  SELECT COUNT(*)
  INTO vCtr
  FROM user_tables
  WHERE table_name = 'WLS_HVST';

  IF vCtr > 1 THEN 
    RAISE TOO_MANY_TABLES;
  ELSIF vCtr > 0 THEN
    dbms_output.put_line('Renaming WLS_HVST table to WLS_HVST_');
    vSQL := 'RENAME WLS_HVST TO WLS_HVST_';
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  ELSE
    dbms_output.put_line('Table WLS_HVST does not need to be renamed');
  END IF;

  SELECT COUNT(*) 
    INTO vCtr FROM user_triggers
    WHERE table_name = 'WLS_HVST_';

  IF vCtr = 0 AND changed > 0 THEN  
    dbms_output.put_line('Creating or replacing TRG_WLS_HVST_INSERT trigger');
    vSQL := 'CREATE OR REPLACE TRIGGER TRG_WLS_HVST_INSERT 
    BEFORE INSERT ON WLS_HVST_ 
    REFERENCING NEW AS newRow 
    FOR EACH ROW 
    BEGIN 
      IF :newRow.RECORDID IS NULL THEN 
        SELECT SEQ_WLS_HVST_RECORDID.nextval INTO :newRow.RECORDID FROM DUAL; 
      END IF; 
    END;';
    EXECUTE IMMEDIATE vSQL;
  END IF;

  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'WLS_HVST' AND EDITION_NAME = vEdition;

  IF vCtr = 0 AND changed > 0 THEN  
    dbms_output.put_line('Creating WLS_HVST editioning view');

    SELECT COUNT(*)
      INTO vCtr FROM user_tab_columns
      WHERE table_name = 'WLS_HVST_' AND column_name = 'WLDFMODULE';
  
    IF vCtr = 0 THEN
      dbms_output.put_line('Using pre-12c columns');
      vSQL := 'CREATE OR REPLACE EDITIONING VIEW WLS_HVST AS SELECT
        RECORDID, 
        TIMESTAMP, 
        DOMAIN, 
        SERVER, 
        TYPE, 
        NAME, 
        ATTRNAME, 
        ATTRTYPE, 
        ATTRVALUE
        FROM WLS_HVST_';
    ELSE
      dbms_output.put_line('Using 12c schema with WLDFMODULE column');
      vSQL := 'CREATE OR REPLACE EDITIONING VIEW WLS_HVST AS SELECT
        RECORDID, 
        TIMESTAMP, 
        DOMAIN, 
        SERVER, 
        TYPE, 
        NAME, 
        ATTRNAME, 
        ATTRTYPE, 
        ATTRVALUE,
        WLDFMODULE
        FROM WLS_HVST_';
    END IF;
    EXECUTE IMMEDIATE vSQL;
    dbms_output.put_line('Compatible WLS_HVST editioning view created ');
  ELSE
    dbms_output.put_line('WLS_HVST Editioning view already exists for edition ' || vEdition);
  END IF;  
END;
/
