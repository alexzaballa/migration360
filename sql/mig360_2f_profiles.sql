DEF title = 'Profiles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_PROFILES' 'DBA_PROFILES'
BEGIN
 :sql_text := q'[
SELECT p1.profile, p1.resource_name, p1.resource_type, p1.limit, decode(p1.limit,'DEFAULT',pd.limit,p1.limit) real_limit
FROM dba_profiles p1, dba_profiles pd
WHERE pd.profile='DEFAULT' and p1.resource_name=pd.resource_name and p1.resource_type=pd.resource_type
ORDER BY 1,2
]';
 :sql_text_cdb := q'[
SELECT p1.con_id, p1.common, p1.profile, p1.resource_name, p1.resource_type, p1.limit, decode(p1.limit,'DEFAULT',pd.limit,p1.limit) real_limit
FROM cdb_profiles p1, cdb_profiles pd
WHERE pd.profile='DEFAULT' and p1.resource_name=pd.resource_name and p1.resource_type=pd.resource_type and p1.con_id=pd.con_id
ORDER BY 1,2,3,4
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Profiles Pivoted';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_PROFILES' 'DBA_PROFILES'
BEGIN
 :sql_text := q'[
SELECT
  PROFILE,
  COMPOSITE_LIMIT,
  CONNECT_TIME,
  CPU_PER_CALL,
  CPU_PER_SESSION,
  FAILED_LOGIN_ATTEMPTS,
  IDLE_TIME,
  LOGICAL_READS_PER_CALL,
  LOGICAL_READS_PER_SESSION,
  PASSWORD_GRACE_TIME,
  PASSWORD_LIFE_TIME,
  PASSWORD_LOCK_TIME,
  PASSWORD_REUSE_MAX,
  PASSWORD_REUSE_TIME,
  PASSWORD_VERIFY_FUNCTION,
  PRIVATE_SGA,
  SESSIONS_PER_USER
FROM (
SELECT p1.profile, p1.resource_name, decode(p1.limit,'DEFAULT',pd.limit,p1.limit) limit
FROM dba_profiles p1, dba_profiles pd
WHERE pd.profile='DEFAULT' and p1.resource_name=pd.resource_name and p1.resource_type=pd.resource_type
)
PIVOT (
  MAX(LIMIT) FOR RESOURCE_NAME IN (
    'COMPOSITE_LIMIT' COMPOSITE_LIMIT,
    'CONNECT_TIME' CONNECT_TIME,
    'CPU_PER_CALL' CPU_PER_CALL,
    'CPU_PER_SESSION' CPU_PER_SESSION,
    'FAILED_LOGIN_ATTEMPTS' FAILED_LOGIN_ATTEMPTS,
    'IDLE_TIME' IDLE_TIME,
    'LOGICAL_READS_PER_CALL' LOGICAL_READS_PER_CALL,
    'LOGICAL_READS_PER_SESSION' LOGICAL_READS_PER_SESSION,
    'PASSWORD_GRACE_TIME' PASSWORD_GRACE_TIME,
    'PASSWORD_LIFE_TIME' PASSWORD_LIFE_TIME,
    'PASSWORD_LOCK_TIME' PASSWORD_LOCK_TIME,
    'PASSWORD_REUSE_MAX' PASSWORD_REUSE_MAX,
    'PASSWORD_REUSE_TIME' PASSWORD_REUSE_TIME,
    'PASSWORD_VERIFY_FUNCTION' PASSWORD_VERIFY_FUNCTION,
    'PRIVATE_SGA' PRIVATE_SGA,
    'SESSIONS_PER_USER' SESSIONS_PER_USER
  )
)
ORDER BY 1
]';
 :sql_text_cdb := q'[
SELECT
  CON_ID,
  COMMON,
  PROFILE,
  COMPOSITE_LIMIT,
  CONNECT_TIME,
  CPU_PER_CALL,
  CPU_PER_SESSION,
  FAILED_LOGIN_ATTEMPTS,
  IDLE_TIME,
  LOGICAL_READS_PER_CALL,
  LOGICAL_READS_PER_SESSION,
  PASSWORD_GRACE_TIME,
  PASSWORD_LIFE_TIME,
  PASSWORD_LOCK_TIME,
  PASSWORD_REUSE_MAX,
  PASSWORD_REUSE_TIME,
  PASSWORD_VERIFY_FUNCTION,
  PRIVATE_SGA,
  SESSIONS_PER_USER
