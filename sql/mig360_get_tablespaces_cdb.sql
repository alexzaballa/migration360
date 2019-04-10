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
SELECT 'ddl_tablespaces.txt' my_spool_filename FROM dual
/


SPO &&my_spool_filename.

PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO TABLESPACES
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO

VAR v_cursor CLOB;
BEGIN
  :v_cursor := q'[
   SELECT DBMS_METADATA.get_ddl ('TABLESPACE', tablespace_name) result_ddl
     FROM DBA_TABLESPACES s
    WHERE s.contents NOT IN ('UNDO','TEMPORARY')
      AND s.tablespace_name NOT IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
 ORDER BY tablespace_name   
  ]';
END;
/

 
SET SERVEROUTPUT ON
DECLARE
  l_cursor_id INTEGER;
  l_rows_processed INTEGER;
  v_ret clob;
  v_ret2 number;
BEGIN
  l_cursor_id := DBMS_SQL.OPEN_CURSOR;
  FOR i IN (SELECT name
              FROM v$containers 
             WHERE con_id > 2 
               AND open_mode = 'READ WRITE'
             ORDER BY con_id)
  LOOP
    DBMS_OUTPUT.PUT_LINE('--'||i.name); 
    DBMS_SQL.PARSE
      ( c             => l_cursor_id
      , statement     => :v_cursor
      , language_flag => DBMS_SQL.NATIVE
      , container     => i.name
      );
      dbms_sql.define_column(l_cursor_id, 1, v_ret);
      l_rows_processed := DBMS_SQL.EXECUTE(c => l_cursor_id);
       LOOP
         IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
           EXIT;
        END IF;
 
        dbms_sql.column_value(l_cursor_id, 1, v_ret);
        dbms_output.put_line(v_ret);
        dbms_output.put_line(' ');
       END LOOP; 
  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(c => l_cursor_id);
EXCEPTION WHEN OTHERS THEN
 IF DBMS_SQL.IS_OPEN(l_cursor_id) THEN
   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
 END IF;
END;
/

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SPO OFF;

COL my_spool_filename CLE;

