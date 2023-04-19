
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-rman-convert-transp-tablespace.htm
PRO NON-CDB
PRO TO-DO: 1-Adjust Create User            ***
PRO 
PRO On Premises:
PRO
PRO mkdir &&dpdump_for_cloud. -p
PRO
PRO  mkdir &&path_data_onprem. -p
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_for_cloud AS '&&dpdump_for_cloud.';; 
PRO
PRO
select 'ALTER TABLESPACE '||tablespace_name||' READ ONLY;'  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') order by tablespace_name
;
PRO
PRO
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
PRO rman target /
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
select 'CONVERT TABLESPACE '||tablesp||' TO PLATFORM ''Linux x86 64-bit''' ||' FORMAT '||'''&&path_data_onprem./%N_%f.dbf'''||';'  
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
'&&dpdump_for_cloud./*.dmp \'||chr(10)|| 
'&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem./'
from dual
;
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem./*.dbf \'||chr(10)|| 
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
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_from_onprem AS '&&dpdump_for_onprem.';; 
PRO
PRO
select '--create user '||username||' identified by '||username||';' from dba_users where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
order by username
;
PRO
PRO
select 'Adjust ASM PATH'||chr(10)||
 'Set environment variables to +ASM'||chr(10)||
 'asmcmd'
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO 
PRO
select 'cp '||'&&path_data_cloud./'||tablespace_name||'_'||file_id||'.dbf'||' '||'+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf'
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   --AND instr(file_name,'+') > 0                               
order by tablespace_name
;
PRO
PRO
--select 'impdp \''/ as sysdba\'' DIRECTORY=dp_from_onprem DUMPFILE=TTS_'||tablespace_name||'.dmp'||' LOGFILE=TTS'||tablespace_name||'_imp.log TRANSPORT_DATAFILES='||'&&dpdump_for_onprem./'||substr(file_name,instr(file_name,'/',-1)+1,length(file_name)) 
--  from dba_data_files s where 1=1
--   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
--   AND s.tablespace_name NOT IN (SELECT tablespace_name
--                                   FROM dba_tablespaces
--                                  WHERE contents IN ('UNDO','TEMPORARY')) order by tablespace_name
PRO Adjust ASM PATH 
PRO Set environment variables to the database
PRO
select 'impdp \''/ as sysdba\'' DIRECTORY=dp_from_onprem DUMPFILE=TTS_'||'01'||'.dmp'||' LOGFILE=TTS'||'01'||'_imp.log TRANSPORT_DATAFILES='||dataf
from(
select LISTAGG('''+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||tablespace_name||'_'||file_id||'.dbf''' , ',')
         WITHIN GROUP (ORDER BY '''+DATA/DATAFILE/'||tablespace_name||'_'||file_id||'.dbf''') 
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
select 'ALTER TABLESPACE '||tablespace_name||' READ WRITE;'  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') order by tablespace_name
;
PRO
PRO
