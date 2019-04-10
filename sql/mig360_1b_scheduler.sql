
DEF title = 'Legacy Jobs';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_JOBS' 'DBA_JOBS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Legacy Jobs Running';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_JOBS_RUNNING' 'DBA_JOBS_RUNNING'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Jobs';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_JOBS' 'DBA_SCHEDULER_JOBS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text' 'owner, job_name'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Job Log for past 7 days';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_JOB_LOG' 'DBA_SCHEDULER_JOB_LOG'
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM &&main_table.
 WHERE log_date > SYSDATE - 7
 ORDER BY
       log_id DESC,
       log_date DESC
';
END;
/
--@@&&9a_pre_one.
--Too slow

/*****************************************************************************************/
DEF title = 'Job Run Details for past 7 days';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_JOB_RUN_DETAILS' 'DBA_SCHEDULER_JOB_RUN_DETAILS'
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM &&main_table.
 WHERE log_date > SYSDATE - 7
 ORDER BY
       log_id DESC,
       log_date DESC
';
END;
/
--@@&&9a_pre_one.
--Too slow

/*****************************************************************************************/
DEF title = 'Chains';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_CHAINS' 'DBA_SCHEDULER_CHAINS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Chain Rules';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_CHAIN_RULES' 'DBA_SCHEDULER_CHAIN_RULES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Chain Steps';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_CHAIN_STEPS' 'DBA_SCHEDULER_CHAIN_STEPS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Credentials';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_CREDENTIALS' 'DBA_SCHEDULER_CREDENTIALS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Database Destinations';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_DB_DESTS' 'DBA_SCHEDULER_DB_DESTS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Destinations';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_DESTS' 'DBA_SCHEDULER_DESTS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'External Destinations';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_EXTERNAL_DESTS' 'DBA_SCHEDULER_EXTERNAL_DESTS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'File Watchers';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_FILE_WATCHERS' 'DBA_SCHEDULER_FILE_WATCHERS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Global Attribute';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_GLOBAL_ATTRIBUTE' 'DBA_SCHEDULER_GLOBAL_ATTRIBUTE'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Groups';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_GROUPS' 'DBA_SCHEDULER_GROUPS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Group Members';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_GROUP_MEMBERS' 'DBA_SCHEDULER_GROUP_MEMBERS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Job Arguments';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_JOB_ARGS' 'DBA_SCHEDULER_JOB_ARGS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Job Classes';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_JOB_CLASSES' 'DBA_SCHEDULER_JOB_CLASSES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Job Destinations';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_JOB_DESTS' 'DBA_SCHEDULER_JOB_DESTS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Job Roles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_JOB_ROLES' 'DBA_SCHEDULER_JOB_ROLES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Notifications';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_NOTIFICATIONS' 'DBA_SCHEDULER_NOTIFICATIONS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Programs';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_PROGRAMS' 'DBA_SCHEDULER_PROGRAMS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Program Arguments';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_PROGRAM_ARGS' 'DBA_SCHEDULER_PROGRAM_ARGS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Remote Databases';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_REMOTE_DATABASES' 'DBA_SCHEDULER_REMOTE_DATABASES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Remote Jobs';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_REMOTE_JOBSTATE' 'DBA_SCHEDULER_REMOTE_JOBSTATE'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Running Chains';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_RUNNING_CHAINS' 'DBA_SCHEDULER_RUNNING_CHAINS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Jobs Running';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_RUNNING_JOBS' 'DBA_SCHEDULER_RUNNING_JOBS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Schedules';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_SCHEDULES' 'DBA_SCHEDULER_SCHEDULES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Windows';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_WINDOWS' 'DBA_SCHEDULER_WINDOWS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text' 'NEXT_START_DATE'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Window Group Members';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_WINGROUP_MEMBERS' 'DBA_SCHEDULER_WINGROUP_MEMBERS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Window Details';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_WINDOW_DETAILS' 'DBA_SCHEDULER_WINDOW_DETAILS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text' 'log_date'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Window Group';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_WINDOW_GROUPS' 'DBA_SCHEDULER_WINDOW_GROUPS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Window Log';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SCHEDULER_WINDOW_LOG' 'DBA_SCHEDULER_WINDOW_LOG'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text' 'log_date'
@@&&9a_pre_one.


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

