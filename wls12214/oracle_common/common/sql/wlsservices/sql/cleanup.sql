Rem
Rem cleanup.sql
Rem
Rem Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cleanup.sql - clean up post-install
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem

Rem Remove ANY privs from schema users, as they are only needed for install time
 
REVOKE create any index FROM &&1;
REVOKE create any trigger FROM &&1;
REVOKE create any table FROM &&1;
REVOKE create any view FROM &&1;

REVOKE create any index FROM &&2;
REVOKE create any trigger FROM &&2;

Rem Add basic schema-level privileges

GRANT create trigger to &&1;
GRANT create table to &&1;
GRANT create view to &&1;

GRANT create trigger to &&2;
