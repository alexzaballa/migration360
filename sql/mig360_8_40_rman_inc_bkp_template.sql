
PRO URL: https://docs.oracle.com/database/121/ADMQS/GUID-74D6A06A-EC88-4CF0-B486-7B68DE4A78E4.htm#ADMQS09311
PRO NON-CDB
PRO 
PRO On Premises:
PRO
PRO  mkdir &&path_data_onprem. -p
PRO  mkdir &&path_data_onprem./control -p
PRO  mkdir &&path_data_onprem./level0 -p
PRO  mkdir &&path_data_onprem./level1 -p
PRO
PRO
PRO Cloud:
PRO
PRO  mkdir &&path_data_cloud. -p
PRO  mkdir &&path_data_cloud./control -p
PRO  mkdir &&path_data_cloud./level0 -p
PRO  mkdir &&path_data_cloud./level1 -p
PRO
PRO
PRO On Premises:
PRO
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
PRO
PRO  rman target /
PRO
PRO   alter database backup controlfile to '&&path_data_onprem./control/controlfile.cf' reuse;;
PRO 
PRO   backup as compressed backupset incremental level 0 database format '/u04/oradata/orclp/level0/%U';;
PRO
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem./control/* \'||chr(10)|| 
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud./control/'
from dual
;
PRO
select 'scp -i &&path_ssh_key. \'||chr(10)||
'&&path_data_onprem./level0/* \'||chr(10)|| 
'&&user_ssh.@&&ip_address_dbaas_vm.:&&path_data_cloud./level0/'
from dual
;
PRO
PRO
PRO ****Move the spfile and password file to the Cloud****
PRO
PRO
PRO Cloud:
PRO
PRO
PRO  Adjust file permission on &&path_data_cloud.
PRO
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
PRO
PRO  rman target /
PRO
PRO   startup nomount;;
PRO 
PRO   restore controlfile from '&&path_data_cloud./control/controlfile.cf';;
PRO
PRO   alter database mount;;
PRO
PRO   catalog start with '&&path_data_cloud./level0/';;
PRO
PRO   run
PRO   {
PRO   set newname for database to '+DATA';;
PRO   restore database;;
PRO   }
PRO
PRO   SWITCH DATABASE TO COPY;;
PRO
PRO
PRO On Premises:
PRO
PRO
PRO  ****Run this part as many as needed****
PRO
PRO
PRO  rman target /
PRO
PRO   backup as compressed backupset incremental level 1 database plus archivelog format '&&path_data_onprem/level1/%U';;
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
PRO  Adjust file permission on &&path_data_cloud.
PRO
PRO
PRO  rman target /
PRO
PRO   catalog start with '&&path_data_cloud./level1/';;
PRO
PRO
PRO On Premises:
PRO
PRO
PRO  rman target /
PRO
PRO   RESTORE DATABASE PREVIEW;;
PRO
PRO ****Get the SCN****
PRO
PRO
PRO Cloud:
PRO
PRO
PRO ****If you are on 12.2, you can use "RECOVER DATABASE UNTIL AVAILABLE REDO;"****
PRO
PRO
PRO RECOVER DATABASE UNTIL SCN your_production_scn;;
PRO
PRO
PRO At the end
PRO
PRO
PRO  sqlplus / as sysdba
PRO
PRO   alter database open RESETLOGS;;
PRO
PRO ****Check RedoLogs and TempFiles****
PRO

