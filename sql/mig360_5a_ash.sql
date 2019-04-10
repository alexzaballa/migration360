/*****************************************************************************************/
--

DEF title = 'Top 24 Wait Events';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_HIST_ACTIVE_SESS_HISTORY' 'DBA_HIST_ACTIVE_SESS_HISTORY'
BEGIN
  :sql_text := q'[
WITH
ranked AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       h.wait_class,
       event event_name,
       COUNT(*) samples,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) wrank
  FROM &&awr_object_prefix.active_sess_history h
 WHERE 1=1
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND h.session_state = 'WAITING'
 GROUP BY
       h.wait_class,
       event
)
SELECT ROUND(samples * 10 / 3600, 1) hours_waited,
       wait_class, 
       event_name
  FROM ranked
 WHERE wrank < 25
 ORDER BY
       wrank
]';
  :sql_text_cdb := q'[
WITH
ranked AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       h.wait_class,
       event event_name,
       con_id,
       COUNT(*) samples,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC, con_id) wrank
  FROM CDB_HIST_ACTIVE_SESS_HISTORY h
 WHERE 1=1
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND h.session_state = 'WAITING'
 GROUP BY
       h.wait_class,
       event,
       con_id
)
SELECT ROUND(samples * 10 / 3600, 1) hours_waited,
       wait_class, 
       event_name,
       con_id
  FROM ranked
 WHERE wrank < 25
 ORDER BY
       wrank
]';
END;
/

@@&&skip_diagnostics.&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Sessions Aggregate per Username and Machine - History';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_HIST_ACTIVE_SESS_HISTORY' 'DBA_HIST_ACTIVE_SESS_HISTORY'
BEGIN
  :sql_text := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       COUNT(*),
       instance_number, 
       (select username from dba_users u where u.user_id = h.user_id) username,       
       machine
  FROM &&awr_object_prefix.active_sess_history h
 WHERE 1=1
   AND user_id <> 0
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
 GROUP BY
       instance_number,
       user_id,       
       machine
order by 1 desc, 2, 3
]';
  :sql_text_cdb := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       COUNT(*),
       instance_number,  
       (select username from dba_users u where u.user_id = h.user_id) username,       
       machine,
       con_id
  FROM CDB_HIST_ACTIVE_SESS_HISTORY h
 WHERE 1=1
   AND user_id <> 0
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
 GROUP BY
       instance_number,
       user_id,       
       machine,
       con_id
order by 1 desc, 2, 3
]';
END;
/

@@&&skip_diagnostics.&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Sessions Aggregate per Username, Machine and Program - History';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_HIST_ACTIVE_SESS_HISTORY' 'DBA_HIST_ACTIVE_SESS_HISTORY'
BEGIN
  :sql_text := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       COUNT(*),
       instance_number,  
       (select username from dba_users u where u.user_id = h.user_id) username,       
       machine,
       program
  FROM &&awr_object_prefix.active_sess_history h
 WHERE 1=1
   AND user_id <> 0
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND NOT regexp_like(program, '^.*\((P[[:alnum:]]{3})\)$')
 GROUP BY
       instance_number,
       user_id,       
       machine,
       program
order by 1 desc, 2, 3, 4
]';
  :sql_text_cdb := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       COUNT(*),
       instance_number,  
       (select username from dba_users u where u.user_id = h.user_id) username,       
       machine,
       program,
       con_id
  FROM CDB_HIST_ACTIVE_SESS_HISTORY h
 WHERE 1=1
   AND user_id <> 0
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND NOT regexp_like(program, '^.*\((P[[:alnum:]]{3})\)$')
 GROUP BY
       instance_number,
       user_id,       
       machine,
       program,
       con_id
order by 1 desc, 2, 3, 4, 5
]';
END;
/

@@&&skip_diagnostics.&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Sessions Aggregate per Username, Machine, Program and Service - History';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_HIST_ACTIVE_SESS_HISTORY' 'DBA_HIST_ACTIVE_SESS_HISTORY'
BEGIN
  :sql_text := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       COUNT(*),
       instance_number, 
       (select username from dba_users u where u.user_id = h.user_id) username,       
       machine,
       program,
       service_hash
  FROM &&awr_object_prefix.active_sess_history h
 WHERE 1=1
   AND user_id <> 0
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND NOT regexp_like(program, '^.*\((P[[:alnum:]]{3})\)$')
 GROUP BY
       instance_number,
       user_id,       
       machine,
       program,
       service_hash
order by 1 desc, 2, 3, 4
]';
  :sql_text_cdb := q'[
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       COUNT(*),
       instance_number,  
       (select username from dba_users u where u.user_id = h.user_id) username,       
       machine,
       program,
       service_hash,
       con_id
  FROM CDB_HIST_ACTIVE_SESS_HISTORY h
 WHERE 1=1
   AND user_id <> 0
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND NOT regexp_like(program, '^.*\((P[[:alnum:]]{3})\)$')
 GROUP BY
       instance_number,
       user_id,       
       machine,
       program,
       service_hash,
       con_id
order by 1 desc, 2, 3, 4, 5
]';
END;
/

@@&&skip_diagnostics.&&skip_ver_le_10.&&9a_pre_one.

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