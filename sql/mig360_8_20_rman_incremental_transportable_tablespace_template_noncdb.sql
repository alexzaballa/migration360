PRO URL: Using Rman Incremental backups To Update Transportable Tablespaces. (Doc ID 831223.1)
PRO NON-CDB
PRO TO-DO: 1-Adjust Create User            ***
PRO 
PRO On Premises:
PRO
PRO
PRO mkdir &&dpdump_for_cloud./ -p
PRO
PRO mkdir &&path_data_onprem./level0/ -p
PRO
PRO mkdir &&path_data_onprem./level1/ -p
PRO
PRO
PRO rman target /
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
select 'BACKUP INCREMENTAL LEVEL 0 FORMAT '||'''&&path_data_onprem./level0/%N_%f.dbf'''||' TABLESPACE '||tablesp||';'  
from(
select LISTAGG(tablespace_name, ',')
         WITHIN GROUP (ORDER BY tablespace_name) 
         AS tablesp
  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') 
)
;
PRO
PRO
PRO Cloud:
PRO
PRO
PRO  mkdir &&dpdump_for_onprem. -p
PRO
PRO  mkdir &&path_data_cloud./level0 -p
PRO 
PRO  mkdir &&path_data_cloud./level1 -p
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem./level0/* \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud./level0/'
from dual
;
PRO
PRO
PRO Cloud:
PRO
PRO  rman target /
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO ****If you are going to another platform, you can add "FROM PLATFORM". For example:"RESTORE FROM PLATFORM 'Linux x86 64-bit"****
PRO 
--select 'RESTORE all foreign datafiles to new from backupset '||dataf||';'
--from(
--select LISTAGG('''&&path_data_cloud./level0/'||tablespace_name||'_'||file_id||'.dbf''' , ' backupset ')
--         WITHIN GROUP (ORDER BY file_id) 
--         AS dataf
--  from dba_data_files s where 1=1
--   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
--   AND s.tablespace_name NOT IN (SELECT tablespace_name
--                                   FROM dba_tablespaces
--                                  WHERE contents IN ('UNDO','TEMPORARY')) 
--)
select 'RESTORE ALL FOREIGN DATAFILES FORMAT '||'''+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||'%N_%f.dbf'''||' from backupset '||'''&&path_data_cloud./level0/'||tablespace_name||'_'||file_id||'.dbf'';'
 from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
order by tablespace_name
;
PRO
--PRO  ****Copy the new datafiles name****
--PRO  ****You will needed it for recover****
PRO
PRO
PRO  ****Run this part bellow as many as needed****
PRO
PRO
PRO On Premises:
PRO
PRO 
select 'rm -f &&path_data_onprem./level1/*' from dual;
PRO
PRO
PRO rman target /
PRO
select 'BACKUP INCREMENTAL LEVEL 1 FORMAT '||'''&&path_data_onprem./level1/%N_%f.dbf'''||' TABLESPACE '||tablesp||';'  
from(
select LISTAGG(tablespace_name, ',')
         WITHIN GROUP (ORDER BY tablespace_name) 
         AS tablesp
  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') 
)
;
PRO
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem./level1/* \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud./level1/'
from dual
;
PRO
PRO
PRO Cloud:
PRO
PRO
PRO ****If you are going to another platform, you can add "FROM PLATFORM". For example:"RECOVER FROM PLATFORM 'Linux x86 64-bit"****
PRO 
select 'RECOVER foreign datafilecopy '||'''+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf'''||' from backupset '||'''&&path_data_cloud./level1/'||tablespace_name||'_'||file_id||'.dbf'';'
 from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
order by tablespace_name
;
PRO
PRO
PRO ****At the end****
PRO 
PRO 
PRO On Premises:
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_for_cloud AS '&&dpdump_for_cloud.';; 
PRO
select 'ALTER TABLESPACE '||tablespace_name||' READ ONLY;'  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') order by tablespace_name
;
PRO
PRO
select 'rm -f &&path_data_onprem./level1/*' from dual;
PRO
PRO
PRO rman target /
PRO
select 'BACKUP INCREMENTAL LEVEL 1 FORMAT '||'''&&path_data_onprem./level1/%N_%f.dbf'''||' TABLESPACE '||tablesp||';'  
from(
select LISTAGG(tablespace_name, ',')
         WITHIN GROUP (ORDER BY tablespace_name) 
         AS tablesp
  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') 
)
;
PRO
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem./level1/* \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud./level1/'
from dual
;
PRO
--need to check listagg limit
select 'expdp \''/ as sysdba\'' TRANSPORT_TABLESPACES='||tablesp||' DIRECTORY=dp_for_cloud DUMPFILE=TTS_'||'01'||'.dmp'||' LOGFILE=TTS'||'01'||'_exp.log' 
from(
select LISTAGG(tablespace_name, ',')
         WITHIN GROUP (ORDER BY tablespace_name) 
         AS tablesp
  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') 
)
;
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
select 'ALTER TABLESPACE '||tablespace_name||' READ WRITE;'  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') order by tablespace_name
;
PRO
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
PRO sqlplus / as sysdba 
PRO
PRO CREATE OR REPLACE DIRECTORY dp_from_onprem AS '&&dpdump_for_onprem.';; 
PRO
PRO
--for next release: generate a SQL File with all privileges from the user
select '--create user '||username||' identified by '||username||';' from dba_users where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
order by username
;
PRO
PRO
PRO rman target /
PRO
PRO ****If you are going to another platform, you can add "FROM PLATFORM". For example:"RECOVER FROM PLATFORM 'Linux x86 64-bit"****
PRO 
select 'RECOVER foreign datafilecopy '||'''+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf'''||' from backupset '||'''&&path_data_cloud./level1/'||tablespace_name||'_'||file_id||'.dbf'';'
 from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
order by tablespace_name
;
PRO
PRO
PRO
select 'impdp \''/ as sysdba\'' DIRECTORY=dp_from_onprem DUMPFILE=TTS_'||'01'||'.dmp'||' LOGFILE=TTS'||'01'||'_imp.log TRANSPORT_DATAFILES='||dataf
from(
select LISTAGG('''+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf''' , ',')
         WITHIN GROUP (ORDER BY tablespace_name,file_id) 
         AS dataf
  from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
)
;
PRO
