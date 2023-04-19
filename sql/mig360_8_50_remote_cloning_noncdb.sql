
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-remote-cloning-non-cdb.htm
PRO
PRO 
PRO On Premises:
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO
PRO CREATE USER remote_clone_user IDENTIFIED BY remote_clone_user;;
PRO GRANT CREATE SESSION, CREATE PLUGGABLE DATABASE TO remote_clone_user;;
PRO
PRO shutdown immediate;;
PRO STARTUP MOUNT;;
PRO ALTER DATABASE OPEN READ ONLY;;
PRO
PRO
PRO Cloud:
PRO
PRO
PRO Add to tnsnames.ora
PRO
PRO
select 'dbclone'||'=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=&&mig360_host_name.)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME='||'&&mig360_dbname.'||')))'
from dual;
PRO
PRO
PRO  sqlplus / as sysdba
PRO
PRO
select 'CREATE DATABASE LINK clone_link'||
' CONNECT TO remote_clone_user IDENTIFIED BY remote_clone_user USING '||'''dbclone'''||';'
from dual
;
PRO
PRO
select 'CREATE PLUGGABLE DATABASE '||'pdb1'||' FROM '||'NON$CDB'||'@clone_link'||';'
from dual;
PRO
PRO
select 'ALTER SESSION SET CONTAINER='||'pdb1'||';'||chr(10)||
'@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql'
from dual;
PRO
PRO
select 'alter pluggable database '||'pdb1'||' open;' from dual;
PRO
PRO
PRO
PRO On Premises:
PRO 
PRO  sqlplus / as sysdba
PRO
PRO ALTER USER remote_clone_user account lock;;
PRO