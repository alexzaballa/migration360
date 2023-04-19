
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-rman-transp-tablespace.htm
PRO CDB
PRO TO-DO: 1-Adjust Create User            ***

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
PRO mkdir &&rman_transdest./ -p
PRO
select 'mkdir &&rman_transdest.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO mkdir &&rman_auxdest. -p
PRO
select 'mkdir &&rman_auxdest.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO rman target /
PRO
PRO ****Run a full backup before, to avoid datafile destination errors and auxiliary instance creation errors****
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
select 'TRANSPORT TABLESPACE '||tablesp||' TABLESPACE DESTINATION '||'''&&rman_transdest.'||'/'||v.name||'/'''||' AUXILIARY DESTINATION '||'''&&rman_auxdest'||'/'||v.name||'/'''||';'||chr(10)||' '  
from (
select v.con_id,
       LISTAGG(v.name||':'||tablespace_name, ',')
         WITHIN GROUP (ORDER BY v.name||':'||tablespace_name) 
         AS tablesp
  from &&table_tb1. s 
      ,v$pdbs v
  where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') 
   AND v.con_id=s.con_id
GROUP by v.con_id
) s
    ,v$PDBS v
where 1=1
   AND v.con_id=s.con_id
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
PRO  mkdir &&path_data_cloud./ -p
PRO
select 'mkdir &&path_data_cloud.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
   '&&rman_transdest./'||name||'/*.dmp \'||chr(10)||
   '&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem.'||'/'||name||'/'||chr(10)||
   ' '
from v$PDBS v
where 1=1
  AND v.con_id>=3
order by v.con_id
;
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
   '&&rman_transdest./'||name||'/*.sql \'||chr(10)||
   '&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem.'||'/'||name||'/'||chr(10)||
   ' '
from v$PDBS v
where 1=1
  AND v.con_id>=3
order by v.con_id
;
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&rman_transdest./'||name||'/*.dbf \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud./'||name||'/'||chr(10)||
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
--for next release: generate a SQL File with all user privileges
with t1 as (
select v.con_id,
       '--alter session set container='||name||';' pdb,       
       listagg(' --create user '||username||' identified by '||username||';',CHR(10)) within group (order by username) cmd
from &&table_tb3. u
    ,v$PDBS v
where 1=1
 AND v.con_id=u.con_id
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
 AND username not in (select grantee
                        from cdb_role_privs 
                       where granted_role='PDB_DBA'
                         and con_id=v.con_id
                         and grantee<>'SYS')
 AND username not like '&&mig360_common_user_prefix.%'
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
select name||'_cloud=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=my_cloud_server_name)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME='||name||')))'
from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'Now, you can move the datafiles from '||'&&path_data_cloud.'||' to +ASM'||chr(10)
from &&table_tb2. s where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM cdb_tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
PRO
select 'Adjust and run the script &&dpdump_for_onprem./'||name||'/impscrpt.sql using data bellow.' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
--verify listagg limit
select 'impdp system@'||v.name||'_cloud'||' DIRECTORY=dp_from_onprem_'||name||' DUMPFILE=dmpfile.dmp LOGFILE=dmpfile_imp.log TRANSPORT_DATAFILES='||dataf||chr(10)||' '
from (
select v.con_id,
       LISTAGG('&&path_data_cloud./'||v.name||'/***DATAFILE***/'||'o1_mf_'||lower(tablespace_name)||'__'||file_id||'_.dbf' , ',')
         WITHIN GROUP (ORDER BY file_name) 
         AS dataf
from &&table_tb2. s
    ,v$pdbs v
where 1=1
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM &&table_tb1.
                                  WHERE contents IN ('UNDO','TEMPORARY')) 
   AND v.con_id=s.con_id
GROUP BY v.con_id
) s
    ,v$PDBS v
where 1=1
   AND v.con_id=s.con_id
order by v.con_id
;
PRO
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
select t1.pdb || CHR(10) || t1.cmd || CHR(10)||' ' from t1;
PRO