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

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

COL my_spool_filename NEW_V my_spool_filename NOPRI;

-- get sool filename and dbid
SELECT 'ddl_users.txt' my_spool_filename FROM dual
/


SPO &&my_spool_filename.

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO USERS
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO

@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'

SELECT &&skip_when_noncdb.'pdb-->'||con_id||chr(10)||
       DBMS_METADATA.get_ddl ('USER', username)
  FROM &&main_table. s
 WHERE 1=1
  &&skip_10g_column.&&skip_11g_column.AND oracle_maintained = 'N'
  &&skip_12c_column.&&skip_18c_column.AND (username not in &&default_user_list_1. and username not in &&default_user_list_2.)  
ORDER BY 
&&skip_when_noncdb.con_id,
username
/

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SPO OFF;

COL my_spool_filename CLE;

