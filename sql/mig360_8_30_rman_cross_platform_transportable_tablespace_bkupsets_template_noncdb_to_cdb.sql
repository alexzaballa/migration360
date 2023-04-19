
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-rman-cross-plat-transp-tablespace.htm
PRO NON-CDB TO CDB

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
PRO mkdir &&dpdump_for_cloud. -p
PRO
PRO mkdir &&path_data_onprem. -p
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_for_cloud AS '&&dpdump_for_cloud.';; 
PRO
PRO
select 
'ALTER TABLESPACE '||tablespace_name||' READ ONLY;'  
from &&table_tb1. s
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
order by tablespace_name
;
PRO
PRO
PRO rman target /
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO ****If you are going to another platform, you can change "FOR TRANSPORT" to "TO PLATFORM". For example:"'TO PLATFORM 'Linux x86 64-bit'"****
PRO ****If you are on 12c, you can use "BACKUP FOR TRANSPORT ALLOW INCONSISTENT INCREMENTAL LEVEL 0/1" for incremental migration****
PRO
select 'BACKUP FOR TRANSPORT FORMAT '||'''&&path_data_onprem./'||'%N_%f'||'.dbf'''||''||' TABLESPACE '||tablesp||' DATAPUMP FORMAT '||'''&&dpdump_for_cloud./'||'01'||'.dmp'||''''||';'  
from(
select LISTAGG(tablespace_name, ',')
         WITHIN GROUP (ORDER BY tablespace_name) 
         AS tablesp
from dba_tablespaces s 
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') 
)
;
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
select 
'ALTER TABLESPACE '||tablespace_name||' READ WRITE;'  
from &&table_tb1. s
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
order by tablespace_name
;
PRO
PRO
PRO Cloud:
PRO
PRO  mkdir &&dpdump_for_onprem. -p
PRO
PRO  mkdir &&path_data_cloud. -p
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&dpdump_for_cloud./* \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem./'
from dual
;
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem./* \' ||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud./'
from dual
;
PRO
PRO
PRO Cloud: 
PRO
PRO
PRO Adjust file permission on &&dpdump_for_onprem./ and &&path_data_cloud.
PRO 
PRO 
PRO Add to tnsnames.ora
PRO
PRO pdbXX=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=my_cloud_server_name)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=pdbXX)))
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO alter session set container=pdbXX;;
PRO
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_from_onprem AS '&&dpdump_for_onprem.';; 
PRO
PRO grant read,write on directory dp_from_onprem to system;;
PRO
PRO
select 
 '--create user '||username||' identified by '||username||';' 
from &&table_tb3. u
where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
order by username
;
PRO
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
select 'rman target sys@pdbXX'||chr(10)||
       'restore all foreign datafiles to new from backupset '||dataf||' '||' DUMP FILE DATAPUMP DESTINATION '||'''&&dpdump_for_onprem./'''||
       ' FROM BACKUPSET '||'''&&dpdump_for_onprem./'||'01'||'.dmp'||''''||';'
from(
select LISTAGG('''&&path_data_cloud./'||tablespace_name||'_'||file_id||'.dbf''' , ' backupset ')
         WITHIN GROUP (ORDER BY '''&&path_data_cloud./'||tablespace_name||'_'||file_id||'.dbf''') 
         AS dataf
  from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
)
;
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO alter session set container=pdbXX;;
PRO
select 
'ALTER TABLESPACE '||tablespace_name||' READ WRITE;'  
from &&table_tb1. s
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
order by tablespace_name
;
PRO
PRO
