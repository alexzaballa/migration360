----------------------------------------------------------------------------------------
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


COL my_spool_filename NEW_V my_spool_filename NOPRI;
COL this_dbid NEW_V this_dbid NOPRI;

-- get sool filename and dbid
SELECT 'quick_db_view_'||name||'.txt' my_spool_filename, dbid this_dbid FROM v$database
/


SPO &&my_spool_filename.


PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO
PRO 001 - general

col SYSTEM_ITEMV format a40
col SYSTEM_VALUEV format a80

WITH
  rac AS (SELECT /*+ MATERIALIZE NO_MERGE */ COUNT(*) instances, CASE COUNT(*) WHEN 1 THEN 'Single-instance' ELSE COUNT(*)||'-node RAC cluster' END db_type FROM gv$instance),
  mem AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'memory_target'),
  sga AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'sga_target'),
  pga AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'pga_aggregate_target'),
  db_block AS (SELECT /*+ MATERIALIZE NO_MERGE */ value bytes FROM v$system_parameter2 WHERE name = 'db_block_size'),
  db AS (SELECT /*+ MATERIALIZE NO_MERGE */ name, platform_name FROM v$database),
  inst AS (SELECT /*+ MATERIALIZE NO_MERGE */ host_name, version db_version FROM v$instance),
  data AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(bytes) bytes, COUNT(*) files, COUNT(DISTINCT ts#) tablespaces FROM v$datafile),
  temp AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(bytes) bytes FROM v$tempfile),
  log AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(bytes) * MAX(members) bytes FROM v$log),
  control AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(block_size * file_size_blks) bytes FROM v$controlfile),
  core AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(value) cnt FROM gv$osstat WHERE stat_name = 'NUM_CPU_CORES'),
  cpu AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(value) cnt FROM gv$osstat WHERE stat_name = 'NUM_CPUS'),
  pmem AS (SELECT /*+ MATERIALIZE NO_MERGE */ SUM(value) bytes FROM gv$osstat WHERE stat_name = 'PHYSICAL_MEMORY_BYTES')
SELECT /*+ NO_MERGE */
       'Database name:' system_itemv, db.name system_valuev
FROM   db
UNION ALL
SELECT 'Oracle Database version:', inst.db_version
FROM   inst
UNION ALL
SELECT 'Database block size:', TRIM(TO_CHAR(db_block.bytes / POWER(2,10), '90'))||' KiB'
FROM   db_block
UNION ALL
SELECT 'Database size:', TRIM(TO_CHAR(ROUND((data.bytes + temp.bytes + log.bytes + control.bytes) / POWER(2,40), 3), '999,999,990.000'))||' TiB'
FROM   db, data, temp, log, control
UNION ALL
SELECT 'Datafiles:', data.files||' (on '||data.tablespaces||' tablespaces)'
FROM   data
UNION ALL
SELECT 'Database configuration:', rac.db_type FROM rac
UNION ALL
SELECT 'Database memory:', 
CASE WHEN mem.target > 0 THEN 'MEMORY '||TRIM(TO_CHAR(ROUND(mem.target / POWER(2,30), 1), '999,990.0'))||' GiB, ' END||
CASE WHEN sga.target > 0 THEN 'SGA '   ||TRIM(TO_CHAR(ROUND(sga.target / POWER(2,30), 1), '999,990.0'))||' GiB, ' END||
CASE WHEN pga.target > 0 THEN 'PGA '   ||TRIM(TO_CHAR(ROUND(pga.target / POWER(2,30), 1), '999,990.0'))||' GiB, ' END||
CASE WHEN mem.target > 0 THEN 'AMM' ELSE CASE WHEN sga.target > 0 THEN 'ASMM' ELSE 'MANUAL' END END
FROM   mem, sga, pga
UNION ALL
SELECT 'Physical CPUs:', core.cnt||' cores'||CASE WHEN rac.instances > 0 THEN ', on '||rac.db_type END
FROM   rac, core
UNION ALL
SELECT 'Oracle CPUs:', cpu.cnt||' CPUs (threads)'||CASE WHEN rac.instances > 0 THEN ', on '||rac.db_type END
FROM   rac, cpu
UNION ALL
SELECT 'Physical RAM:', TRIM(TO_CHAR(ROUND(pmem.bytes / POWER(2,30), 1), '999,990.0'))||' GiB'||CASE WHEN rac.instances > 0 THEN ', on '||rac.db_type END
FROM   rac, pmem
UNION ALL
SELECT 'Operating system:', db.platform_name
FROM   db
&&skip_10g_column.&&skip_11g_column.UNION ALL
&&skip_10g_column.&&skip_11g_column.SELECT 'Multitenant:', CDB from v$database
/

