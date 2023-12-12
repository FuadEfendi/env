-- Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
--
--
-- crelstbs.sql - Create Weblogic Leasing table for MySQL
-- 

-- Note ';' has to be applied to the next line in define statement.

set @additional_schema_name='$ADDITIONAL_SCHEMA_NAME';

DROP PROCEDURE if exists create_alter_wls_active_table
/

CREATE PROCEDURE create_alter_wls_active_table(IN schemaName varchar(255))
language sql
BEGIN

  SET @sql = CONCAT('CREATE TABLE IF NOT EXISTS ', schemaName, '.ACTIVE ( ',
    'SERVER VARCHAR(150) NOT NULL, ',
    'INSTANCE VARCHAR(100) NOT NULL, ',
    'DOMAINNAME VARCHAR(50) NOT NULL, ',
    'CLUSTERNAME VARCHAR(50) NOT NULL, ',
    'TIMEOUT DATETIME, ',
    'PRIMARY KEY (SERVER, DOMAINNAME, CLUSTERNAME) )');

  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END
/

CALL create_alter_wls_active_table(@additional_schema_name)
/

DROP PROCEDURE if exists create_alter_wls_active_table
/

