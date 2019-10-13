
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-data-pump-conventional.htm
PRO CDB
PRO TO-DO: 1-Tablespaces - DDL ***

DEF table_tb1 = ''
COL table_tb1 NEW_V table_tb1 nopri
SELECT /*+ result_cache */ CASE WHEN '&&is_cdb.' IN ('T','Y') THEN 'CDB_TABLESPACES' ELSE 'DBA_TABLESPACES' end table_tb1
FROM dual;

DEF table_tb2 = ''
COL table_tb2 NEW_V table_tb2 nopri
SELECT /*+ result_cache */ CASE WHEN '&&is_cdb.' IN ('T','Y') THEN 'CDB_DATA_FILES' ELSE 'DBA_DATA_FILES' end table_tb2
FROM dual;

DEF table_tb3 = ''
COL table_tb3 NEW_V table_tb3 nopri
SELECT /*+ result_cache */ CASE WHEN '&&is_cdb.' IN ('T','Y') THEN 'CDB_USERS' ELSE 'DBA_USERS' end table_tb3
FROM dual;

PRO 
PRO On Premises:
PRO
PRO mkdir &&dpdump_for_cloud./ -p
PRO
select 'mkdir &&dpdump_for_cloud.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_for_cloud AS '&&dpdump_for_cloud.';; 
PRO
select 'alter session set container='||name||';'||chr(10)||
' CREATE OR REPLACE DIRECTORY dp_for_cloud_'||name||' AS ''&&dpdump_for_cloud.'||'/'||name||''';'||chr(10)||
' '
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'alter session set container='||name||';'||chr(10)||
' grant read,write on directory dp_for_cloud_'||name||' to system;'||chr(10)||
' ' 
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO Add to tnsnames.ora
PRO
PRO
select name||'_onp=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=&&mig360_host_name.)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME='||name||')))'
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO ****You can use PARALLEL parameter with expdp to speed up the process. Remember to add %U to dumpfile parameter****
PRO ****You can also set FILESIZE parameter. For example filesize=2g**** 
PRO
PRO
select 'expdp system@'||v.name||'_onp'||' SCHEMAS='||username||' DIRECTORY=dp_for_cloud_'||name||' DUMPFILE='||username||'_'||name||'.dmp'||' LOGFILE='||username||'_'||name||'_exp.log flashback_time=systimestamp'||chr(10)||' ' 
from &&table_tb3. u
    ,v$PDBS v
where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
  and v.con_id=u.con_id
  and v.con_id>=3
  and username not in (select grantee
                         from cdb_role_privs 
                        where granted_role='PDB_DBA'
                          and con_id=v.con_id
                          and grantee<>'SYS')
  and username not like '&&mig360_common_user_prefix.%'
order by u.con_id,username
;
PRO
PRO
PRO Cloud:
PRO
PRO  mkdir &&dpdump_for_onprem./ -p
PRO
select 'mkdir &&dpdump_for_onprem.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
   '&&dpdump_for_cloud./'||name||'/*.dmp \'||chr(10)||
   '&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem.'||'/'||name||'/'||chr(10)||
   ' '
from v$PDBS v
where 1=1
  AND v.con_id>=3
order by v.con_id
;
PRO
PRO
PRO Cloud: 
PRO
--if you are going to DBCS - OCI
--create pluggable database PDB_MIG_NEW ADMIN USER pdb_adm IDENTIFIED BY pdb_adm keystore identified by "your_password";
--alter session set container=pdb_mig_new;
--administer key management set key force keystore identified by "your_password" with backup;
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_from_onprem AS '&&dpdump_for_onprem.';; 
PRO
select 'alter session set container='||name||';'||chr(10)||
' CREATE OR REPLACE DIRECTORY dp_from_onprem_'||name||' AS ''&&dpdump_for_onprem.'||'/'||name||''';'||chr(10)||
' ' 
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'alter session set container='||name||';'||chr(10)||
' grant read,write on directory dp_from_onprem_'||name||' to system;'||chr(10)||
' ' 
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO Add to tnsnames.ora
PRO
PRO
select name||'_cloud=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=my_cloud_server_name)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME='||name||')))'
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO Adjust and create the tablespaces
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
with t1 as (
select v.con_id,
       'alter session set container='||name||';' pdb,       
       listagg(' CREATE BIGFILE TABLESPACE '||tablespace_name||' DATAFILE '||'''+DATA'''||' SIZE 10M AUTOEXTEND ON NEXT 10M;',CHR(10)) within group (order by tablespace_name) cmd
from &&table_tb1. s
    ,v$PDBS v
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND v.con_id=s.con_id
group by v.con_id,v.name
order by v.con_id
)
select t1.pdb || CHR(10) || t1.cmd || CHR(10)||' '  from t1
;
PRO
PRO
PRO ****You can use PARALLEL parameter with impdp to speed up the process. Remember to add %U to dumpfile parameter****
PRO
PRO
select 'impdp system@'||v.name||'_cloud'||' SCHEMAS='||username||' DIRECTORY=dp_from_onprem_'||name||' DUMPFILE='||username||'_'||name||'.dmp'||' LOGFILE='||username||'_'||name||'_imp.log'||chr(10)||' ' 
from &&table_tb3. u
    ,v$PDBS v
where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
  and v.con_id=u.con_id
  and username not in (select grantee
                         from cdb_role_privs 
                        where granted_role='PDB_DBA'
                          and con_id=v.con_id
                          and grantee<>'SYS')
  and username not like '&&mig360_common_user_prefix.%'  
order by u.con_id,username
;
PRO
