/*****************************************************************************************/
--

DEF main_table = '&&awr_hist_prefix.SYSMETRIC_HISTORY';
DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF tit_01 = 'Max';
DEF tit_02 = '95th Percentile';
DEF tit_03 = '90th Percentile';
DEF tit_04 = '85th Percentile';
DEF tit_05 = '80th Percentile';
DEF tit_06 = '75th Percentile';
DEF tit_07 = 'Median';
DEF tit_08 = 'Avg';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := q'[
WITH 
per_instance_and_hour AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       MIN(begin_time) begin_time, 
       MAX(end_time) end_time, 
       MAX(value) value_max,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY value) value_95p,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY value) value_90p,
       PERCENTILE_DISC(0.85) WITHIN GROUP (ORDER BY value) value_85p,
       PERCENTILE_DISC(0.80) WITHIN GROUP (ORDER BY value) value_80p,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY value) value_75p,
       MEDIAN(value) value_med,
       AVG(value) value_avg
  FROM &&awr_object_prefix.sysmetric_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&mig360_dbid.
   AND group_id = 2 /* 1 minute intervals */
   AND metric_name = '@metric_name@'
   AND value >= 0
 GROUP BY
       snap_id,
       instance_number
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), 'YYYY-MM-DD HH24:MI:SS') begin_time,
       TO_CHAR(MIN(end_time), 'YYYY-MM-DD HH24:MI:SS') end_time,
       ROUND(SUM(value_max), 1) "Max",
       ROUND(SUM(value_95p), 1) "95th Percentile",
       ROUND(SUM(value_90p), 1) "90th Percentile",
       ROUND(SUM(value_85p), 1) "85th Percentile",
       ROUND(SUM(value_80p), 1) "80th Percentile",
       ROUND(SUM(value_75p), 1) "75th Percentile",
       ROUND(SUM(value_med), 1) "Median",
       ROUND(SUM(value_avg), 1) "Avg",
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM per_instance_and_hour
 GROUP BY
       snap_id
 ORDER BY
       snap_id
]';
END;
/


DEF vbaseline = '';

DEF skip_lch = '';
DEF title = 'I/O Megabytes per Second';
DEF vaxis = 'Megabtyes per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max/Perc/Med/Avg refer to statistics within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
@@&&skip_all.&&skip_diagnostics.&&9a_pre_one.

DEF main_table = '&&awr_hist_prefix.SYSMETRIC_HISTORY';
DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF tit_01 = 'Max';
DEF tit_02 = '95th Percentile';
DEF tit_03 = '90th Percentile';
DEF tit_04 = '85th Percentile';
DEF tit_05 = '80th Percentile';
DEF tit_06 = '75th Percentile';
DEF tit_07 = 'Median';
DEF tit_08 = 'Avg';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

DEF skip_lch = '';
DEF title = 'I/O Requests per Second';
DEF vaxis = 'Requests per Second';
DEF abstract = '"&&title." with unit of "&&vaxis.", based on 1-minute samples. Max/Perc/Med/Avg refer to statistics within each hour.<br />'
DEF foot = 'Max values represent the peak of the metric within each hour and among the 60 samples on it. Each sample represents in turn an average within a 1-minute interval.'
EXEC :sql_text := REPLACE(:sql_text_backup, '@metric_name@', '&&title.');
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

/*****************************************************************************************/