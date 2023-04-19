
PRO URL: https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/mig-unplugging-plugging-pdb.htm
PRO 12.2
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
select 'alter pluggable database '||name||' unplug into ''&&path_unplug_pdb./'||name||'.pdb'';'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
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
'&&path_unplug_pdb./*.pdb \'||chr(10)||
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_plug_pdb./'
from dual
;
PRO
PRO
PRO Cloud: 
PRO
PRO  sqlplus / as sysdba 
PRO
PRO
select 'create pluggable database '||name||' using ''&&path_plug_pdb./'||name||'.pdb'';'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO
select 'alter pluggable database '||name||' open;'||chr(10)||' ' from v$pdbs where con_id>=3 order by con_id;
PRO
PRO