Rem
Rem create-stbrole.sql
Rem
Rem Copyright (c) 2011, 2015, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      create-stbrole.sql -SQL script to grant STBROLE. 
Rem
Rem    DESCRIPTION
Rem    This file creates the STBRole and grant select, insert to 
Rem    COMPONENT_SCHEMA_INFO table.
Rem
Rem


GRANT SELECT, INSERT, UPDATE, DELETE ON &&1..COMPONENT_SCHEMA_INFO TO STBROLE
/

