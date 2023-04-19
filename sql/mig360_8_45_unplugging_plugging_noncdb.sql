
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-unplugging-plugging-non-cdb.htm
PRO 12.2
PRO
PRO 
PRO On Premises:
PRO
PRO mkdir &&path_unplug_pdb. -p
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO shutdown immediate;
PRO
PRO STARTUP OPEN READ ONLY;
PRO
PRO
select 'BEGIN'||chr(10)||' DBMS_PDB.DESCRIBE(''&&path_unplug_pdb./'||'db'||'.xml'');'||chr(10)||'END;'||chr(10)||'/'||chr(10) from dual;
PRO
PRO
select 'Set environment variables to +ASM'||chr(10)||
 'asmcmd'
 from dba_data_files s 
where instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
select 'cp '||file_name||' '||'&&path_unplug_pdb./'
  from dba_data_files s 
 where instr(file_name,'+') > 0                               
order by tablespace_name
;
select 'cp '||file_name||' '||'&&path_unplug_pdb./'
  from dba_temp_files s 
 where instr(file_name,'+') > 0                               
order by tablespace_name
;
PRO
PRO
select 'Copy using SO'||chr(10)
 from dba_data_files s 
where instr(file_name,'+') = 0                               
   AND rownum=1
;
PRO
select 'cp '||file_name||' '||'&&path_unplug_pdb./'
 from dba_data_files s 
where instr(file_name,'+') = 0
order by tablespace_name
;
select 'cp '||file_name||' '||'&&path_unplug_pdb./'
 from dba_temp_files s 
where instr(file_name,'+') = 0
order by tablespace_name
;
PRO
PRO
PRO Cloud:
PRO
PRO  mkdir &&path_plug_pdb. -p
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_unplug_pdb./* \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_plug_pdb./'
from dual
;
PRO
PRO
PRO Cloud: 
PRO
PRO
select 'Adjust ASM PATH'||chr(10)||
 'Set environment variables to +ASM'||chr(10)||
 'asmcmd'
 from dba_data_files s 
where instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
select 'cp '||'&&path_plug_pdb./'||substr(file_name,instr(file_name,'/',-1)+1,length(file_name))||' '||'+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf'
  from dba_data_files s
order by tablespace_name
;
select 'cp '||'&&path_plug_pdb./'||substr(file_name,instr(file_name,'/',-1)+1,length(file_name))||' '||'+DATA/'||'&&mig360_dbname.'||'/DATAFILE/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf'
  from dba_temp_files s
order by tablespace_name
;
PRO
PRO
PRO Adjust ASM PATH on &&path_plug_pdb./db.xml
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
select 'create pluggable database '||'pdb1'||' using ''&&path_plug_pdb./'||'db'||'.xml'';'||chr(10) from dual;
PRO
PRO
select 'ALTER SESSION SET CONTAINER='||'pdb1'||';'||chr(10)||'@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql;'||chr(10)||'ALTER PLUGGABLE DATABASE OPEN;'||chr(10) from dual;
PRO
PRO