FROM (
SELECT p1.con_id, p1.common, p1.profile, p1.resource_name, decode(p1.limit,'DEFAULT',pd.limit,p1.limit) limit
FROM cdb_profiles p1, cdb_profiles pd
WHERE pd.profile='DEFAULT' and p1.resource_name=pd.resource_name and p1.resource_type=pd.resource_type and p1.con_id=pd.con_id
)
PIVOT (
  MAX(LIMIT) FOR RESOURCE_NAME IN (
    'COMPOSITE_LIMIT' COMPOSITE_LIMIT,
    'CONNECT_TIME' CONNECT_TIME,
    'CPU_PER_CALL' CPU_PER_CALL,
    'CPU_PER_SESSION' CPU_PER_SESSION,
    'FAILED_LOGIN_ATTEMPTS' FAILED_LOGIN_ATTEMPTS,
    'IDLE_TIME' IDLE_TIME,
    'LOGICAL_READS_PER_CALL' LOGICAL_READS_PER_CALL,
    'LOGICAL_READS_PER_SESSION' LOGICAL_READS_PER_SESSION,
    'PASSWORD_GRACE_TIME' PASSWORD_GRACE_TIME,
    'PASSWORD_LIFE_TIME' PASSWORD_LIFE_TIME,
    'PASSWORD_LOCK_TIME' PASSWORD_LOCK_TIME,
    'PASSWORD_REUSE_MAX' PASSWORD_REUSE_MAX,
    'PASSWORD_REUSE_TIME' PASSWORD_REUSE_TIME,
    'PASSWORD_VERIFY_FUNCTION' PASSWORD_VERIFY_FUNCTION,
    'PRIVATE_SGA' PRIVATE_SGA,
    'SESSIONS_PER_USER' SESSIONS_PER_USER
  )
)
ORDER BY 1, 2, 3
]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Users x Profiles Pivoted';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_PROFILES' 'DBA_PROFILES'
BEGIN
 :sql_text := q'[
SELECT a.username, a.account_status, p.*
from dba_users a, (
SELECT
  PROFILE,
  COMPOSITE_LIMIT,
  CONNECT_TIME,
  CPU_PER_CALL,
  CPU_PER_SESSION,
  FAILED_LOGIN_ATTEMPTS,
  IDLE_TIME,
  LOGICAL_READS_PER_CALL,
  LOGICAL_READS_PER_SESSION,
  PASSWORD_GRACE_TIME,
  PASSWORD_LIFE_TIME,
  PASSWORD_LOCK_TIME,
  PASSWORD_REUSE_MAX,
  PASSWORD_REUSE_TIME,
  PASSWORD_VERIFY_FUNCTION,
  PRIVATE_SGA,
  SESSIONS_PER_USER
FROM (
SELECT p1.profile, p1.resource_name, decode(p1.limit,'DEFAULT',pd.limit,p1.limit) limit
FROM dba_profiles p1, dba_profiles pd
WHERE pd.profile='DEFAULT' and p1.resource_name=pd.resource_name and p1.resource_type=pd.resource_type
)
PIVOT (
  MAX(LIMIT) FOR RESOURCE_NAME IN (
    'COMPOSITE_LIMIT' COMPOSITE_LIMIT,
    'CONNECT_TIME' CONNECT_TIME,
    'CPU_PER_CALL' CPU_PER_CALL,
    'CPU_PER_SESSION' CPU_PER_SESSION,
    'FAILED_LOGIN_ATTEMPTS' FAILED_LOGIN_ATTEMPTS,
    'IDLE_TIME' IDLE_TIME,
    'LOGICAL_READS_PER_CALL' LOGICAL_READS_PER_CALL,
    'LOGICAL_READS_PER_SESSION' LOGICAL_READS_PER_SESSION,
    'PASSWORD_GRACE_TIME' PASSWORD_GRACE_TIME,
    'PASSWORD_LIFE_TIME' PASSWORD_LIFE_TIME,
    'PASSWORD_LOCK_TIME' PASSWORD_LOCK_TIME,
    'PASSWORD_REUSE_MAX' PASSWORD_REUSE_MAX,
    'PASSWORD_REUSE_TIME' PASSWORD_REUSE_TIME,
    'PASSWORD_VERIFY_FUNCTION' PASSWORD_VERIFY_FUNCTION,
    'PRIVATE_SGA' PRIVATE_SGA,
    'SESSIONS_PER_USER' SESSIONS_PER_USER
  )
)
) p where a.profile = p.profile
ORDER BY 1
]';
 :sql_text_cdb := q'[
