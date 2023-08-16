-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
--
--
-- dropuser.sql - Drop User
--
-- Note:
--   Drop login, user and schema that were created for Weblogic core.
--   This script uses additional feature supported from Microsoft sqlcmd.exe.
--   It has to be run from an administrator account.
--
--   Syntax: sqlcmd -S <server> -U <username> -P <password> -i dropuser.sql
--                -v SCHEMA_USER="<username>" DATABASE_NAME="<mds db>"
--
--   Examples: sqlcmd -S stada66 -U sa -P x -i dropuser.sql -v SCHEMA_USER="john" DATABASE_NAME="wlscore"
-- 
go
set nocount on
set implicit_transactions off
go

-- drop login
PRINT N'-- Drop login --'

declare @loginId   int

select @loginId = principal_id from sys.sql_logins where name = N'$(SCHEMA_USER)'

IF (@loginId is not null)
BEGIN
  drop login $(SCHEMA_USER) 
END
go

declare @loginIdAdd   int

select @loginIdAdd = principal_id from sys.sql_logins where name = N'$(ADDITIONAL_SCHEMA_NAME)'

IF (@loginIdAdd is not null)
BEGIN
  drop login $(ADDITIONAL_SCHEMA_NAME) 
END
go

-- switch to database
use $(DATABASE_NAME)

-- drop schema
DECLARE @oName    NVARCHAR(257)
DECLARE @iName    NVARCHAR(128)
DECLARE @oType    NVARCHAR(10)
DECLARE @parmDef  NVARCHAR(500)

DECLARE @delSql   NVARCHAR(200)

DECLARE C1 CURSOR GLOBAL FORWARD_ONLY READ_ONLY FOR
  select i.name, s.name  + N'.' + o.name from sys.indexes as i, sys.objects as o , sys.schemas as s 
         where i.object_id = o.object_id and 
              o.schema_id = s.schema_id and 
              (s.name = N'$(SCHEMA_USER)' or s.name = N'$(ADDITIONAL_SCHEMA_NAME)' ) and i.name is not null and
              i.is_unique_constraint = 0 and i.is_primary_key = 0

DECLARE C2 CURSOR GLOBAL FORWARD_ONLY READ_ONLY FOR 
   select s.name + N'.' + o.name, o.type from sys.objects as o , sys.schemas as s 
           where o.schema_id = s.schema_id and (s.name = N'$(SCHEMA_USER)' or s.name = N'$(ADDITIONAL_SCHEMA_NAME)')

DECLARE C3 CURSOR GLOBAL FORWARD_ONLY READ_ONLY FOR
  select i.name, s.name  + N'.' + o.name from sys.foreign_keys as i, sys.objects as o , sys.schemas as s
         where i.parent_object_id = o.object_id and
              o.schema_id = s.schema_id and
              (s.name = N'$(SCHEMA_USER)' or s.name = N'$(ADDITIONAL_SCHEMA_NAME)' ) and i.name is not null


PRINT N'-- Drop Indexes --'

open C1

-- Delete indexes.


WHILE(1=1)
BEGIN
  FETCH NEXT FROM C1 INTO @iName, @oName
       
  IF (@@FETCH_STATUS <> 0)
  BEGIN
    CLOSE C1
    DEALLOCATE C1
    BREAK
  END

  set @delSql = N'drop index ' +  @iName + N' on ' +  @oName

  exec sp_executesql @delSql        
END

PRINT N'-- Drop foreign keys --'

open C3

WHILE(1=1)
BEGIN
  FETCH NEXT FROM C3 INTO @iName, @oName

  IF (@@FETCH_STATUS <> 0)
  BEGIN
    CLOSE C3
    DEALLOCATE C3
    BREAK
  END

  set @delSql = N'alter table ' +  @oName + N' drop constraint ' +  @iName

  exec sp_executesql @delSql
END

-- delete tables, stored procedures and functions.
PRINT N'-- Drop tables, stored procedures and functions --'

open C2

WHILE(1=1)
BEGIN
  FETCH NEXT FROM C2 INTO @oName, @oType
       
  IF (@@FETCH_STATUS <> 0)
  BEGIN
    CLOSE C2
    DEALLOCATE C2
    BREAK
  END
  
  IF ( @oType = N'U')
  BEGIN
    set @delSql = N'drop table ' + @oName
    exec sp_executesql @delSql
  END
  ELSE IF ( @oType = N'P' )
  BEGIN
    set @delSql = N'drop procedure ' + @oName
    exec sp_executesql @delSql
  END
  ELSE IF ( @oType = N'FN' )
  BEGIN
    set @delSql = N'drop function ' + @oName
    exec sp_executesql @delSql
  END
END
go

PRINT N'-- Drop Schema --'

DECLARE @sid    INT

select @sid = schema_id from sys.schemas where name = N'$(SCHEMA_USER)'

IF (@sid is not null)
BEGIN
    drop schema $(SCHEMA_USER) 
END
go

PRINT N'-- Drop Runtime Schema --'

DECLARE @sid    INT

select @sid = schema_id from sys.schemas where name = N'$(ADDITIONAL_SCHEMA_NAME)'

IF (@sid is not null)
BEGIN
    drop schema $(ADDITIONAL_SCHEMA_NAME) 
END
go

-- drop user
PRINT N'-- Drop db user --'

declare @userId   int

select @userId = principal_id from sys.database_principals
    where name = N'$(SCHEMA_USER)' and type = N'S'

IF (@userId is not null)
BEGIN
  drop user $(SCHEMA_USER)
END
go

declare @userIdAdd   int

select @userIdAdd = principal_id from sys.database_principals
    where name = N'$(ADDITIONAL_SCHEMA_NAME)' and type = N'S'

IF (@userIdAdd is not null)
BEGIN
  drop user $(ADDITIONAL_SCHEMA_NAME)
END
go

-- drop user in master
use master
go

declare @userId   int

select @userId = principal_id from sys.database_principals
    where name = N'$(SCHEMA_USER)' and type = N'S'

IF (@userId is not null)
BEGIN
  drop user $(SCHEMA_USER)
END
go

declare @userIdAdd   int

select @userIdAdd = principal_id from sys.database_principals
    where name = N'$(ADDITIONAL_SCHEMA_NAME)' and type = N'S'

IF (@userIdAdd is not null)
BEGIN
  drop user $(ADDITIONAL_SCHEMA_NAME)
END
go


PRINT N'Operation completed!'
go







