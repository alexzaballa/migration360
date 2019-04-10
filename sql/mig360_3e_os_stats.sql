/*****************************************************************************************/
--Operating System (OS) Statistics

DEF title = 'Operating System (OS) Statistics';
DEF main_table = '&&gv_view_prefix.OSSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.osstat
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