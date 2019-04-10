--
SET TERM ON;
SET HEA ON; 
SET LIN 32767; 
SET NEWP NONE; 
SET PAGES 1000; 
SET LONG 32000; 
SET LONGC 2000; 
SET WRA ON; 
SET TRIMS ON; 
SET TRIM ON; 
SET TI OFF;
SET TIMI OFF;
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;
SET ECHO OFF;
SET VER OFF;
SET FEED OFF;

SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON


COL my_spool_filename NEW_V my_spool_filename NOPRI;

-- get sool filename and dbid
SELECT 'ddl_dbconf.txt' my_spool_filename FROM dual
/


SPO &&my_spool_filename.

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO Data to import and generate migration scripts
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO

PRO ***dba_tablespaces***
SELECT
    tablespace_name|| ',' ||
    status|| ',' ||
    contents "dba_tablespaces"
FROM
    dba_tablespaces;

PRO
PRO ***dba_data_files***
SELECT
    file_name|| ',' ||
    file_id|| ',' ||
    tablespace_name "dba_data_files"
FROM
    dba_data_files;

PRO
PRO ***dba_users***
SELECT
    username|| ',' ||
    user_id|| ',' ||
    account_status
    &&skip_10g_column.&&skip_11g_column. || ',' || oracle_maintained 
    "dba_users"
FROM
    dba_users;

PRO
PRO ***v$parameter***
SELECT
    name|| ',' ||
    value "v$parameter"
FROM
    v$parameter
WHERE
    name IN(
        'db_recovery_file_dest',
        'audit_file_dest'
    );

PRO
PRO ***v$database***
SELECT
    dbid|| ',' ||
    name|| ',' ||
    log_mode|| ',' ||
    force_logging|| ',' ||
    open_mode|| ',' ||
    platform_name "v$database"
FROM
    v$database;

PRO
PRO ***v$log***
SELECT
    group#|| ',' ||
    thread#|| ',' ||
    sequence#|| ',' ||
    bytes|| ',' ||
    status "v$log"
FROM
    v$log;

PRO
PRO ***v$logfile***
SELECT
    group#|| ',' ||
    member "v$logfile"
FROM
    v$logfile;
PRO

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SPO OFF;

COL my_spool_filename CLE;

