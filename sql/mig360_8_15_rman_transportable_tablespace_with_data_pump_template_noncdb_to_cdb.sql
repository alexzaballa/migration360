
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-rman-transp-tablespace.htm
PRO NON-CDB to CDB
PRO TO-DO: 1-Adjust Create User            ***
PRO 
PRO On Premises:
PRO
PRO mkdir &&rman_transdest. -p
PRO
PRO mkdir &&rman_auxdest. -p
PRO
PRO
PRO rman target /
PRO
PRO ****Run a full backup before, to avoid datafile destination errors and auxiliary instance creation errors****
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
select 'TRANSPORT TABLESPACE '||tablesp||' TABLESPACE DESTINATION '||'''&&rman_transdest.'''||' AUXILIARY DESTINATION '||'''&&rman_auxdest.'''||';'  
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
PRO  mkdir &&dpdump_for_onprem. -p
PRO
PRO  mkdir &&path_data_cloud. -p
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&rman_transdest./*.dmp \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem./'
from dual
;
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&rman_transdest./*.sql \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&dpdump_for_onprem./'
from dual
;
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&rman_transdest./*.dbf \'||chr(10)||
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
select '--create user '||username||' identified by '||username||';' from dba_users where 1=1
&&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
&&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)
order by username
;
PRO
PRO
select 'Now, you can move the datafiles from '||'&&path_data_cloud.'||' to +ASM'||chr(10)
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
PRO Adjust and run the script &&dpdump_for_onprem./impscrpt.sql using data bellow.
PRO
PRO
select 'impdp system@pdbXX DIRECTORY=dp_from_onprem DUMPFILE=dmpfile.dmp LOGFILE=dmpfile_imp.log TRANSPORT_DATAFILES='||dataf||chr(10)||' '
from (
select LISTAGG('&&rman_transdest./'||'o1_mf_'||lower(tablespace_name)||'__'||file_id||'_.dbf' , ',')
         WITHIN GROUP (ORDER BY file_name) 
         AS dataf
from dba_data_files s
where 1=1
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
select 'ALTER TABLESPACE '||tablespace_name||' READ WRITE;'  from dba_tablespaces s where 1=1
   AND s.contents NOT IN ('UNDO','TEMPORARY')
   AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS','USERS') order by tablespace_name
;
PRO
PRO
