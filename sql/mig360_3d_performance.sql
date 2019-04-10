/*****************************************************************************************/
--

DEF title = 'Result Cache related parameters';
DEF main_table = '&&gv_view_prefix.SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       inst_id, name "PARAMETER", value, isdefault, ismodified
  FROM &&gv_object_prefix.system_parameter2
 WHERE name IN ('result_cache_mode','result_cache_max_size','result_cache_max_result')
 ORDER BY 2,1,3
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       con_id, inst_id, name "PARAMETER", value, isdefault, ismodified
  FROM &&gv_object_prefix.system_parameter2
 WHERE name IN ('result_cache_mode','result_cache_max_size','result_cache_max_result')
 ORDER BY 1,3,2,4
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Result Cache status';
DEF main_table = 'DBMS_RESULT_CACHE';
BEGIN
  :sql_text := q'[
SELECT dbms_result_cache.status FROM dual
]';
END;
/
@@&&skip_ver_le_10.&&skip_ver_le_11_1.&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Result Cache memory';
DEF main_table = '&&gv_view_prefix.RESULT_CACHE_MEMORY';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       inst_id, free, count(*)
  FROM &&gv_object_prefix.result_cache_memory
 GROUP BY inst_id, free
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       con_id, inst_id, free, count(*)
  FROM &&gv_object_prefix.result_cache_memory
 GROUP BY con_id, inst_id, free
 order by 1, 2, 4 desc
]';
END;
/
@@&&skip_ver_le_10.&&skip_ver_le_11_1.&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Result Cache statistics';
DEF main_table = '&&gv_view_prefix.RESULT_CACHE_STATISTICS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       inst_id, name, value
  FROM &&gv_object_prefix.result_cache_statistics
 ORDER BY 1, 2
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       con_id, inst_id, name, value
  FROM &&gv_object_prefix.result_cache_statistics
 ORDER BY 1, 2, 3
]';
END;
/
@@&&skip_ver_le_10.&&skip_ver_le_11_1.&&9a_pre_one.


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
