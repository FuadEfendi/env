Rem
Rem cresvctbl.sql
Rem
Rem Copyright (c) 2012, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cresvctbl.sql - SQL script to create ServiceTable schema. 
Rem
Rem    DESCRIPTION
Rem    This file creates the database schema for ServiceTable. 
Rem
Rem

CREATE TABLE "SERVICETABLE"
(
  "ID" VARCHAR2(200) PRIMARY KEY,
  "STYPE" VARCHAR2(50) NOT NULL,
  "ENDPOINT" CLOB NOT NULL,
  "LASTUPDATED" TIMESTAMP NOT NULL,
  "PROMOTED" CHAR(1) check (PROMOTED in ( 'Y', 'N' )) NOT NULL,
  "VALID" CHAR(1) check (VALID in ( 'Y', 'N' )) NOT NULL
) tablespace &&1;

CREATE INDEX SERVICETABLE_IDX ON SERVICETABLE(STYPE);
