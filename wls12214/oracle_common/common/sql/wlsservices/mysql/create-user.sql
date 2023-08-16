-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--
-- create-user.sql - Create login, db user and schema for Weblogic
--                   Services  on MySQL 
--

set @schema_user='$SCHEMA_NAME';

set @schema_password='$SCHEMA_PASSWORD';

set @additional_schema_name='$ADDITIONAL_SCHEMA_NAME';

set @additional_schema_password='$ADDITIONAL_SCHEMA_PASSWORD';

-- Default to mysql database
use mysql
/

drop procedure if exists wlssrv_execute_sql;

create procedure wlssrv_execute_sql(sqlStmt varchar(256) character set utf8mb4)
language sql
begin
    SET @sql = sqlStmt;

    PREPARE stmt FROM @sql; 

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;
end
/

drop procedure if exists wlssrv_create_user1
/

create procedure wlssrv_create_user1(schema_user     varchar(16) character set utf8mb4, 
                                    schema_password varchar(64) character set utf8mb4,
                                    schema_name varchar(16) character set utf8mb4,
				    additional_schema_name varchar(16) character set utf8mb4)
language sql
begin

  set @schema=null, @charset=null,@collate=null;

  IF ( @schema IS NULL ) THEN
    -- create create schema 
    SET @sql = CONCAT('create schema ', schema_name); 

    call wlssrv_execute_sql(@sql);
  END IF;

  set @count=0;

  -- Create a user who can access to db locally.
  SET @sql = CONCAT('grant all on ', schema_name, '.*', 
           ' to ', schema_user, '@''localhost'' identified by ''', schema_password, '''');

  call wlssrv_execute_sql(@sql);

  SET @sql = CONCAT('grant process on *.*', ' to ', schema_user, '@''localhost''');

  call wlssrv_execute_sql(@sql);

  SET @sql = CONCAT('grant all on ', schema_name, '.*', 
           ' to ', schema_user, '@''%'' identified by ''', schema_password, '''');

  call wlssrv_execute_sql(@sql);

  SET @sql = CONCAT('grant process on *.*', ' to ', schema_user, '@''%''');

  call wlssrv_execute_sql(@sql);

  SET @sql = CONCAT('grant all on ', additional_schema_name, '.*', 
           ' to ', schema_user, '@''%'' identified by ''', schema_password, '''');

  call wlssrv_execute_sql(@sql);

END
/

drop procedure if exists wlssrv_create_user2
/

create procedure wlssrv_create_user2(schema_user     varchar(16) character set utf8mb4, 
                                    schema_password varchar(64) character set utf8mb4,
                                    schema_name varchar(16) character set utf8mb4)
language sql
begin

  set @schema=null, @charset=null,@collate=null;

  IF ( @schema IS NULL ) THEN
    -- create create schema 
    SET @sql = CONCAT('create schema ', schema_name); 

    call wlssrv_execute_sql(@sql);
  END IF;

  set @count=0;

  -- Create a user who can access to db locally.
  SET @sql = CONCAT('grant all on ', schema_name, '.*', 
           ' to ', schema_user, '@''localhost'' identified by ''', schema_password, '''');

  call wlssrv_execute_sql(@sql);

  SET @sql = CONCAT('grant process on *.*', ' to ', schema_user, '@''localhost''');

  call wlssrv_execute_sql(@sql);

  SET @sql = CONCAT('grant all on ', schema_name, '.*', 
           ' to ', schema_user, '@''%'' identified by ''', schema_password, '''');

  call wlssrv_execute_sql(@sql);

  SET @sql = CONCAT('grant process on *.*', ' to ', schema_user, '@''%''');

  call wlssrv_execute_sql(@sql);

  

END
/


call wlssrv_create_user1(@schema_user, @schema_password, @schema_user, @additional_schema_name)
/

call wlssrv_create_user2(@additional_schema_name, @additional_schema_password, @additional_schema_name)
/

drop procedure if exists wlssrv_create_user1
/

drop procedure if exists wlssrv_create_user2
/

drop procedure if exists wlssrv_execute_sql
/
