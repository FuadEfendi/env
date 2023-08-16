--SET SCHEMA=$1
--@

CREATE PROCEDURE executeCreateTableStatement(in createStatement varchar(2056))
BEGIN
  EXECUTE IMMEDIATE createStatement;
END
@

BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);

  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE
        TABSCHEMA = schemaName AND TABNAME = 'JOBINSTANCEDATA') = 0
        THEN
            SET sqlvar = 'CREATE TABLE JOBINSTANCEDATA(
              jobinstanceid BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1) CONSTRAINT JOBINSTANCE_PK PRIMARY KEY,
              name		VARCHAR(512),
              apptag VARCHAR(512)
            )';
            call executeCreateTableStatement(sqlvar);
     END IF;
 END
 @

BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);

  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE
        TABSCHEMA = schemaName AND TABNAME = 'EXECUTIONINSTANCEDATA') = 0
        THEN
            SET sqlvar = 'CREATE TABLE EXECUTIONINSTANCEDATA(
                jobexecid BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1) CONSTRAINT JOBEXECUTION_PK PRIMARY KEY,
                jobinstanceid BIGINT,
                createtime	TIMESTAMP,
                starttime		TIMESTAMP,
                endtime		TIMESTAMP,
                updatetime	TIMESTAMP,
                parameters	BLOB,
                batchstatus		VARCHAR(512),
                exitstatus		VARCHAR(512),
                CONSTRAINT JOBINST_JOBEXEC_FK FOREIGN KEY (jobinstanceid) REFERENCES JOBINSTANCEDATA (jobinstanceid)
            )';
            call executeCreateTableStatement(sqlvar);
    END IF;
END
@
  
BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);

  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE
        TABSCHEMA = schemaName AND TABNAME = 'STEPEXECUTIONINSTANCEDATA') = 0
        THEN
            SET sqlvar = 'CREATE TABLE STEPEXECUTIONINSTANCEDATA(
                stepexecid BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1) CONSTRAINT STEPEXECUTION_PK PRIMARY KEY,
                jobexecid	BIGINT,
                batchstatus         VARCHAR(512),
                exitstatus			VARCHAR(512),
                stepname			VARCHAR(512),
                readcount			INTEGER,
                writecount			INTEGER,
                commitcount         INTEGER,
                rollbackcount		INTEGER,
                readskipcount		INTEGER,
                processskipcount	INTEGER,
                filtercount			INTEGER,
                writeskipcount		INTEGER,
                startTime           TIMESTAMP,
                endTime             TIMESTAMP,
                persistentData		BLOB,
                CONSTRAINT JOBEXEC_STEPEXEC_FK FOREIGN KEY (jobexecid) REFERENCES EXECUTIONINSTANCEDATA (jobexecid)
            )';
            call executeCreateTableStatement(sqlvar);
    END IF;
END
@

BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);

  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE
        TABSCHEMA = schemaName AND TABNAME = 'JOBSTATUS') = 0
        THEN
            SET sqlvar = 'CREATE TABLE JOBSTATUS (
              id BIGINT NOT NULL CONSTRAINT JOBSTATUS_PK PRIMARY KEY,
              obj		BLOB,
              CONSTRAINT JOBSTATUS_JOBINST_FK FOREIGN KEY (id) REFERENCES JOBINSTANCEDATA (jobinstanceid) ON DELETE CASCADE
            )';
            call executeCreateTableStatement(sqlvar);
    END IF;
END
@

BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);

  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE
        TABSCHEMA = schemaName AND TABNAME = 'STEPSTATUS') = 0
        THEN
            SET sqlvar = 'CREATE TABLE STEPSTATUS (
              id BIGINT NOT NULL CONSTRAINT STEPSTATUS_PK PRIMARY KEY,
              obj		BLOB,
              CONSTRAINT STEPSTATUS_STEPEXEC_FK FOREIGN KEY (id) REFERENCES STEPEXECUTIONINSTANCEDATA (stepexecid) ON DELETE CASCADE
            )';
            call executeCreateTableStatement(sqlvar);
 END IF;
END
@

BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);

  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE
        TABSCHEMA = schemaName AND TABNAME = 'CHECKPOINTDATA') = 0
        THEN
            SET sqlvar = 'CREATE TABLE CHECKPOINTDATA(
              id		VARCHAR(512),
              obj		BLOB
            )';
            call executeCreateTableStatement(sqlvar);

            SET sqlvar = 'CREATE INDEX CHK_INDEX ON CHECKPOINTDATA(id)';
            call executeCreateTableStatement(sqlvar);
  END IF;
END
@





 
  
