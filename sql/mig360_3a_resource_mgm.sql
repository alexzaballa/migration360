DEF title = 'Consumer Groups';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_RSRC_CONSUMER_GROUPS' 'DBA_RSRC_CONSUMER_GROUPS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Consumer Group Users and Roles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_RSRC_CONSUMER_GROUP_PRIVS' 'DBA_RSRC_CONSUMER_GROUP_PRIVS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resource Groups Mappings';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_RSRC_GROUP_MAPPINGS' 'DBA_RSRC_GROUP_MAPPINGS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

vDEF title = 'Resource Groups Mapping Priorities';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_RSRC_MAPPING_PRIORITY' 'DBA_RSRC_MAPPING_PRIORITY'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resource Plan Directives';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_RSRC_PLAN_DIRECTIVES' 'DBA_RSRC_PLAN_DIRECTIVES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resource Plans';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_RSRC_PLANS' 'DBA_RSRC_PLANS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Active Resource Consumer Groups';
DEF main_table = 'GV$RSRC_CONSUMER_GROUP';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resource Consumer Group History';
DEF main_table = 'GV$RSRC_CONS_GROUP_HISTORY';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resource Plan';
DEF main_table = 'GV$RSRC_PLAN';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resource Plan History';
DEF main_table = 'GV$RSRC_PLAN_HISTORY';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'RM Stats per Session';
DEF main_table = 'GV$RSRC_SESSION_INFO';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
--@@&&9a_pre_one.
--Too Slow

/*****************************************************************************************/

DEF title = 'Resources Consumed per Consumer Group';
DEF main_table = 'GV$RSRCMGRMETRIC';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Resources Consumed History';
DEF main_table = 'GV$RSRCMGRMETRIC_HISTORY';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

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