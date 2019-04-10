/*****************************************************************************************/
--

DEF title = 'Golden Gate Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 WHERE name like '%goldengate%'
 ORDER BY
       name,
       inst_id,
       ordinal
]';
END;
/
@@&&9a_pre_one.


-- TO add in future release

--MOS Note:1298562.1:
--Oracle GoldenGate database Complete Database Profile check script for Oracle DB (All Schemas) Classic Extract 

--MOS Note: 1296168.1
--Oracle GoldenGate database Schema Profile check script for Oracle DB

/*****************************************************************************************/

DEF title = 'Golden Gate Process';
@@&&fc_def_output_file. out_filename 'gg&&current_time..txt'

COL cmd_gg NEW_V cmd_gg NOPRI
--select ' echo `ps -ef | /usr/bin/grep "./mgr PARAMFILE" | /usr/bin/grep -v grep`'
select ' if [ `ps -ef | grep "./mgr PARAMFILE" | grep -v grep | wc -l` -ge 1 ]; then echo `ps -ef | grep "./mgr PARAMFILE" | grep -v grep`; fi'
 cmd_gg from dual;
COL cmd_gg NEW_V clear

HOS &&cmd_gg. > &&out_filename.
UNDEF cmd_gg

COL cmd_gg2 NEW_V cmd_gg2 NOPRI
--select '
--if [ `ps -ef | /usr/bin/grep "./mgr PARAMFILE" | /usr/bin/grep -v /usr/bin/grep | /usr/bin/wc -l` -ge 1 ]; then echo "Golden Gate Manager is running."; fi'
select ' if [ `ps -ef | grep "./mgr PARAMFILE" | grep -v grep | wc -l` -ge 1 ]; then echo "Golden Gate Manager is running."; fi'
 cmd_gg2 from dual;
COL cmd_gg2 NEW_V clear

HOS &&cmd_gg2. >> &&out_filename.
UNDEF cmd_gg2

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
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
