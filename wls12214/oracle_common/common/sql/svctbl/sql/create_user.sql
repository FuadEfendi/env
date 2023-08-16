Rem
Rem $Header: fmwconfig/dist/oracle.fmwconfig.common.shared/common/sql/svctbl/sql/create_user.sql /main/3 2015/07/23 09:34:57 znazib Exp $
Rem
Rem create_user.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      create_user.sql - create database user
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem

CREATE USER &&1 IDENTIFIED BY &&2 DEFAULT TABLESPACE &&3 TEMPORARY TABLESPACE &&4;
GRANT connect TO &&1;
GRANT create table TO &&1;
GRANT select on schema_version_registry to &&1;

-- Grant the user unlimited quota to the tablespace.
ALTER USER &&1 QUOTA unlimited ON &&3;


DECLARE
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE STBROLE';
EXCEPTION
    WHEN OTHERS THEN  NULL;
END;
/

