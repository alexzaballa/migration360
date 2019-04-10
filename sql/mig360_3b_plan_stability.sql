/*****************************************************************************************/
--SQL Patches

DEF title = 'SQL Patches';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SQL_PATCHES' 'DBA_SQL_PATCHES'
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.sql_patches
 ORDER BY
       created DESC
]';
  :sql_text_cdb := q'[
SELECT *
  FROM CDB_SQL_PATCHES
 ORDER BY
       con_id,
       created DESC
]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--SQL Profiles

DEF title = 'SQL Profiles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SQL_PROFILES' 'DBA_SQL_PROFILES'
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.sql_profiles
 ORDER BY
       created DESC
]';
  :sql_text_cdb := q'[
SELECT *
  FROM CDB_SQL_PROFILES
 ORDER BY
       con_id,
       created DESC
]';
END;
/
@@&&skip_tuning.&&9a_pre_one. 

/*****************************************************************************************/
--SQL Plan Baselines

DEF title = 'SQL Plan Baselines';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SQL_PLAN_BASELINES' 'DBA_SQL_PLAN_BASELINES'
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.sql_plan_baselines
 ORDER BY
       created DESC
]';
  :sql_text_cdb := q'[
SELECT *
  FROM CDB_SQL_PLAN_BASELINES
 ORDER BY
       con_id,
       created DESC
]';
END;
/
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
