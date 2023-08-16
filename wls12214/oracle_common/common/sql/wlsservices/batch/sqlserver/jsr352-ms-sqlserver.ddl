DECLARE @this_schema VARCHAR(256);

BEGIN

    SET @this_schema = SCHEMA_NAME();
    PRINT 'schema name: ' + @this_schema;

    IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @this_schema
        AND  TABLE_NAME = 'JOBINSTANCEDATA'))
    BEGIN
        CREATE TABLE "JOBINSTANCEDATA" (
            "jobinstanceid"   BIGINT NOT NULL PRIMARY KEY IDENTITY,
            "name"    VARCHAR(512),
            "apptag" VARCHAR(512)
        );
    END;

    IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @this_schema
        AND  TABLE_NAME = 'EXECUTIONINSTANCEDATA'))
    BEGIN
        CREATE TABLE "EXECUTIONINSTANCEDATA"(
          "jobexecid"  BIGINT NOT NULL PRIMARY KEY IDENTITY,
          "jobinstanceid" BIGINT,
          "createtime"  DATETIME,
          "starttime"   DATETIME,
          "endtime"   DATETIME,
          "updatetime"  DATETIME,
          "parameters"  VARBINARY,
          "batchstatus"   VARCHAR(512),
          "exitstatus"    VARCHAR(512),
          CONSTRAINT JOBINST_JOBEXEC_FK FOREIGN KEY (jobinstanceid) REFERENCES JOBINSTANCEDATA (jobinstanceid)
        );
    END;

    IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @this_schema
        AND  TABLE_NAME = 'STEPEXECUTIONINSTANCEDATA'))
    BEGIN
        CREATE TABLE "STEPEXECUTIONINSTANCEDATA"(
            "stepexecid" BIGINT NOT NULL PRIMARY KEY IDENTITY,
            "jobexecid" BIGINT,
            "batchstatus"         VARCHAR(512),
            "exitstatus"      VARCHAR(512),
            "stepname"      VARCHAR(512),
            "readcount"       INTEGER,
            "writecount"      INTEGER,
            "commitcount"     INTEGER,
            "rollbackcount"   INTEGER,
            "readskipcount"   INTEGER,
            "processskipcount"  INTEGER,
            "filtercount"       INTEGER,
            "writeskipcount"    INTEGER,
            "startTime"           DATETIME,
            "endTime"             DATETIME,
            "persistentData"    VARBINARY,
            CONSTRAINT JOBEXEC_STEPEXEC_FK FOREIGN KEY (jobexecid) REFERENCES EXECUTIONINSTANCEDATA (jobexecid)
        );
    END;

    IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @this_schema
        AND  TABLE_NAME = 'JOBSTATUS'))
    BEGIN
        CREATE TABLE "JOBSTATUS" (
            "id"		BIGINT NOT NULL PRIMARY KEY,
            "obj"		VARBINARY,
            CONSTRAINT JOBSTATUS_JOBINST_FK FOREIGN KEY (id) REFERENCES JOBINSTANCEDATA (jobinstanceid) ON DELETE CASCADE
        );
    END;

    IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @this_schema
        AND  TABLE_NAME = 'STEPSTATUS'))
    BEGIN
        CREATE TABLE "STEPSTATUS"(
            "id"		BIGINT NOT NULL PRIMARY KEY,
            "obj"		VARBINARY,
            CONSTRAINT STEPSTATUS_STEPEXEC_FK FOREIGN KEY (id) REFERENCES STEPEXECUTIONINSTANCEDATA (stepexecid) ON DELETE CASCADE
        );
    END;


    IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @this_schema
        AND  TABLE_NAME = 'CHECKPOINTDATA'))
    BEGIN
          CREATE TABLE "CHECKPOINTDATA"(
            "id"		VARCHAR(512),
            "obj"		VARBINARY
        );
    END;

END;

GO


  
