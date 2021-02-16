/*****************************************************************************************/
--CBO System Statistics

DEF title = 'CBO System Statistics';
DEF main_table = 'SYS.AUX_STATS$';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM sys.aux_stats$
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/
--Default Values for DBMS_STATS

DEF title = 'Default Values for DBMS_STATS';
DEF main_table = 'SYS.OPTSTAT_HIST_CONTROL$';
BEGIN
  :sql_text := q'[
SELECT * FROM sys.optstat_hist_control$
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/
--Tables with Missing Stats
--adding NVL to con_id - 19.9 slowness

DEF title = 'Tables with Missing Stats';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TAB_STATISTICS' 'DBA_TAB_STATISTICS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
       s.owner, s.table_name
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.con_id, s.owner, s.table_name, s.stale_stats, s.stattype_locked
  FROM CDB_tab_statistics s,
       CDB_tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND nvl(t.con_id,-1) = nvl(s.con_id,-1)
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM CDB_external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
   AND nvl(e.con_id,-1) = nvl(s.con_id,-1)
)
 ORDER BY
       s.con_id, s.owner, s.table_name
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Tables with Stale Stats
--adding NVL to con_id - 19.9 slowness

DEF title = 'Tables with Stale Stats';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TAB_STATISTICS' 'DBA_TAB_STATISTICS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stale_stats = 'YES'
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
       s.owner, s.table_name
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.con_id, s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stattype_locked
  FROM CDB_tab_statistics s,
       CDB_tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stale_stats = 'YES'
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND nvl(t.con_id,-1) = nvl(s.con_id,-1)
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM CDB_external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
   AND nvl(e.con_id,-1) = nvl(s.con_id,-1)
)
 ORDER BY
       s.con_id, s.owner, s.table_name
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Tables with Outdated Stats'
--adding NVL to con_id - 19.9 slowness

DEF title = 'Tables with Outdated Stats';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TAB_STATISTICS' 'DBA_TAB_STATISTICS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed < SYSDATE - 31
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
       s.owner, s.table_name
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.con_id, s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM CDB_TAB_STATISTICS s,
       CDB_TABLES t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed < SYSDATE - 31
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND nvl(t.con_id,-1) = nvl(s.con_id,-1)
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM CDB_EXTERNAL_TABLES e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name
   AND nvl(e.con_id,-1) = nvl(s.con_id,-1)
)
 ORDER BY
       s.con_id, s.owner, s.table_name
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Tables with Locked Stats
--adding NVL to con_id - 19.9 slowness

DEF title = 'Tables with Locked Stats';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TAB_STATISTICS' 'DBA_TAB_STATISTICS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked, e.type_name external_table_type
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t,
       &&dva_object_prefix.external_tables e
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stattype_locked IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND e.owner(+) = s.owner
   AND e.table_name(+) = s.table_name 
 ORDER BY
       s.owner, s.table_name
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.con_id, s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked, e.type_name external_table_type
  FROM CDB_TAB_STATISTICS s,
       CDB_TABLES t,
       CDB_EXTERNAL_TABLES e
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.stattype_locked IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND nvl(t.con_id,1) = nvl(s.con_id,-1)
   AND t.table_name = s.table_name
   AND e.owner(+) = s.owner
   AND e.con_id(+) = s.con_id
   AND e.table_name(+) = s.table_name 
 ORDER BY
       s.con_id, s.owner, s.table_name
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Global Temporary Tables with Stats
--adding NVL to con_id - 19.9 slowness

DEF title = 'Global Temporary Tables with Stats';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TAB_STATISTICS' 'DBA_TAB_STATISTICS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'Y'
 ORDER BY
       s.owner, s.table_name
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.con_id, s.owner, s.table_name, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM CDB_TAB_STATISTICS s,
       CDB_TABLES t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND nvl(t.con_id,-1) = nvl(s.con_id,-1)
   AND t.table_name = s.table_name
   AND t.temporary = 'Y'
 ORDER BY
       s.con_id, s.owner, s.table_name
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Temp Tables with Stats
--adding NVL to con_id - 19.9 slowness

DEF title = 'Temp Tables with Stats';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TAB_STATISTICS' 'DBA_TAB_STATISTICS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM &&dva_object_prefix.tab_statistics s,
       &&dva_object_prefix.tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   /*AND s.stale_stats = 'YES'*/
   AND (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND NOT EXISTS (
SELECT NULL
  FROM &&dva_object_prefix.external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
)
 ORDER BY
       s.owner, s.table_name
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       s.con_id, s.owner, s.table_name, t.temporary, s.num_rows, s.last_analyzed, s.stale_stats, s.stattype_locked
  FROM CDB_TAB_STATISTICS s,
       CDB_TABLES t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.last_analyzed IS NOT NULL
   /*AND s.stale_stats = 'YES'*/
   AND (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%\_TEMP\_%' ESCAPE '\')
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND nvl(t.con_id,-1) = nvl(s.con_id,-1)
   AND t.table_name = s.table_name
   AND NOT EXISTS (
SELECT NULL
  FROM CDB_EXTERNAL_TABLES e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name 
   AND nvl(e.con_id,-1) = nvl(s.con_id,-1)
)
 ORDER BY
       s.con_id, s.owner, s.table_name
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_bch = 'Y';
DEF skip_pch = 'Y';
DEF vaxis = '';
DEF haxis = '';
DEF skip_all = '';
DEF title_suffix = '';
EXEC :sql_text := '';

/*****************************************************************************************/