SELECT a.con_id con_id_user, a.username, a.account_status, p.*
from cdb_users a, (
SELECT
  CON_ID,
  COMMON,
  PROFILE,
  COMPOSITE_LIMIT,
  CONNECT_TIME,
  CPU_PER_CALL,
  CPU_PER_SESSION,
  FAILED_LOGIN_ATTEMPTS,
  IDLE_TIME,
  LOGICAL_READS_PER_CALL,
  LOGICAL_READS_PER_SESSION,
  PASSWORD_GRACE_TIME,
  PASSWORD_LIFE_TIME,
  PASSWORD_LOCK_TIME,
  PASSWORD_REUSE_MAX,
  PASSWORD_REUSE_TIME,
  PASSWORD_VERIFY_FUNCTION,
  PRIVATE_SGA,
  SESSIONS_PER_USER
FROM (
SELECT p1.con_id, p1.common, p1.profile, p1.resource_name, decode(p1.limit,'DEFAULT',pd.limit,p1.limit) limit
FROM cdb_profiles p1, cdb_profiles pd
WHERE pd.profile='DEFAULT' and p1.resource_name=pd.resource_name and p1.resource_type=pd.resource_type and p1.con_id=pd.con_id
)
PIVOT (
  MAX(LIMIT) FOR RESOURCE_NAME IN (
    'COMPOSITE_LIMIT' COMPOSITE_LIMIT,
    'CONNECT_TIME' CONNECT_TIME,
    'CPU_PER_CALL' CPU_PER_CALL,
    'CPU_PER_SESSION' CPU_PER_SESSION,
    'FAILED_LOGIN_ATTEMPTS' FAILED_LOGIN_ATTEMPTS,
    'IDLE_TIME' IDLE_TIME,
    'LOGICAL_READS_PER_CALL' LOGICAL_READS_PER_CALL,
    'LOGICAL_READS_PER_SESSION' LOGICAL_READS_PER_SESSION,
    'PASSWORD_GRACE_TIME' PASSWORD_GRACE_TIME,
    'PASSWORD_LIFE_TIME' PASSWORD_LIFE_TIME,
    'PASSWORD_LOCK_TIME' PASSWORD_LOCK_TIME,
    'PASSWORD_REUSE_MAX' PASSWORD_REUSE_MAX,
    'PASSWORD_REUSE_TIME' PASSWORD_REUSE_TIME,
    'PASSWORD_VERIFY_FUNCTION' PASSWORD_VERIFY_FUNCTION,
    'PRIVATE_SGA' PRIVATE_SGA,
    'SESSIONS_PER_USER' SESSIONS_PER_USER
  )
)
) p where a.profile = p.profile and (a.con_id = p.con_id or p.common='YES')
ORDER BY 1, 2, 3
]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Profile Verification Functions';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_PROFILES' 'DBA_PROFILES'

BEGIN
   :sql_text := q'[
SELECT /*+ &&top_level_hints. */ 
       owner, object_name, created, last_ddl_time, status
  FROM dba_objects
 WHERE object_name IN (SELECT limit
                         FROM dba_profiles
                        WHERE resource_name = 'PASSWORD_VERIFY_FUNCTION')
 ORDER BY 1,2
]';

   :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ 
       con_id,owner, object_name, created, last_ddl_time, status
  FROM cdb_objects
 WHERE object_name IN (SELECT limit
                         FROM cdb_profiles
                        WHERE resource_name = 'PASSWORD_VERIFY_FUNCTION')
 ORDER BY 1,2,3
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/


