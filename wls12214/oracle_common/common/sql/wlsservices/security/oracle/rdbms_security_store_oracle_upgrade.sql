declare
   dyn_stmt VARCHAR2(200);
   row_counter number;
   type array_t is varray(18) of varchar2(160);
   table_name_array array_t := array_t('BEAPC', 'BEAPCM', 'BEAPRMP', 'BEARM', 'BEASAML2_CACHE', 'BEASAMLAP', 'BEASAMLAP_AURI', 'BEASAMLAP_ITP', 'BEASAMLAP_RURI', 
                            'BEASAMLRP', 'BEASAMLRP_ACP', 'BEASAMLRP_AU', 'BEAWCRE', 'BEAXACMLAP', 'BEAXACMLAP_RS', 'BEAXACMLRAP', 'BEAXACMLRAP_R', 'BEAXACMLRAP_RS');
                            
   table_modify_array array_t := array_t('CREDN VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000), PM_CN VARCHAR2(2000)', 'ENTRY_KEY VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000)', 
                            'CN VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000), WCRIDN VARCHAR2(2000), WCRSN VARCHAR2(2000), WCRSDN VARCHAR2(2000), WCRSKI VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'CN VARCHAR2(2000), XRS VARCHAR2(2000)', 'CN VARCHAR2(2000)', 'TYPEN VARCHAR2(2000), CN VARCHAR2(2000),  XR VARCHAR2(2000)', 'XRS VARCHAR2(2000)');
                            
begin
   for i in 1..table_name_array.count loop
       row_counter := 0;
       select count(*) into row_counter from user_tables where table_name=table_name_array(i);
       if row_counter > 0 then  
         -- dbms_output.put_line(i || ':' || table_name_array(i) || '=====>' || table_modify_array(i));
         dyn_stmt := 'ALTER TABLE ' || table_name_array(i) || ' MODIFY ( ' || table_modify_array(i) || ' )'; 
         dbms_output.put_line(i || ':' || dyn_stmt);
         execute immediate dyn_stmt;
         -- dbms_output.put_line(i || ':' || dyn_stmt);
       end if;
   end loop;
end;
commit;