PRO
PRO
PRO 002 - instances

col dbidv   format a20
col dbnamev format a20
col db_unique_namev format a30
col platform_namev  format a30 
col versionv format a20
col inst_idv format 9999999999
col instance_numberv format 9999999999
col instance_namev   format a20
col host_namev       format a20
col cpu_countv       format a20


SELECT d.dbid dbid,
       d.name dbnamev,
       d.db_unique_name db_unique_namev,
       d.platform_name platform_namev,
       i.version versionv,
       i.inst_id inst_idv,
       i.instance_number instance_numberv,
       i.instance_name instance_name,
       LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1)) host_namev,
       p.value cpu_countv
  FROM v$database d,
       gv$instance i,
       gv$system_parameter2 p
 WHERE p.inst_id = i.inst_id
   AND p.name = 'cpu_count'
order by i.inst_id
/

PRO
PRO
PRO 003 - patches

col ACTION_TIMEV format a25
col ACTIONV    format a20
col NAMESPACEV format a20
col VERSIONV   format a20
col IDV        format 9999999999
col COMMENTSV  format a80
col BUNDLE_SERIESV format a20

select COMMENTS COMMENTSV
      ,VERSION VERSIONV
      ,NAMESPACE NAMESPACEV
      ,to_char(ACTION_TIME,'dd/mm/rrrr hh24:mi:ss') ACTION_TIMEV
      ,ACTION ACTIONV            
      ,ID IDV      
      --,BUNDLE_SERIES BUNDLE_SERIESV
  from DBA_REGISTRY_HISTORY
/ 

PRO
PRO
PRO 004 - pdbs

col namev   format a40
col open_modev format a20
col con_idv format 9999999999

SELECT        
       &&skip_when_noncdb.con_id con_idv,
       &&skip_when_noncdb.name namev,
       &&skip_when_noncdb.open_mode open_modev
       &&skip_when_cdb.'NON-CDB'
  &&skip_when_noncdb.FROM v$pdbs
  &&skip_when_cdb.FROM DUAL
ORDER BY 1
/

PRO
PRO
PRO 005 - memory_target

col inst_idv       format 9999999999
col memory_targetv format a40
col sga_targetv    format  a40
col pga_aggregate_targetv format a40
col cpu_countv            format a40

SELECT /*+ MATERIALIZE NO_MERGE */
    inst_id inst_idv,
    value memory_targetv
FROM
    gv$parameter
WHERE
    name = 'memory_target'
ORDER BY inst_id    
/    

PRO
PRO
PRO 006 - sga_target
  
SELECT /*+ MATERIALIZE NO_MERGE */
    inst_id inst_idv,
    value sga_targetv
FROM
    gv$parameter
WHERE
    name = 'sga_target'
ORDER BY inst_id
/  

PRO
PRO
PRO 007 - pga_aggregate_target

SELECT /*+ MATERIALIZE NO_MERGE */
    inst_id inst_idv,
    value pga_aggregate_targetv
FROM
    gv$parameter
WHERE
    name = 'pga_aggregate_target'
ORDER BY inst_id    
/  

PRO
PRO
PRO 008 - cpu_count

SELECT /*+ MATERIALIZE NO_MERGE */
    inst_id inst_idv,
    value cpu_countv
FROM
    gv$parameter
WHERE
    name = 'cpu_count'
ORDER BY inst_id    
/  

PRO
PRO
PRO 009 - sessions

col TOTALV   format 9999999999
col CON_IDV  format 9999999999
col INST_IDV format 9999999999
col TYPEV    format a20
col SERVERV  format a20
col STATUSV  format a20
col STATEV   format a20

SELECT COUNT(*) TOTALV,
       &&skip_10g_column.&&skip_11g_column.con_id CON_IDV,
       inst_id INST_IDV,
       type   TYPEV,
       server SERVERV,
       status STATUSV,
       state  STATEV
  FROM gv$session
 GROUP BY
       &&skip_10g_column.&&skip_11g_column.con_id,
       inst_id,
       type,
       server,
       status,
       state
 ORDER BY
       1 DESC, 2, 3, 4, 5, 6
/


PRO
PRO
PRO 010 - waits

col INST_IDV      format 9999999999
col WAIT_CLASSV   format a30
col TIEME_WAITEDV format 99999999999999

SELECT /*+  NO_MERGE  */ 
       inst_id INST_IDV
      ,wait_class WAIT_CLASSV
      ,time_waited TIEME_WAITEDV
  FROM gv$system_wait_class
 ORDER BY
       inst_id,
       time_waited DESC
/       


PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

SPO OFF;



