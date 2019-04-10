/*****************************************************************************************/

DEF main_table = '&&awr_hist_prefix.ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text_backup := q'[
WITH
hist AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class END wait_class,
       ROW_NUMBER () OVER (ORDER BY COUNT(*) DESC) rn,
       COUNT(*) samples
  FROM &&awr_object_prefix.active_sess_history h
 WHERE @filter_predicate@
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&mig360_dbid.
   AND (session_state = 'ON CPU' OR wait_class <> 'Idle')
 GROUP BY
       CASE session_state WHEN 'ON CPU' THEN session_state ELSE wait_class END
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */ SUM(samples) samples FROM hist
)
SELECT h.wait_class||' ('||ROUND(100 * h.samples / t.samples, 1)||'%)' bucket,
       ROUND(100 * h.samples / t.samples, 1) percent,
       &&wait_class_colors.
       &&wait_class_colors2.
       &&wait_class_colors3.
       &&wait_class_colors4. color,
       h.samples||' 10s-samples ('||ROUND(100 * h.samples / t.samples, 1)||'% of DB Time)' tooltip
  FROM hist h,
       total t
 ORDER BY 2 DESC NULLS LAST
]';
END;
/


/*****************************************************************************************/

SELECT ', between '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 1, 'YYYY-MM-DD HH24:MM:SS')||' and '||TO_CHAR(TO_TIMESTAMP('&&tool_sysdate.', 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MM:SS') between_times FROM DUAL;


SELECT '&&between_dates.' between_times FROM DUAL;

DEF skip_bch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Classes for Cluster for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Classes for Instance 1 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 1');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Classes for Instance 2 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 2');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Classes for Instance 3 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 3');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Classes for Instance 4 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 4');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Classes for Instance 5 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 5');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Classes for Instance 6 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 6');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Classes for Instance 7 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 7');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF skip_bch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM &&gv_object_prefix.instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Classes for Instance 8 for &&history_days. days of history';
DEF title_suffix = '&&between_times.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'instance_number = 8');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_bch = 'Y';
DEF skip_pch = 'Y';
DEF vaxis = '';
DEF haxis = '';
DEF skip_all = '';
DEF title_suffix = '';
EXEC :sql_text := '';

