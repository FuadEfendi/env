
# WebLogic Job Scheduler Data Store DDL for DB2
# Copyright (c) 2005,2014, Oracle and/or its affiliates. All rights reserved.

DROP TABLE WEBLOGIC_TIMERS;

CREATE TABLE WEBLOGIC_TIMERS (
  TIMER_ID VARCHAR(100) NOT NULL,
  LISTENER BLOB(32M) NOT NULL,
  START_TIME BIGINT NOT NULL,
  INTERVAL BIGINT NOT NULL,
  TIMER_MANAGER_NAME VARCHAR(500) NOT NULL,
  DOMAIN_NAME VARCHAR(100) NOT NULL,
  CLUSTER_NAME VARCHAR(100) NOT NULL,
  USER_KEY VARCHAR(1000),
  PK INT NOT NULL GENERATED ALWAYS AS IDENTITY,
  IDX INT GENERATED ALWAYS AS (CASE WHEN USER_KEY IS NULL THEN PK ELSE NULL END),
  PRIMARY KEY (TIMER_ID, CLUSTER_NAME, DOMAIN_NAME)
); 

CREATE UNIQUE INDEX WEBLOGIC_TIMERS_IDX 
  ON WEBLOGIC_TIMERS (USER_KEY, IDX);
