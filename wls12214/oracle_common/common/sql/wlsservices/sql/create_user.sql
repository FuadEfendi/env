Rem
Rem create_user.sql
Rem
Rem Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
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

CREATE USER &&1 IDENTIFIED BY &&2 DEFAULT TABLESPACE &&3 TEMPORARY TABLESPACE &&4;
GRANT connect TO &&1;
GRANT create type TO &&1;
GRANT create procedure TO &&1;
GRANT create table TO &&1;
GRANT create sequence TO &&1;
GRANT create any index to &&1;
GRANT create any trigger to &&1;
GRANT create any table to &&1;
GRANT create any view to &&1;


-- Grant the user unlimited quota to the tablespace.
ALTER USER &&1 QUOTA unlimited ON &&3;

CREATE USER &&5 IDENTIFIED BY &&6 DEFAULT TABLESPACE &&3 TEMPORARY TABLESPACE &&4;
GRANT connect TO &&5;
GRANT create type TO &&5;
GRANT create procedure TO &&5;
GRANT create table TO &&5;
GRANT create sequence TO &&5;
GRANT create any index to &&5;
GRANT create any trigger to &&5;

-- Grant the user unlimited quota to the tablespace.
ALTER USER &&5 QUOTA unlimited ON &&3;
