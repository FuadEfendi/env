-- Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
--
--
-- jsr352-mysql.sql - Create tables for JSR 352 JobRepository tables for MySQL
-- 

-- Note ';' has to be applied to the next line in define statement.

DROP PROCEDURE if exists create_jsr352_tables
/

CREATE PROCEDURE create_jsr352_tables()
language sql
BEGIN
    CREATE TABLE IF NOT EXISTS JOBINSTANCEDATA(
      jobinstanceid   BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
      name    VARCHAR(512), 
      apptag VARCHAR(512)
    );
    
    CREATE TABLE IF NOT EXISTS EXECUTIONINSTANCEDATA(
      jobexecid     BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
      jobinstanceid BIGINT,
      createtime  TIMESTAMP,
      starttime   TIMESTAMP,
      endtime   TIMESTAMP,
      updatetime  TIMESTAMP,
      parameters  BLOB,
      batchstatus   VARCHAR(512),
      exitstatus    VARCHAR(512),
      CONSTRAINT JOBINST_JOBEXEC_FK FOREIGN KEY (jobinstanceid) REFERENCES JOBINSTANCEDATA (jobinstanceid)
    );
      
    CREATE TABLE IF NOT EXISTS STEPEXECUTIONINSTANCEDATA(
      stepexecid    BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
      jobexecid BIGINT,
      batchstatus       VARCHAR(512),
      exitstatus      VARCHAR(512),
      stepname        VARCHAR(512),
      readcount         INT,
      writecount        INT,
      commitcount       INT,
      rollbackcount     INT,
      readskipcount     INT,
      processskipcount  INT,
      filtercount       INT,
      writeskipcount    INT,
      startTime           TIMESTAMP,
      endTime             TIMESTAMP,
      persistentData    BLOB,
      CONSTRAINT JOBEXEC_STEPEXEC_FK FOREIGN KEY (jobexecid) REFERENCES EXECUTIONINSTANCEDATA (jobexecid)
    );  
    
    CREATE TABLE IF NOT EXISTS JOBSTATUS (
      id		BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
      obj   BLOB,
      CONSTRAINT JOBSTATUS_JOBINST_FK FOREIGN KEY (id) REFERENCES JOBINSTANCEDATA (jobinstanceid) ON DELETE CASCADE
    );
    
    CREATE TABLE IF NOT EXISTS STEPSTATUS(
      id		BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
      obj   BLOB,
      CONSTRAINT STEPSTATUS_STEPEXEC_FK FOREIGN KEY (id) REFERENCES STEPEXECUTIONINSTANCEDATA (stepexecid) ON DELETE CASCADE
    );
    
    CREATE TABLE IF NOT EXISTS CHECKPOINTDATA(
      id		VARCHAR(512),
      obj		BLOB
    );
    
END
/

CALL create_jsr352_tables()
/

DROP PROCEDURE if exists create_jsr352_tables
/

