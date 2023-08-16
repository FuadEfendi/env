
# WebLogic Job Scheduler Data Store DDL for MYSQL
# Copyright (c) 2005,2014, Oracle and/or its affiliates. All rights reserved.
#
# Limit on single column index is 767 bytes
# http://dev.mysql.com/doc/refman/5.5/en/innodb-restrictions.html
#
# Furthermore, the limit is 255 characters for utf8 or 191 characters for utf8mb4.
# http://dev.mysql.com/doc/refman/5.5/en/charset-unicode-upgrading.html
#
# Script here is creating the USER_KEY column with 191 characters. This
# can be modified with larger size if needed on databases with character sets 
# other than utf8mb4.
#
DROP TABLE WEBLOGIC_TIMERS;

CREATE TABLE WEBLOGIC_TIMERS (
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

