PRO Doc ID 2308210.1
PRO Check BUG 28502403 – ORACLE 18.3.0 MULTITENANT: COMPATIBILITY CHECK DOES NOT WORK.
PRO
PRO 
PRO On Premises:
PRO
PRO mkdir &&path_unplug_pdb. -p
PRO
PRO  sqlplus / as sysdba 
PRO
PRO
select 'alter pluggable database '||name||' close immediate;'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
PRO  rman target / 
PRO
select 
'backup for transport'||chr(10)||
'unplug into ''&&path_unplug_pdb./'||name||'.xml'''||chr(10)||
'format ''&&path_unplug_pdb./'||name||'_BKP_%U'''||chr(10)||
'pluggable database '||name||';'||chr(10)||
' '
from v$pdbs where con_id>=3 order by con_id;
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
PRO  rman target / 
PRO
PRO
select 
'restore using ''&&path_plug_pdb./'||name||'.xml'''||chr(10)||
'foreign pluggable database '||name||chr(10)||
'format ''+DATA/***ASM_PATH***/%U'''||chr(10)||
'from backupset ''&&path_plug_pdb./***BACKUPSET_NAME_HERE***'''||';'||chr(10)||
' '
from v$pdbs where con_id>=3 order by con_id
;
PRO
PRO
select 'alter pluggable database '||name||' open;'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO