------------------------
-- Pre-load variables --
------------------------

-- ebs
DEF ebs_schema = '';
DEF ebs_table_name = 'FND_PRODUCT_GROUPS';
DEF ebs_column1_name = 'RELEASE_NAME';
DEF ebs_column2_name = 'APPLICATIONS_SYSTEM_NAME';
COL ebs_schema NEW_V ebs_schema;
COL ebs_table_name NEW_V ebs_table_name;
COL ebs_column1_name NEW_V ebs_column1_name;
COL ebs_column2_name NEW_V ebs_column2_name;

DEF ebs_release = '';
DEF ebs_system_name = '';
COL ebs_release NEW_V ebs_release;
COL ebs_system_name NEW_V ebs_system_name;
SELECT owner ebs_schema FROM sys.dba_tab_columns WHERE owner = 'APPLSYS' AND table_name = '&&ebs_table_name.' AND column_name = '&&ebs_column1_name.' AND ROWNUM = 1;
SELECT DECODE('&&ebs_schema.','','SYS','&&ebs_schema.') ebs_schema, DECODE('&&ebs_schema.','','DUAL','&&ebs_table_name.') ebs_table_name, DECODE('&&ebs_schema.','','NULL','&&ebs_column1_name.') ebs_column1_name, DECODE('&&ebs_schema.','','NULL','&&ebs_column2_name.') ebs_column2_name FROM DUAL;
SELECT &&ebs_column1_name. ebs_release, &&ebs_column2_name. ebs_system_name FROM &&ebs_schema..&&ebs_table_name. WHERE ROWNUM = 1;

UNDEF ebs_schema ebs_table_name ebs_column1_name ebs_column2_name

-- siebel
DEF siebel_schema = '';
DEF siebel_table_name = 'S_APP_VER';
DEF siebel_column_name = 'APP_VER';
COL siebel_schema NEW_V siebel_schema;
COL siebel_table_name NEW_V siebel_table_name;
COL siebel_column_name NEW_V siebel_column_name;

DEF siebel_app_ver = '';
COL siebel_app_ver NEW_V siebel_app_ver;
SELECT owner siebel_schema FROM sys.dba_tab_columns WHERE table_name = '&&siebel_table_name.' AND column_name = '&&siebel_column_name.' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT DECODE('&&siebel_schema.','','SYS','&&siebel_schema.') siebel_schema, DECODE('&&siebel_schema.','','DUAL','&&siebel_table_name.') siebel_table_name, DECODE('&&siebel_schema.','','NULL','&&siebel_column_name.') siebel_column_name FROM DUAL;
SELECT &&siebel_column_name. siebel_app_ver FROM &&siebel_schema..&&siebel_table_name. WHERE ROWNUM = 1;
SELECT DECODE('&&siebel_schema.','SYS','') siebel_schema FROM DUAL;

UNDEF siebel_table_name siebel_column_name

-- psft
DEF psft_schema = '';
DEF psft_table_name = 'PSSTATUS';
DEF psft_column_name = 'TOOLSREL';
COL psft_schema NEW_V psft_schema;
COL psft_table_name NEW_V psft_table_name;
COL psft_column_name NEW_V psft_column_name;

DEF psft_tools_rel = '';
COL psft_tools_rel NEW_V psft_tools_rel;
SELECT owner psft_schema FROM sys.dba_tab_columns WHERE table_name = '&&psft_table_name.' AND column_name = '&&psft_column_name.' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT DECODE('&&psft_schema.','','SYS','&&psft_schema.') psft_schema, DECODE('&&psft_schema.','','DUAL','&&psft_table_name.') psft_table_name, DECODE('&&psft_schema.','','NULL','&&psft_column_name.') psft_column_name FROM DUAL;
SELECT &&psft_column_name. psft_tools_rel FROM &&psft_schema..&&psft_table_name. WHERE ROWNUM = 1;
SELECT DECODE('&&psft_schema.','SYS','') psft_schema FROM DUAL;

UNDEF psft_table_name psft_column_name

-- SQLTXPLAIN
DEF skip_sqltxplain = '';
COL skip_sqltxplain NEW_V skip_sqltxplain;
select DECODE(COUNT(*),0,'&&fc_skip_script.') skip_sqltxplain from dba_objects where owner='SQLTXPLAIN';

-- System Under Observation extra variables

-- CPU model
COL cmd_getcpu_model NEW_V cmd_getcpu_model
SELECT decode(platform_id,
13,'cat /proc/cpuinfo | grep -i name | sort | uniq', -- Linux x86 64-bit
6,'lsconf | grep Processor', -- AIX-Based Systems (64-bit)
2,'prtconf -b', -- Solaris[tm] OE (64-bit)
4,'machinfo', -- HP-UX IA (64-bit)
'cat /proc/cpuinfo | grep -i name | sort | uniq' -- Others
) cmd_getcpu_model from v$database;

DEF processor_model = 'Unknown';
COL processor_model NEW_V processor_model
HOS &&cmd_getcpu_model. | head -10 > cpuinfo.sql
GET cpuinfo.sql
A ' processor_model FROM DUAL;
0 SELECT '
/
SELECT REPLACE(REPLACE(REPLACE(REPLACE('&&processor_model.', CHR(9)), CHR(10)), ':'), 'model name ') processor_model FROM DUAL;
HOS rm cpuinfo.sql

UNDEF cmd_getcpu_model

COL system_item FOR A40 HEA 'Covers one database'
COL system_value HEA ''


/*****************************************************************************************/

DEF title = 'System Under Observation';
DEF main_table = 'DUAL';
BEGIN
  :sql_text := q'[
WITH
  rac AS (SELECT /*+ &&sq_fact_hints. */ COUNT(*) instances, CASE COUNT(*) WHEN 1 THEN 'Single-instance' ELSE COUNT(*)||'-node RAC cluster' END db_type FROM gv$instance),
  mem AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'memory_target'),
  sga AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'sga_target'),
  pga AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) target FROM gv$system_parameter2 WHERE name = 'pga_aggregate_target'),
  db_block AS (SELECT /*+ &&sq_fact_hints. */ value bytes FROM v$system_parameter2 WHERE name = 'db_block_size'),
  db AS (SELECT /*+ &&sq_fact_hints. */ name, platform_name FROM v$database),
  inst AS (SELECT /*+ &&sq_fact_hints. */ host_name, version db_version FROM v$instance),
  data AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) bytes, COUNT(*) files, COUNT(DISTINCT ts#) tablespaces FROM v$datafile),
  temp AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) bytes FROM v$tempfile),
  log AS (SELECT /*+ &&sq_fact_hints. */ SUM(bytes) * MAX(members) bytes FROM v$log),
  control AS (SELECT /*+ &&sq_fact_hints. */ SUM(block_size * file_size_blks) bytes FROM v$controlfile),
  &&skip_ver_le_11_1. cell AS (SELECT /*+ &&sq_fact_hints. */ COUNT(DISTINCT cell_name) cnt FROM v$cell_state),
  core AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) cnt FROM gv$osstat WHERE stat_name = 'NUM_CPU_CORES'),
  cpu AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) cnt FROM gv$osstat WHERE stat_name = 'NUM_CPUS'),
  pmem AS (SELECT /*+ &&sq_fact_hints. */ SUM(value) bytes FROM gv$osstat WHERE stat_name = 'PHYSICAL_MEMORY_BYTES')
SELECT /*+ &&top_level_hints. */
       'Database name:' system_item, db.name system_value
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
&&skip_ver_le_11_1. SELECT 'Hardware:', CASE WHEN cell.cnt > 0 THEN 'Engineered System '||
&&skip_ver_le_11_1. CASE WHEN '&&processor_model.' LIKE '%5675%' THEN 'X2-2 ' END|| 
&&skip_ver_le_11_1. CASE WHEN '&&processor_model.' LIKE '%2690%' THEN 'X3-2 ' END|| 
&&skip_ver_le_11_1. CASE WHEN '&&processor_model.' LIKE '%2697%' THEN 'X4-2 ' END|| 
&&skip_ver_le_11_1. CASE WHEN '&&processor_model.' LIKE '%2699%' THEN 'X5-2 ' END|| 
&&skip_ver_le_11_1. CASE WHEN '&&processor_model.' LIKE '%8870%' THEN 'X3-8 ' END|| 
&&skip_ver_le_11_1. CASE WHEN '&&processor_model.' LIKE '%8895%' THEN 'X4-8 or X5-8 ' END|| 
&&skip_ver_le_11_1. 'with '||cell.cnt||' storage servers' 
&&skip_ver_le_11_1. ELSE 'Unknown' END FROM cell
&&skip_ver_le_11_1.  UNION ALL
SELECT 'Processor:', '&&processor_model.'
FROM   DUAL
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
]';
END;        
/
@@&&9a_pre_one.

UNDEF processor_model


/*****************************************************************************************/

DEF title = 'Identification';
DEF main_table = 'V$DATABASE';
BEGIN
  :sql_text := q'[
SELECT d.dbid,
       d.name dbname,
       d.db_unique_name,
       d.platform_name,
       i.version,
       i.inst_id,
       i.instance_number,
       i.instance_name,
       LOWER(SUBSTR(i.host_name||'.', 1, INSTR(i.host_name||'.', '.') - 1)) host_name,
       p.value cpu_count,
       '&&ebs_release.' ebs_release,
       '&&ebs_system_name.' ebs_system_name,
       '&&siebel_schema.' siebel_schema,
       '&&siebel_app_ver.' siebel_app_ver,
       '&&psft_schema.' psft_schema,
       '&&psft_tools_rel.' psft_tools_rel
  FROM v$database d,
       gv$instance i,
       gv$system_parameter2 p
 WHERE p.inst_id = i.inst_id
   AND p.name = 'cpu_count'
order by i.inst_id  
]';
END;        
/
@@&&9a_pre_one.

UNDEF ebs_release ebs_system_name siebel_schema siebel_app_ver psft_schema psft_tools_rel


/*****************************************************************************************/

DEF title = 'Version';
DEF main_table = 'V$VERSION';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM V$VERSION
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Database';
DEF main_table = 'V$DATABASE';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Instance';
DEF main_table = 'GV$INSTANCE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$instance
 ORDER BY
       inst_id
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Pluggable Databases State';
DEF main_table = 'V$PDBS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM v$pdbs
 ORDER BY
       con_id
';
END;
/
@@&&skip_ver_le_11.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Pluggable Databases';
DEF main_table = 'DBA_PDBS';
BEGIN
  :sql_text := '
SELECT pdb1.*, pdb2.open_mode, pdb2.restricted, pdb2.open_time, pdb2.total_size, pdb2.block_size, pdb2.recovery_status
FROM  DBA_PDBS pdb1 join v$pdbs pdb2
  on pdb1.con_id=pdb2.con_id
ORDER BY pdb1.con_id
';
END;
/
@@&&skip_ver_le_11.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Database and Instance History';
DEF main_table = 'DBA_HIST_DATABASE_INSTANCE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       dbid,        
       instance_number, 
       startup_time,    
       version,     
       db_name,     
       instance_name,   
       host_name     
  FROM dba_hist_database_instance
 ORDER BY
       dbid,        
       instance_number, 
       startup_time
';
END;        
/
@@&&skip_diagnostics.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Instance Recovery';
DEF main_table = 'GV$INSTANCE_RECOVERY';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$instance_recovery
 ORDER BY
       inst_id
';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Database Properties';
DEF main_table = 'DATABASE_PROPERTIES';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM database_properties
order by 1
';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Options';
DEF main_table = 'V$OPTION';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM v$option
 ORDER BY 1
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Registry';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_REGISTRY' 'DBA_REGISTRY'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM &&main_table.
 ORDER BY
       comp_id
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM &&main_table.
 ORDER BY
       comp_id,con_id
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Registry History';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_REGISTRY_HISTORY' 'DBA_REGISTRY_HISTORY'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM &&main_table.
 ORDER BY 1
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Registry Hierarchy';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_REGISTRY_HIERARCHY' 'DBA_REGISTRY_HIERARCHY'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Registry SQLPatch';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_REGISTRY_SQLPATCH' 'DBA_REGISTRY_SQLPATCH'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_11.&&9a_pre_one.

/******************************************************************************************/

COL skip_apex NEW_V skip_apex
select DECODE(COUNT(*),0,'--') skip_apex from dba_objects where object_name='APEX_RELEASE';
 
DEF title = 'Apex Release';
DEF main_table = 'APEX_RELEASE';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_apex.&&9a_pre_one.


/******************************************************************************************/

--DEF title = 'Feature Usage Statistics';
--@@&&fc_main_table_name. '&&is_cdb.' 'CDB_FEATURE_USAGE_STATISTICS' 'DBA_FEATURE_USAGE_STATISTICS'
--BEGIN
--  :sql_text := q'[
--SELECT /*+ &&top_level_hints. */
--       *
--  FROM &&main_table.
-- ORDER BY
--       name,
--       version
--]';
--END;
--/
--@@&&9a_pre_one.


/*****************************************************************************************/
--add section 1g

--DEF title = 'Options Packs_Usage_Statistics';
--@@&&fc_def_output_file. out_filename 'options_packs_usage_statistics.txt'

--after update the file, remove the command CLEAR COLUMNS

--@@sql/options_packs_usage_statistics.sql


--DEF one_spool_text_file = '&&out_filename.'
--DEF one_spool_text_file_rename = 'Y'
--DEF skip_html = '--';
--DEF skip_text_file = ''
--@@&&9a_pre_one.

--UNDEF out_filename

/*****************************************************************************************/

DEF title = 'License';
DEF main_table = 'GV$LICENSE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$license
 ORDER BY
       inst_id
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resource Limit';
DEF main_table = 'GV$RESOURCE_LIMIT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$resource_limit
 ORDER BY
       resource_name,
       inst_id
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'HWM Statistics';
DEF main_table = 'DBA_HIGH_WATER_MARK_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM dba_high_water_mark_statistics
 ORDER BY
       dbid,
       name
]';
END;
/
@@&&skip_diagnostics.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Database Links';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_DB_LINKS' 'DBA_DB_LINKS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM &&main_table.
 ORDER BY
       owner,
       db_link
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Modified Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 WHERE ismodified = 'MODIFIED'
 ORDER BY
       name,
       inst_id,
       ordinal
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Non-default Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 WHERE isdefault = 'FALSE'
 ORDER BY
       name,
       inst_id,
       ordinal
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'All Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 ORDER BY
       name,
       inst_id,
       ordinal
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Parameter File';
DEF main_table = 'V$SPPARAMETER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM v$spparameter
 WHERE isspecified = 'TRUE'
 ORDER BY
       name,
       sid,
       ordinal
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'System Parameters Change Log';
DEF main_table = 'DBA_HIST_PARAMETER';
BEGIN
  :sql_text := q'[
WITH 
all_parameters AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       snap_id,
       dbid,
       instance_number,
       parameter_name,
       value,
       isdefault,
       ismodified,
       lag(value) OVER (PARTITION BY dbid, instance_number, parameter_hash ORDER BY snap_id) prior_value
  FROM dba_hist_parameter
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&moat369_dbid.
)
SELECT /*+ &&top_level_hints. */
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI') begin_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI') end_time,
       p.snap_id,
       --p.dbid,
       p.instance_number,
       p.parameter_name,
       p.value,
       p.isdefault,
       p.ismodified,
       p.prior_value
  FROM all_parameters p,
       dba_hist_snapshot s
 WHERE p.value != p.prior_value
   AND s.snap_id = p.snap_id
   AND s.dbid = p.dbid
   AND s.instance_number = p.instance_number
 ORDER BY
       s.begin_interval_time DESC,
       --p.dbid,
       p.instance_number,
       p.parameter_name
]';
END;
/
@@&&skip_diagnostics.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'All Hidden Parameters';
DEF main_table = 'x$ksppi';
BEGIN
  :sql_text := q'[
SELECT
  ksppinm name,
  ksppstvl value,
  ksppdesc description
FROM
  x$ksppi a,
  x$ksppsv b
WHERE
  a.indx=b.indx 
AND
  substr(ksppinm,1,1) = '_'
ORDER BY ksppinm
]';
END;
/
@@&&skip_when_notsys.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'PDB Parameter File';
DEF main_table = 'PDB_SPFILE$';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
         pdb.pdb_id
       , pdb.pdb_name
       , UPPER(spf.db_uniq_name) db_unique_name
       , spf.sid
       , spf.name
       , spf.value$ value
  FROM pdb_spfile$ spf,
       dba_pdbs pdb
 WHERE pdb.con_uid = spf.pdb_uid
 ORDER BY
       pdb_id,name
]';
END;
/
@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_when_notsys.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'SQLTXPLAIN Version';
DEF main_table = 'SQLTXPLAIN.SQLI$_PARAMETER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       sqltxplain.sqlt$a.get_param('tool_version') sqlt_version,
       sqltxplain.sqlt$a.get_param('tool_date') sqlt_version_date,
       sqltxplain.sqlt$a.get_param('install_date') install_date
FROM   DUAL
]';
END;
/
@@&&skip_sqltxplain.&&9a_pre_one.
UNDEF skip_sqltxplain

/*****************************************************************************************/

DEF title = 'Memory Configuration';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
DEF foot = 'Recommended GB to be filled out during HC.';
BEGIN
  :sql_text := q'[
WITH
system_parameter AS (
SELECT inst_id,
       name,
       value
  FROM &&gv_object_prefix.system_parameter2
 WHERE name IN
( 'memory_max_target'
, 'memory_target'
, 'pga_aggregate_target'
, 'sga_max_size'
, 'sga_target'
, 'db_cache_size'
, 'shared_pool_size'
, 'shared_pool_reserved_size'
, 'large_pool_size'
, 'java_pool_size'
, 'streams_pool_size'
, 'result_cache_max_size'
, 'db_keep_cache_size'
, 'db_recycle_cache_size'
, 'db_32k_cache_size'
, 'db_16k_cache_size'
, 'db_8k_cache_size'
, 'db_4k_cache_size'
, 'db_2k_cache_size'
)),
spparameter_inst AS (
SELECT i.inst_id,
       p.name,
       p.display_value
  FROM &&v_object_prefix.spparameter p,
       &&gv_object_prefix.instance i
 WHERE p.isspecified = 'TRUE'
   AND p.sid <> '*'
   AND i.instance_name = p.sid
),
spparameter_all AS (
SELECT p.name,
       p.display_value
  FROM &&v_object_prefix.spparameter p
 WHERE p.isspecified = 'TRUE'
   AND p.sid = '*'
)
SELECT s.name,
       s.inst_id,
       CASE WHEN i.name IS NOT NULL THEN TO_CHAR(i.inst_id) ELSE (CASE WHEN a.name IS NOT NULL THEN '*' END) END spfile_sid,
       NVL(i.display_value, a.display_value) spfile_value,
       CASE s.value WHEN '0' THEN '0' ELSE TRIM(TO_CHAR(ROUND(TO_NUMBER(s.value)/POWER(2,30),3),'9990.000'))||'G' END current_gb,
       NULL recommended_gb
  FROM system_parameter s,
       spparameter_inst i,
       spparameter_all  a
 WHERE i.inst_id(+) = s.inst_id
   AND i.name(+)    = s.name
   AND a.name(+)    = s.name
 ORDER BY
       CASE s.name
       WHEN 'memory_max_target'         THEN  1
       WHEN 'memory_target'             THEN  2
       WHEN 'pga_aggregate_target'      THEN  3
       WHEN 'sga_max_size'              THEN  4
       WHEN 'sga_target'                THEN  5
       WHEN 'db_cache_size'             THEN  6
       WHEN 'shared_pool_size'          THEN  7
       WHEN 'shared_pool_reserved_size' THEN  8
       WHEN 'large_pool_size'           THEN  9
       WHEN 'java_pool_size'            THEN 10
       WHEN 'streams_pool_size'         THEN 11
       WHEN 'result_cache_max_size'     THEN 12
       WHEN 'db_keep_cache_size'        THEN 13
       WHEN 'db_recycle_cache_size'     THEN 14
       WHEN 'db_32k_cache_size'         THEN 15
       WHEN 'db_16k_cache_size'         THEN 16
       WHEN 'db_8k_cache_size'          THEN 17
       WHEN 'db_4k_cache_size'          THEN 18
       WHEN 'db_2k_cache_size'          THEN 19
       END,
       s.inst_id
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

