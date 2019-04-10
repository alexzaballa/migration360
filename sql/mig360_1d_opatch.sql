DEF title = 'OPatch lspatches - oracle';
@@&&fc_def_output_file. out_filename 'opatch_lspatches.txt'

HOS $ORACLE_HOME/OPatch/opatch lspatches > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ opatch lspatches';
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'OPatch lsinv - oracle';
@@&&fc_def_output_file. out_filename 'opatch_lsinv_details.txt'

HOS $ORACLE_HOME/OPatch/opatch lsinv -details > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ opatch lsinv -details';
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'OPatch lsinv all - oracle';
@@&&fc_def_output_file. out_filename 'opatch_lsinv_all.txt'

HOS $ORACLE_HOME/OPatch/opatch lsinv -all > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ opatch lsinv -all';
@@&&9a_pre_one.

/*****************************************************************************************/

@@&&fc_def_output_file. step_file 'step_file.sql'

-- lsnrctl status | &&cmd_grep. "Listener Parameter File" | &&cmd_awk. '{print $4}' | &&cmd_awk. -F'/[^/]*$' '{print $1}' | &&cmd_awk. -F'/[^/]*$' '{print $1}' | &&cmd_awk. -F'/[^/]*$' '{print $1}' > &&step_file.
HOS echo "DEF mig360_grid_home = '"$(ps -ef | &&cmd_grep. ocssd.bin | &&cmd_grep. -v &&cmd_grep. | &&cmd_awk. -F'/[^/]*$' '{print $1}' | &&cmd_awk. -F'/[^/]*$' '{print $1}' | &&cmd_awk. -F'^[^/]*/' '{print "/"$2}')"'" > &&step_file.
@&&step_file.
HOS rm -f &&step_file.
UNDEF step_file

/*****************************************************************************************/

DEF title = 'OPatch lspatches - grid';
@@&&fc_def_output_file. out_filename 'opatch_grid_lspatches.txt'

HOS $ORACLE_HOME/OPatch/opatch lspatches -oh &&mig360_grid_home. > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ opatch lspatches -oh &&mig360_grid_home.';
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'OPatch lsinv - grid';
@@&&fc_def_output_file. out_filename 'opatch_grid_lsinv_details.txt'

HOS $ORACLE_HOME/OPatch/opatch lsinv -details -oh &&mig360_grid_home. > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ opatch lsinv -details -oh &&mig360_grid_home.';
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'OPatch lsinv all - grid';
@@&&fc_def_output_file. out_filename 'opatch_grid_lsinv_all.txt'

HOS $ORACLE_HOME/OPatch/opatch lsinv -all -oh &&mig360_grid_home. > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ opatch lsinv -all -oh &&mig360_grid_home.';
@@&&9a_pre_one.

/*****************************************************************************************/

UNDEF mig360_grid_home
UNDEF out_filename


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

