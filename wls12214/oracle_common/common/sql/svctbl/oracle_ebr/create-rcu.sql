Rem
Rem
Rem cremds-rcu.sql
Rem
Rem Copyright (c) 2006, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      create-rcu.sql - RCU SQL script to create EBR-enabled schema for
Rem                       SVCTBL repository. 
Rem
Rem    DESCRIPTION
Rem    This file creates the EBR-enabled database schema for SVCTBL repository.
Rem    To be used only by RCU.
Rem
Rem    NOTES
Rem    The first parameter is the schema user, the second parameter is 
Rem    the edition name.
Rem    The user should have grant to create sequence in order to
Rem    successfully use the SVCTBL Repository.
Rem
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

ALTER SESSION SET EDITION=&&1;

Rem Create SVCTBL Repository

Rem Creating the tables and views for EBR-enabled schema
Rem NOTE: Minimum Database version required - Oracle 11.2
@@../sql/cresvctbl.sql &&2
@@../sql/crecomptbl.sql &&2

EXIT;
