
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-unplugging-plugging-pdb.htm
PRO 12.1
PRO
PRO 
PRO On Premises:
PRO
PRO mkdir &&path_unplug_pdb. -p
PRO
select 'mkdir &&path_unplug_pdb.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO
select 'alter pluggable database '||name||' close immediate;'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'alter pluggable database '||name||' unplug into ''&&path_unplug_pdb./'||name||'/'||name||'.xml'';'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'Set environment variables to +ASM'
from CDB_DATA_FILES s where 1=1
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
--verify listagg limit
with t1 as (
select v.con_id,
       '#'||name pdb,
       listagg(' cp '||file_name||' '||'&&path_unplug_pdb./'||v.name||'/',CHR(10)) within group (order by file_name) cmd
from &&table_tb2. s
    ,v$pdbs v
where 1=1
   AND instr(file_name,'+') > 0
   AND v.con_id=s.con_id
group by v.con_id,name
order by con_id
)
select t1.pdb || CHR(10) || 'asmcmd -p << EOF' || CHR(10) || t1.cmd || CHR(10) || 'EOF'|| CHR(10) ||' '  
  from t1
;
PRO
with t1 as (
select v.con_id,
       '#'||name pdb,
       listagg(' cp '||file_name||' '||'&&path_unplug_pdb./'||v.name||'/',CHR(10)) within group (order by file_name) cmd
from CDB_TEMP_FILES s
    ,v$pdbs v
where 1=1
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
from CDB_DATA_FILES s where 1=1
   AND instr(file_name,'+') = 0                               
   AND rownum=1
;
PRO
select '#'||name||chr(10)||
       ' cp '||file_name||' '||'&&path_unplug_pdb./'||v.name||'/'
from CDB_DATA_FILES s 
    ,v$pdbs v
where 1=1
   AND instr(file_name,'+') = 0
   AND v.con_id=s.con_id
order by v.con_id,tablespace_name
;
PRO
select '#'||name||chr(10)||
       ' cp '||file_name||' '||'&&path_unplug_pdb./'||v.name||'/'
from CDB_TEMP_FILES s 
    ,v$pdbs v
where 1=1
   AND instr(file_name,'+') = 0
   AND v.con_id=s.con_id
order by v.con_id,tablespace_name
;
PRO
PRO
PRO Cloud:
PRO
PRO  mkdir &&path_plug_pdb. -p
PRO
select 'mkdir &&path_plug_pdb.'||'/'||name||'/'||' -p' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO On Premises:
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_unplug_pdb./'||name||'/*.xml \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_plug_pdb./'||CHR(10)||
' ' 
from v$PDBS v
where 1=1
  AND v.con_id>=3
order by v.con_id
;
PRO
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_unplug_pdb.'||'/'||name||'/* \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_plug_pdb.'||'/'||name||'/'||CHR(10)||
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
PRO
select 'Set environment variables to +ASM'||chr(10)||
 'Adjust ASM PATH'||chr(10)||
 ' export MIG360_ASM=+DATA/***ASM_PATH***'
from &&table_tb2. s where 1=1
   AND instr(file_name,'+') > 0                               
   AND rownum=1
;
PRO
--verify listagg limit
with t1 as (
select v.con_id,
       '#'||name pdb,      
       listagg(' cp '||'&&path_plug_pdb./'||v.name||'/'||substr(file_name,instr(file_name,'/',-1)+1,length(file_name))||' '||'$MIG360_ASM/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf',CHR(10)) within group (order by file_name) cmd
from &&table_tb2. s 
    ,v$pdbs v
where 1=1
   AND v.con_id=s.con_id
group by v.con_id,name
order by v.con_id
)
select t1.pdb || CHR(10) || 'asmcmd -p << EOF' || CHR(10) || t1.cmd || CHR(10) || 'EOF'||CHR(10)||' ' 
  from t1
;
PRO
with t1 as (
select v.con_id,
       '#'||name pdb,      
       listagg(' cp '||'&&path_plug_pdb./'||v.name||'/'||substr(file_name,instr(file_name,'/',-1)+1,length(file_name))||' '||'$MIG360_ASM/'||substr(file_name,instr(file_name,'/',-1)+1,instr(file_name,'.',1)-(instr(file_name,'/',-1)+1))||'_'||file_id||'.dbf',CHR(10)) within group (order by file_name) cmd
from CDB_TEMP_FILES s 
    ,v$pdbs v
where 1=1
   AND v.con_id=s.con_id
group by v.con_id,name
order by v.con_id
)
select t1.pdb || CHR(10) || 'asmcmd -p << EOF' || CHR(10) || t1.cmd || CHR(10) || 'EOF'||CHR(10)||' '  
  from t1
;
PRO
PRO
select 'Adjust ASM PATH on '||'&&path_plug_pdb./'||name||'.xml;' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO  sqlplus / as sysdba 
PRO
PRO
select 'create pluggable database '||name||' using ''&&path_plug_pdb./'||name||'/'||name||'.xml'';'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'alter pluggable database '||name||' open;'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO