-- Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
--
--
-- crewlstbs.sql - Create tables for Weblogic core services for MySQL
-- 

-- Note ';' has to be applied to the next line in define statement.

DROP PROCEDURE if exists create_alter_wls_core_tables
/

CREATE PROCEDURE create_alter_wls_core_tables()
language sql
BEGIN

  CREATE TABLE IF NOT EXISTS WEBLOGIC_TIMERS 
  (
    TIMER_ID VARCHAR(100) NOT NULL,
    LISTENER LONGBLOB NOT NULL,
    START_TIME BIGINT NOT NULL,
    SCHEDULE_INTERVAL BIGINT NOT NULL,
    TIMER_MANAGER_NAME VARCHAR(500) NOT NULL,
    DOMAIN_NAME VARCHAR(100) NOT NULL,
    CLUSTER_NAME VARCHAR(100) NOT NULL,
    USER_KEY VARCHAR(191) UNIQUE,
    PRIMARY KEY (TIMER_ID, CLUSTER_NAME, DOMAIN_NAME)
  );

  -- Check for USER_KEY column and add if necessary (since 12.1.3)
  IF NOT EXISTS(
    SELECT * FROM `information_schema`.`COLUMNS`
      WHERE COLUMN_NAME='USER_KEY' AND TABLE_NAME='WEBLOGIC_TIMERS') THEN
      ALTER TABLE `WEBLOGIC_TIMERS` ADD `USER_KEY` varchar(191) unique;
  END IF;

  -- TIMER_MANAGER_NAME column length increased in 12.2.1
  ALTER TABLE `WEBLOGIC_TIMERS` MODIFY `TIMER_MANAGER_NAME` VARCHAR(500) NOT NULL;

END
/

CALL create_alter_wls_core_tables()
/

DROP PROCEDURE if exists create_alter_wls_core_tables
/

