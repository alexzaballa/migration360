DEF title = 'Tasks Statistics';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_CLIENT' 'DBA_AUTOTASK_CLIENT'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays statistical data for each automated maintenance task over 7-day and 30-day periods.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Tasks History';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_CLIENT_HISTORY' 'DBA_AUTOTASK_CLIENT_HISTORY'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays per-window history of job execution counts for each automated maintenance task.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Running Jobs';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_CLIENT_JOB' 'DBA_AUTOTASK_CLIENT_JOB'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays information about currently running Scheduler jobs created for automated maintenance tasks.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Jobs History';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_JOB_HISTORY' 'DBA_AUTOTASK_JOB_HISTORY'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays the history of automated maintenance task job runs. Jobs are added to this view after they finish executing.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Operations';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_OPERATION' 'DBA_AUTOTASK_OPERATION'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays all automated maintenance task operations for each client.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Schedule';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_SCHEDULE' 'DBA_AUTOTASK_SCHEDULE'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text' 'start_time'
DEF foot = 'Displays the schedule of maintenance windows for the next 32 days for each client.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Status';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_STATUS' 'DBA_AUTOTASK_STATUS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays status information for automated maintenance.'
@@&&skip_ver_le_10.&&skip_ver_le_11.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Tasks';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_TASK' 'DBA_AUTOTASK_TASK'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays information about current and past automated maintenance tasks.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Windows';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_WINDOW_CLIENTS' 'DBA_AUTOTASK_WINDOW_CLIENTS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text' 'window_next_time'
DEF foot = 'Displays the windows that belong to MAINTENANCE_WINDOW_GROUP, along with the Enabled or Disabled status for the window for each maintenance task.'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Windows History';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_AUTOTASK_WINDOW_HISTORY' 'DBA_AUTOTASK_WINDOW_HISTORY'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
DEF foot = 'Displays historical information for automated maintenance task windows.'
@@&&9a_pre_one.


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/
