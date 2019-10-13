
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-data-pump-conventional.htm
PRO NON-CDB to CDB
PRO TO-DO: 1-Tablespaces - DDL ***
PRO 
PRO On Premises:
PRO
PRO
PRO mkdir &&dpdump_for_cloud. -p
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_for_cloud AS '&&dpdump_for_cloud.';; 
PRO
PRO
PRO ****You can use PARALLEL parameter with expdp to speed up the process. Remember to add %U to dumpfile parameter****
PRO ****You can also set FILESIZE parameter. For example filesize=2g**** 
PRO
PRO
select 'expdp \''/ as sysdba\'' SCHEMAS='||username||' DIRECTORY=dp_for_cloud DUMPFILE='||username||'.dmp'||' LOGFILE='||username||'_exp.log flashback_time=systimestamp' from dba_users where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
order by username
;
PRO
PRO
PRO Cloud:
PRO
PRO  mkdir &&dpdump_for_onprem. -p
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&dpdump_for_cloud./*.dmp \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem./' 
from dual
;
PRO
PRO
PRO Cloud: 
PRO
PRO
PRO Adjust file permission on &&dpdump_for_onprem./
PRO 
PRO 
PRO Add to tnsnames.ora
PRO
PRO pdbXX=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=my_cloud_server_name)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=pdbXX)))
PRO
PRO
PRO sqlplus / as sysdba
PRO
PRO alter session set container=pdbXX;;
PRO
PRO
PRO CREATE OR REPLACE DIRECTORY dp_from_onprem AS '&&dpdump_for_onprem.';; 
PRO
PRO grant read,write on directory dp_from_onprem to system;;
PRO
PRO
PRO Adjust and create the tablespaces
PRO
PRO
select 'CREATE BIGFILE TABLESPACE '||tablespace_name||' DATAFILE '||'''+DATA'''||' SIZE 10M AUTOEXTEND ON NEXT 10M;'  
from DBA_TABLESPACES s
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
order by tablespace_name
;
PRO
PRO
PRO ****You can use PARALLEL parameter with impdp to speed up the process. Remember to add %U to dumpfile parameter****
PRO
PRO
select 'impdp system@pdbXX SCHEMAS='||username||' DIRECTORY=dp_from_onprem DUMPFILE='||username||'.dmp'||' LOGFILE='||username||'_imp.log' from dba_users where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
order by username
;
PRO
PRO
