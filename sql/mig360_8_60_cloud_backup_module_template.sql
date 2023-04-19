
PRO URL: https://docs.oracle.com/en/cloud/paas/db-backup-cloud/index.html
PRO URL: https://docs.oracle.com/en/cloud/paas/db-backup-cloud/csdbb/installing-oracle-database-cloud-backup-module-oci.html#GUID-600A939A-6BA8-48F5-8F2F-DFF2A74A015A
PRO
PRO
PRO Download at http://www.oracle.com/technetwork/database/availability/oracle-cloud-backup-2162729.html
PRO
PRO 
PRO On Premises:
PRO
PRO
PRO Transfer opc_installer.zip to Source Database server on /tmp
PRO
PRO  scp opc_installer.zip oracle@&&mig360_host_name./tmp
PRO 
PRO 
PRO mkdir &&path_cloud_bkp_module. -p
PRO mkdir &&path_cloud_bkp_module./installer -p
PRO
PRO cp /tmp/opc_installer.zip &&path_cloud_bkp_module./installer
PRO
PRO chown -R oracle:oinstall &&path_cloud_bkp_module.
PRO
PRO cd &&path_cloud_bkp_module./installer
PRO
PRO unzip opc_installer.zip
PRO
PRO cd &&path_cloud_bkp_module.
PRO 
PRO mkdir config  lib  oci_wallet
PRO
PRO
PRO Create PEM file according to https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm
PRO
PRO mkdir ~/.oci
PRO openssl genrsa -out ~/.oci/oci_api_key.pem 2048
PRO chmod go-rwx ~/.oci/oci_api_key.pem
PRO openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
PRO 
PRO
PRO Config Oracle Database Cloud Backup Module on source and destination:
PRO
PRO java -jar &&path_cloud_bkp_module./installer/oci_installer/oci_install.jar -host https://objectstorage.us-ashburn-1.oraclecloud.com \
PRO   -pvtKeyFile /home/oracle/.oci/oci_api_key.pem \
PRO   -pubFingerPrint FINGERPRINT \
PRO   -uOCID OCID1.USER.OC1..XXXX \
PRO   -tOCID OCID1.TENANCY.OC1..XXXX \
PRO   -walletDir &&path_cloud_bkp_module./oci_wallet \
PRO   -libDir &&path_cloud_bkp_module./lib \
PRO   -bucket db_backups \
PRO   -configFile &&path_cloud_bkp_module./config/opc2&&mig360_dbname_dg..ora
PRO
PRO
PRO Backup Source Database
PRO
PRO
PRO rman target /
PRO
PRO SET ENCRYPTION ON IDENTIFIED BY 'my_strong_passwd' ONLY;;
PRO
PRO CONFIGURE CONTROLFILE AUTOBACKUP ON;;
PRO CONFIGURE DEFAULT DEVICE TYPE TO SBT;;
PRO CONFIGURE DEVICE TYPE sbt BACKUP TYPE TO COMPRESSED BACKUPSET;;
PRO CONFIGURE COMPRESSION ALGORITHM 'BASIC';;
PRO CONFIGURE BACKUP OPTIMIZATION ON;;
PRO
PRO
PRO ****If you have advanced compression****
PRO CONFIGURE COMPRESSION ALGORITHM 'MEDIUM';;
PRO
PRO
PRO CONFIGURE CHANNEL DEVICE TYPE sbt 
PRO PARMS='SBT_LIBRARY=&&path_cloud_bkp_module./lib/libopc.so,
PRO SBT_PARMS=(OPC_PFILE=&&path_cloud_bkp_module./config/opc2&&mig360_dbname_dg..ora)';;
PRO
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO ****CONFIGURE DEVICE TYPE sbt PARALLELISM 4 BACKUP TYPE TO COMPRESSED BACKUPSET****
PRO
PRO
PRO BACKUP DEVICE TYPE sbt DATABASE;;
PRO
PRO
PRO ****You can minimize downtime using incremental backups:****
PRO 
PRO  backup as compressed backupset DEVICE TYPE sbt incremental level 0 database plus archivelog NOT BACKED UP DELETE INPUT;;
PRO  backup as compressed backupset DEVICE TYPE sbt incremental level 1 database plus archivelog NOT BACKED UP DELETE INPUT;;
PRO
PRO
PRO Restore Database to the Cloud:
PRO
PRO 
PRO rman target /
PRO 
PRO STARTUP NOMOUNT;;
PRO 
PRO SET DECRYPTION IDENTIFIED BY 'my_strong_passwd';;
PRO SET DBID=&&mig360_dbid.;;
PRO 
PRO RUN {
PRO ALLOCATE CHANNEL t1 DEVICE TYPE sbt 
PRO  PARMS='SBT_LIBRARY=&&path_cloud_bkp_module./lib/libopc.so,
PRO  SBT_PARMS=(OPC_PFILE=&&path_cloud_bkp_module./config/opc2&&mig360_dbname_dg..ora)';;
PRO 
PRO RESTORE SPFILE TO PFILE '$ORACLE_HOME/dbs/init&&mig360_dbname_dg..ora' FROM AUTOBACKUP;;
PRO }
PRO 
PRO
PRO sqlplus / as sysdba
PRO
PRO create spfile from pfile='?/dbs/initCDB2.ora';;
PRO 
PRO
PRO rman target /
PRO
PRO SET DECRYPTION IDENTIFIED BY 'my_strong_passwd';;
PRO SET DBID=&&mig360_dbid.;;
PRO 
PRO SHUTDOWN ABORT;;
PRO
PRO STARTUP NOMOUNT;;
PRO
PRO 
PRO RUN {
PRO ALLOCATE CHANNEL t1 DEVICE TYPE sbt 
PRO  PARMS='SBT_LIBRARY=&&path_cloud_bkp_module./lib/libopc.so,
PRO  SBT_PARMS=(OPC_PFILE=&&path_cloud_bkp_module./config/opc2&&mig360_dbname_dg..ora)';;
PRO 
PRO RESTORE CONTROLFILE FROM AUTOBACKUP;;
PRO }
PRO
PRO 
PRO ALTER DATABASE MOUNT;; 
PRO 
PRO
PRO CONFIGURE CHANNEL DEVICE TYPE sbt 
PRO PARMS='SBT_LIBRARY=&&path_cloud_bkp_module./lib/libopc.so,
PRO SBT_PARMS=(OPC_PFILE=&&path_cloud_bkp_module./config/opc2&&mig360_dbname_dg..ora)';;
PRO
PRO
PRO ****You can use RMAN PARALLEL parameters or allocate multiple channels in a run block to speed up the process****
PRO
PRO 
PRO RESTORE DATABASE;;
PRO
PRO 
PRO On Premises:
PRO
PRO
PRO ****Is possible applying the incremental backup level 1 to minimize downtime***
PRO ****Using the incremental backup, you have to catalog new backup pieces****
PRO ****Run this on-premises " echo "list backupset;" | rman target / | awk '/Handle:/ {print "catalog device type sbt backuppiece " "'\''" $2 "'\'';"}' "****
PRO ****Copy the result and run in the cloud****
PRO
PRO
PRO Cloud:
PRO 
PRO
PRO ****If you are on 12.2, you can use "RECOVER DATABASE UNTIL AVAILABLE REDO;"****
PRO ****You can also run "RESTORE DATABASE PREVIEW DEVICE TYPE SBT;" to get the SCN****
PRO
PRO
PRO RECOVER DATABASE UNTIL SCN your_last_scn;;
PRO 
PRO 
PRO ALTER DATABASE OPEN RESETLOGS;;
PRO 
PRO ****Check RedoLogs and TempFiles****
PRO
