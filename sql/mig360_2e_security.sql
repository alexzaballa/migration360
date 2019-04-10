DEF title = 'Users';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'
EXEC :sql_text := 'SELECT * FROM dba_users ORDER BY username';
EXEC :sql_text_cdb := 'SELECT * FROM CDB_USERS ORDER BY username';
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Default Users';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'
BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
    :sql_text := q'[
SELECT *
FROM   &&main_table.
where  oracle_maintained='Y'
ORDER BY username
    ]';
  ELSE
    :sql_text := q'[
SELECT *
FROM   DBA_USERS
where  (username in &&default_user_list_1. or username in &&default_user_list_2.)
ORDER BY username
    ]';
  END IF;
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/
DEF title = 'Non Default Users';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'
BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
  :sql_text := q'[
SELECT *
FROM   &&main_table.
where  oracle_maintained='N'
ORDER BY username
  ]';
  ELSE
  :sql_text := q'[
SELECT *
FROM   dba_users
where  not (username in &&default_user_list_1. or username in &&default_user_list_2.)
ORDER BY username
  ]';
  END IF;
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Wrong Default Users';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'
BEGIN
  :sql_text := q'[
WITH result as (
  SELECT * FROM &&main_table.
  where oracle_maintained = 'Y'
  minus
  SELECT * FROM &&main_table.
  where (username in &&default_user_list_1. or username in &&default_user_list_2.)
) select * from result order by username
  ]';
END;
/
@@&&skip_ver_le_11.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Password file users';
DEF main_table = 'GV$PWFILE_USERS';
BEGIN
  :sql_text := q'[  
SELECT * FROM gv$pwfile_users
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Inactive Users';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'
BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
    :sql_text := q'[
SELECT * FROM &&main_table.
WHERE last_login < sysdate-30
ORDER BY last_login
    ]';
  ELSE
    IF '&&diagnostics_pack.' = 'Y' THEN
      :sql_text := q'[
SELECT u.user_id,u.username,u.account_status,'30 days or more innactive - ASH' days
FROM dba_users u
WHERE NOT EXISTS (
  SELECT 'x'
  from  dba_hist_active_sess_history a
  where sample_time > sysdate-30
  and a.user_id = u.user_id)
union all
SELECT u.user_id,u.username,u.account_status,'30 days or more innactive - AUDIT' days
FROM dba_users u
WHERE NOT EXISTS (
  SELECT 'x'
  FROM dba_audit_trail a
  WHERE a.username = u.username
  AND a.logoff_time > sysdate-30)
order by 1
      ]';
    ELSE
      :sql_text := q'[
SELECT u.user_id,u.username,u.account_status,'30 days or more innactive - AUDIT' days
FROM dba_users u
WHERE NOT EXISTS (
  SELECT 'x'
  FROM dba_audit_trail a
  WHERE a.username = u.username
  AND a.logoff_time > sysdate-30)
order by 1
      ]';
    END IF;
  END IF;
END;
/
--@@&&9a_pre_one.
--Diagnostic pack
--Too slow

/*****************************************************************************************/

DEF title = 'Expired or Locked Users';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'
EXEC :sql_text := q'[SELECT * FROM DBA_USERS WHERE account_status != 'OPEN' ORDER BY account_status,username]';
EXEC :sql_text_cdb := q'[SELECT * FROM CDB_USERS WHERE account_status != 'OPEN' ORDER BY con_id, account_status,username]';
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Proxy Users';
DEF main_table = 'PROXY_USERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ *
  FROM proxy_users
 ORDER BY client
]';
END;
/
@@&&9a_pre_one.



/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/


