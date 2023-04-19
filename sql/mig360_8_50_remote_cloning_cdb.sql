
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-remote-cloning-pdb.htm
PRO
PRO 
PRO On Premises:
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO
select 'ALTER SESSION SET CONTAINER='||name||';'||chr(10)||
' CREATE USER remote_clone_user IDENTIFIED BY remote_clone_user;'||chr(10)||
' GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE TO remote_clone_user;'||chr(10)||
' '
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO CONN / AS SYSDBA
PRO
select 
'ALTER PLUGGABLE DATABASE '||name||' CLOSE;'||chr(10)||
'ALTER PLUGGABLE DATABASE '||name||' OPEN READ ONLY;'||chr(10)||
' '
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO
PRO Cloud:
PRO
PRO
PRO Add to tnsnames.ora
PRO
PRO
select name||'_onp=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=&&mig360_host_name.)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME='||name||')))'
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO  sqlplus / as sysdba
PRO
PRO
select 'CREATE DATABASE LINK clone_link_'||name||
' CONNECT TO remote_clone_user IDENTIFIED BY remote_clone_user USING '''||name||'_onp'';'||chr(10)||' '
from v$pdbs where con_id>=3 order by con_id
;
PRO
PRO
select 'CREATE PLUGGABLE DATABASE '||name||' FROM '||name||'@clone_link_'||name||';'||chr(10)||' '
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'alter pluggable database '||name||' open;'||chr(10)||' ' 
 from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO On Premises:
PRO 
PRO  sqlplus / as sysdba
PRO
select 'ALTER SESSION SET CONTAINER='||name||';'||chr(10)||
'ALTER USER remote_clone_user account lock;'||chr(10)||
' '
from v$pdbs where con_id>=3 order by con_id;
PRO
