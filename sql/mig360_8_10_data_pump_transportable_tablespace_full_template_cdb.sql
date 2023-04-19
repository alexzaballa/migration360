PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-data-pump-full-transp.htm
PRO CDB

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
with t1 as (
select v.con_id,
       'alter session set container='||name||';' pdb,
       listagg(' ALTER TABLESPACE '||tablespace_name||' READ ONLY;',CHR(10)) within group (order by tablespace_name) cmd
from &&table_tb1. s
    ,v$PDBS v
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND v.con_id=s.con_id
group by v.con_id,v.name
order by v.con_id
)
select t1.pdb || CHR(10) || t1.cmd || CHR(10)||' ' from t1
;
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
--verify listagg limit
select 'expdp system@'||v.name||'_onp'||' FULL=y TRANSPORTABLE=always DIRECTORY=dp_for_cloud_'||name||' DUMPFILE=TTS_'||'01'||'_'||name||'.dmp'||' LOGFILE=TTS_'||'01'||'_'||name||'_exp.log'||chr(10)||' ' 
from v$PDBS v
where 1=1
  AND v.con_id>2
order by v.con_id
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
PRO mkdir &&path_data_cloud./ -p
PRO
select 'mkdir &&path_data_cloud.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO On Premises:
PRO
PRO
PRO mkdir &&path_data_onprem./ -p
PRO
select 'mkdir &&path_data_onprem.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'Set environment variables to +ASM'||chr(10)
from &&table_tb2. s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM cdb_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
--verify listagg limit
with t1 as (
select v.con_id,
       '#'||name pdb,
       listagg(' cp '||file_name||' '||'&&path_data_onprem./'||v.name||'/',CHR(10)) within group (order by file_name) cmd
from &&table_tb2. s
    ,v$pdbs v
where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM cdb_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY'))
   AND instr(file_name,'+') > 0
   AND v.con_id=s.con_id
group by v.con_id,name
order by con_id
)
select t1.pdb || CHR(10) || 'asmcmd -p << EOF' || CHR(10) || t1.cmd || CHR(10) || 'EOF'|| CHR(10) ||' '  
 from t1
;
PRO
PRO
select 'Copy using SO'||chr(10)
from &&table_tb2. s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM cdb_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') = 0                               
   AND rownum=1
;
PRO
select '#'||name||chr(10)||
       ' cp '||file_name||' '||'&&path_data_onprem./'||v.name||'/'
from &&table_tb2. s 
    ,v$pdbs v
where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM cdb_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') = 0
   AND v.con_id=s.con_id
order by v.con_id,tablespace_name
;
PRO
PRO
PRO Set environment variables to the database
PRO
PRO  sqlplus / as sysdba 
PRO
with t1 as (
select v.con_id,
       'alter session set container='||name||';' pdb,
       listagg(' ALTER TABLESPACE '||tablespace_name||' READ WRITE;',CHR(10)) within group (order by tablespace_name) cmd
from &&table_tb1. s
    ,v$PDBS v
where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND v.con_id=s.con_id
group by v.con_id,v.name
order by v.con_id
)
select t1.pdb || CHR(10) || t1.cmd || CHR(10)||' ' from t1
;
PRO
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
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem.'||'/'||name||'/* \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud.'||'/'||name||'/'||chr(10)||
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
select 'Set environment variables to +ASM'||chr(10)||
 'Adjust ASM PATH'||chr(10)||
 ' export MIG360_ASM=+DATA/***ASM_PATH***'
from &&table_tb2. s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM cdb_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
--verify listagg limit
with t1 as (
select v.con_id,
       '#'||name pdb,      
       listagg(' cp '||'&&path_data_cloud./'||v.name||'/'||substr(file_name,instr(file_name,'/',-1)+1,length(file_name))||' '||'$MIG360_ASM/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf',CHR(10)) within group (order by file_name) cmd
from &&table_tb2. s 
    ,v$pdbs v
where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM cdb_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND v.con_id=s.con_id
group by v.con_id,name
order by v.con_id
)
select t1.pdb || CHR(10) || 'asmcmd -p << EOF' || CHR(10) || t1.cmd || CHR(10) || 'EOF'|| CHR(10) ||' ' 
from t1
;
PRO
PRO
PRO Adjust ASM PATH 
PRO Set environment variables to the database
PRO
PRO ****You can use PARALLEL parameter with impdp to speed up the process. Remember to add %U to dumpfile parameter****
PRO
--verify listagg limit
select 'impdp system@'||v.name||'_cloud'||' FULL=y DIRECTORY=dp_from_onprem_'||name||' DUMPFILE=TTS_'||'01'||'_'||name||'.dmp'||' LOGFILE=TTS_'||'01'||'_'||name||'_imp.log TRANSPORT_DATAFILES='||dataf||chr(10)||' '
from (
select con_id,
       LISTAGG('$MIG360_ASM/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf' , ',')
         WITHIN GROUP (ORDER BY file_name) 
         AS dataf
from &&table_tb2. s
where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM &&table_tb1.
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
GROUP BY con_id
) s
    ,v$PDBS v
where 1=1
   AND v.con_id=s.con_id
order by v.con_id
;
PRO
PRO