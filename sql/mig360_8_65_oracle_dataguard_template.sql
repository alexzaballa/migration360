PRO URL: https://www.oracle.com/technetwork/database/availability/dr-to-oracle-cloud-2615770.pdf
PRO
PRO
PRO On Premises:
PRO 
PRO
SELECT 'Adjust db_recovery_file_dest and db_recovery_file_dest_size'
  FROM v$parameter
 WHERE name = 'db_recovery_file_dest'
   AND value IS NULL
   AND rownum=1;
PRO 
PRO
SELECT 'Enabling ARCHIVELOG Mode'||chr(10)||
       ''||chr(10)||
       ' sqlplus / as sysdba'||chr(10)||
       ''||chr(10)||
       ' SHUTDOWN IMMEDIATE;'||chr(10)||
       ' STARTUP MOUNT;'||chr(10)||
       ' ALTER DATABASE ARCHIVELOG;'||chr(10)||
       ' ALTER DATABASE OPEN;'
 FROM v$database
WHERE log_mode <> 'ARCHIVELOG';
PRO 
PRO
SELECT 'Enabling Force Logging Mode'||chr(10)||
       ''||chr(10)||
       ' ALTER DATABASE FORCE LOGGING;'||chr(10)
 FROM v$database
WHERE force_logging = 'NO';
PRO 
PRO 
PRO 
select ' ALTER DATABASE ADD STANDBY LOGFILE THREAD '||thread#||' GROUP '||((select max(group#) from v$log v2 )+rownum) ||' (''+REDO'') '||' SIZE '||bytes||';' from v$log v;
PRO
PRO -- Add one more per thread **** 
PRO 
PRO Add to tnsnames.ora
PRO
PRO &&mig360_dbname_dg._STBY=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=&&ip_address_dbaas_vm.)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=&&mig360_dbname_dg.)(UR=A)))
PRO
PRO Add the source and the destination connect descriptor in the $TNS_ADMIN/tnsnames.ora files on both the source and auxiliary server
PRO
PRO
PRO Cloud:
PRO
PRO
PRO Ensure the listener.ora file is configured for static service registration.
PRO 
PRO SID_LIST_LISTENER =
PRO   (SID_LIST =
PRO   (SID_DESC =
PRO   (SID_NAME=&&mig360_dbname_dg.)
PRO   (ORACLE_HOME=/u01/app/oracle/product/18.0.0/dbhome_1)
PRO   )
PRO )
PRO 
PRO LISTENER =
PRO   (DESCRIPTION_LIST =
PRO     (DESCRIPTION =
PRO     (ADDRESS = (PROTOCOL = TCP)(HOST = &&ip_address_dbaas_vm.)(PORT = 1521))
PRO   )
PRO )
PRO
PRO
PRO Create a file called /tmp/init.ora
PRO 
PRO *.db_name='&&mig360_dbname_dg.'
PRO
SELECT '*.compatible='''||value||''''
  FROM v$parameter
 WHERE name = 'compatible';
PRO
SELECT '*.enable_pluggable_database='||value
  FROM v$parameter
 WHERE name = 'enable_pluggable_database';
PRO 
PRO *.log_file_name_convert='dummy','dummy';
PRO
--Doc ID 352879.1 and Doc ID 2194825.1
PRO
select 'mkdir -p '|| value from v$parameter where name like 'audit_file_dest';
PRO 
PRO orapwd file=$ORACLE_HOME/dbs/orapw&&mig360_dbname_dg. password=YOUR_PASSWORD entries=10
PRO 
PRO 
PRO export ORACLE_SID=&&mig360_dbname_dg.
PRO 
PRO sqlplus / as sysdba
PRO 
PRO STARTUP NOMOUNT PFILE='/tmp/init.ora';;
PRO 
PRO CREATE SPFILE FROM PFILE='/tmp/init.ora';;
PRO 
PRO SHUTDOWN ABORT;;
PRO 
PRO STARTUP NOMOUNT;;
PRO 
PRO
PRO On Premises:
PRO 
PRO
PRO rman TARGET sys/password@&&mig360_dbname_dg. AUXILIARY sys/password@&&mig360_dbname_dg._STBY
PRO 
PRO DUPLICATE TARGET DATABASE FOR STANDBY
PRO FROM ACTIVE DATABASE
PRO DORECOVER
PRO NOFILENAMECHECK;;
PRO 
PRO
PRO sqlplus / as sysdba
PRO
PRO ALTER SYSTEM SET log_archive_dest_2='SERVICE=&&mig360_dbname_dg._STBY ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=&&mig360_dbname_dg.';;
PRO
PRO
PRO Cloud:
PRO
PRO
PRO sqlplus / as sysdba
PRO 
PRO -- Start Apply Process
PRO ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;;
PRO 
PRO 
PRO On Premises:
PRO
PRO
PRO If you are planning to use Broker, you have to change db_unique_name parameter in the standby database
PRO
PRO
PRO sqlplus / as sysdba
PRO
PRO -- Convert standby database to primary
PRO ALTER DATABASE COMMIT TO SWITCHOVER TO STANDBY;;
PRO
PRO -- Shutdown primary database
PRO SHUTDOWN IMMEDIATE;;
PRO
PRO
PRO Cloud:
PRO
PRO
PRO -- Convert standby database to primary
PRO sqlplus / as sysdba
PRO
PRO ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;;
PRO 
PRO -- Shutdown standby database
PRO SHUTDOWN IMMEDIATE;;
PRO 
PRO -- Open old standby database as primary
PRO STARTUP;;
PRO 
