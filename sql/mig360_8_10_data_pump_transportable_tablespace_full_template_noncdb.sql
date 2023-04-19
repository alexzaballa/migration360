PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-data-pump-full-transp.htm
PRO NON-CDB
PRO 
PRO On Premises:
PRO
PRO mkdir &&dpdump_for_cloud. -p
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_for_cloud AS '&&dpdump_for_cloud.';; 
PRO
select 'ALTER TABLESPACE '||tablespace_name||' READ ONLY;'  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS') order by tablespace_name
;
PRO
PRO ****You can use PARALLEL parameter with expdp to speed up the process. Remember to add %U to dumpfile parameter****
PRO ****You can also set FILESIZE parameter. For example filesize=2g**** 
PRO
select 'expdp \''/ as sysdba\'' '||'FULL=y TRANSPORTABLE=always'||' DIRECTORY=dp_for_cloud DUMPFILE=TTS_'||'01'||'.dmp'||' LOGFILE=TTS'||'01'||'_exp.log' 
from(
select LISTAGG(tablespace_name, ',')
         WITHIN GROUP (ORDER BY tablespace_name) 
         AS tablesp
  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS') 
)
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
PRO
PRO mkdir &&path_data_onprem. -p
PRO
PRO
select 'Set environment variables to +ASM'||chr(10)||
 'asmcmd'
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
select 'cp '||file_name||' '||'&&path_data_onprem./'
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') > 0                               
order by tablespace_name
;
PRO
PRO
select 'Copy using SO'||chr(10)
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') = 0
   AND rownum=1
;
PRO
select 'cp '||file_name||' '||'&&path_data_onprem./'
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') = 0
order by tablespace_name
;
PRO
PRO
PRO Set environment variables to the database
PRO
PRO  sqlplus / as sysdba 
PRO
select 'ALTER TABLESPACE '||tablespace_name||' READ WRITE;'  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS') order by tablespace_name
;
PRO
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&dpdump_for_cloud./*.dmp \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem.'
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
PRO  sqlplus / as sysdba 
PRO
PRO  CREATE OR REPLACE DIRECTORY dp_from_onprem AS '&&dpdump_for_onprem.';; 
PRO
PRO
select 'Adjust ASM PATH'||chr(10)||
 'Set environment variables to +ASM'||chr(10)||
 'asmcmd'
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
select 'cp '||'&&path_data_cloud./'||substr(file_name,instr(file_name,'/',-1)+1,length(file_name))||' '||'+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf'
from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
order by tablespace_name
;
PRO
PRO
PRO Adjust ASM PATH 
PRO Set environment variables to the database
PRO
PRO ****You can use PARALLEL parameter with impdp to speed up the process. Remember to add %U to dumpfile parameter****
PRO
select 'impdp \''/ as sysdba\'' FULL=y DIRECTORY=dp_from_onprem DUMPFILE=TTS_'||'01'||'.dmp'||' LOGFILE=TTS'||'01'||'_imp.log TRANSPORT_DATAFILES='||dataf
from(
select LISTAGG('''+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||tablespace_name||'_'||file_id||'.dbf''' , ',')
         WITHIN GROUP (ORDER BY '''+DATA/DATAFILE/'||tablespace_name||'_'||file_id||'.dbf''') 
         AS dataf
  from dba_data_files s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM dba_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
)
;
PRO
PRO
