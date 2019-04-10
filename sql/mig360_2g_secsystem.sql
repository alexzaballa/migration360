DEF title = 'Users With Inappropriate Tablespaces Granted';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_USERS' 'DBA_USERS'

BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
     :sql_text := q'[
SELECT * from dba_users
where (default_tablespace in ('SYSAUX','SYSTEM') or
temporary_tablespace not in
   (select tablespace_name
    from   dba_tablespaces
    where  contents = 'TEMPORARY'
    and    status = 'ONLINE'))
and oracle_maintained='N'
order by username
]';
    :sql_text_cdb := q'[
SELECT * from cdb_users
where (default_tablespace in ('SYSAUX','SYSTEM') or
temporary_tablespace not in
   (select tablespace_name
    from   cdb_tablespaces
    where  contents = 'TEMPORARY'
    and    status = 'ONLINE'))
and oracle_maintained='N'
order by username
]';
  ELSE
     :sql_text := q'[
SELECT * from dba_users
where (default_tablespace in ('SYSAUX','SYSTEM') or
temporary_tablespace not in
   (select tablespace_name
    from   dba_tablespaces
    where  contents = 'TEMPORARY'
    and    status = 'ONLINE'))
and not ( username in &&default_user_list_1. or username in &&default_user_list_2.)
order by username
]';
  END IF;
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Users With Sensitive Roles Granted';
DEF main_table = '&&dva_view_prefix.ROLE_PRIVS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       p.* from &&dva_object_prefix.role_privs p
where (p.granted_role in 
('AQ_ADMINISTRATOR_ROLE','DELETE_CATALOG_ROLE','DBA','DM_CATALOG_ROLE','EXECUTE_CATALOG_ROLE',
'EXP_FULL_DATABASE','GATHER_SYSTEM_STATISTICS','HS_ADMIN_ROLE','IMP_FULL_DATABASE',
   'JAVASYSPRIV','JAVA_ADMIN','JAVA_DEPLOY','LOGSTDBY_ADMINISTRATOR',
   'OEM_MONITOR','OLAP_DBA','RECOVERY_CATALOG_OWNER','SCHEDULER_ADMIN',
   'SELECT_CATALOG_ROLE','WM_ADMIN_ROLE','XDBADMIN','RESOURCE')
    or p.granted_role like '%ANY%')
   and p.grantee not in &&exclusion_list.
   and p.grantee not in &&exclusion_list2.
   and p.grantee in (select username from &&dva_object_prefix.users)
order by p.grantee, p.granted_role
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Users with CREATE SESSION privilege';
DEF main_table = '&&dva_view_prefix.USERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ DISTINCT 
       u.NAME "SCHEMA", d.account_status
  FROM SYS.user$ u, &&dva_object_prefix.users d
 WHERE u.NAME = d.username
   AND d.account_status NOT LIKE '%LOCKED%'
   AND u.type# = 1
   AND u.NAME != 'SYS'
   AND u.NAME != 'SYSTEM'
   AND u.user# IN (
              SELECT     grantee#
                    FROM SYS.sysauth$
              CONNECT BY PRIOR grantee# = privilege#
              START WITH privilege# =
                                     (SELECT PRIVILEGE
                                        FROM SYS.system_privilege_map
                                       WHERE NAME = 'CREATE SESSION'))
   AND u.NAME IN (SELECT DISTINCT owner
                    FROM &&dva_object_prefix.objects
                   WHERE object_type != 'SYNONYM')
ORDER BY 1
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Users with Alter Session and Alter System';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SYS_PRIVS' 'DBA_SYS_PRIVS'

BEGIN
     :sql_text := q'[
SELECT /*+ &&top_level_hints. */
    * 
FROM dba_sys_privs
WHERE privilege in ('ALTER SESSION','ALTER SYSTEM')
AND grantee <> 'DBA'
]';
    :sql_text_cdb := q'[
  -- Created by Rodrigo Jorge
SELECT /*+ &&top_level_hints. */ CON_ID, GRANTEE, PRIVILEGE, PATH FROM (
  SELECT CON_ID, GRANTEE, PRIVILEGE, PATH, RANK() OVER(PARTITION BY CON_ID, GRANTEE, PRIVILEGE ORDER BY PREF ASC) RANK3 FROM (
    SELECT CON_ID, GRANTEE, PRIVILEGE, NULL PATH, 1 PREF
    FROM   CDB_SYS_PRIVS
    WHERE  (CON_ID, GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)
    AND    privilege in ('ALTER SESSION','ALTER SYSTEM')
    UNION ALL
    SELECT CON_ID, GRANTEE, PRIVILEGE, PATH, 2 PREF FROM (
      SELECT CON_ID, GRANTEE, PRIVILEGE, PATH, RANK() OVER(PARTITION BY CON_ID, GRANTEE, PRIVILEGE ORDER BY PATH ASC) RANK2
      FROM   (SELECT A.CON_ID,
                     A.GRANTEE,
                     B.PRIVILEGE,
                     A.PATH,
                     A.NIVEL,
                     RANK() OVER(PARTITION BY A.CON_ID, A.GRANTEE, B.PRIVILEGE ORDER BY A.NIVEL ASC) RANK1
              FROM   (SELECT CON_ID,
                             GRANTEE,
                             GRANTED_ROLE FIRST_ROLE,
                             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                             LTRIM(SYS_CONNECT_BY_PATH(GRANTED_ROLE, '->'), '->') PATH,
                             LEVEL NIVEL
                      FROM   CDB_ROLE_PRIVS A
                      CONNECT BY PRIOR GRANTEE = GRANTED_ROLE AND PRIOR CON_ID = CON_ID) A,
                     CDB_SYS_PRIVS B
              WHERE  (A.CON_ID, A.GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)
            AND    B.privilege in ('ALTER SESSION','ALTER SYSTEM')
              AND    A.GRANTED_ROLE_ROOT = B.GRANTEE AND A.CON_ID = B.CON_ID)
      WHERE  RANK1 = 1
    ) WHERE  RANK2 = 1
  )
) WHERE RANK3 = 1 ORDER BY 1,2,3]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Users with EXPORT/IMPORT FULL';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLE_PRIVS' 'DBA_ROLE_PRIVS'

BEGIN
     :sql_text := q'[
SELECT /*+ &&top_level_hints. */
 * 
 FROM dba_role_privs
WHERE grantee NOT IN ('SYS','SYSTEM', 'ORACLE', 'OPS$ORACLE')
AND granted_role IN ('EXP_FULL_DATABASE', 'IMP_FULL_DATABASE')
AND grantee <> 'DBA'
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */
 * 
 FROM cdb_role_privs
WHERE grantee NOT IN ('SYS','SYSTEM', 'ORACLE', 'OPS$ORACLE')
AND granted_role IN ('EXP_FULL_DATABASE', 'IMP_FULL_DATABASE')
AND grantee <> 'DBA'
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Users granted INHERIT PRIVILEGES';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TAB_PRIVS' 'DBA_TAB_PRIVS'
BEGIN
    :sql_text := q'[
    select /*+ &&top_level_hints. */
    p.*
    from cdb_tab_privs p
    where p.privilege='INHERIT PRIVILEGES']';
END;
/
@@&&skip_ver_le_11.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Users with ANY System Privilege';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SYS_PRIVS' 'DBA_SYS_PRIVS'

BEGIN
  :sql_text := q'[
SELECT *
  FROM dba_sys_privs
  WHERE privilege LIKE '%ANY%'
  ORDER BY grantee,
    privilege
]';
  :sql_text_cdb := q'[
SELECT *
  FROM cdb_sys_privs
  WHERE privilege LIKE '%ANY%'
  ORDER BY grantee,
    privilege
]';
END;
/
@@&&9a_pre_one. 


/*****************************************************************************************/

DEF title = 'Grants by System Privileges';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SYS_PRIVS' 'DBA_SYS_PRIVS'
DEF foot = '* Users between brackets have system privileges granted indirectly.';
BEGIN
     :sql_text := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
SELECT /*+ &&top_level_hints. */ PRIVILEGE, LISTAGG(GRANTEE_FORMATED, ', ') WITHIN GROUP (ORDER BY GRANTEE) GRANTEES FROM (
  SELECT GRANTEE, PRIVILEGE, DECODE(PATH,NULL,GRANTEE,'(' || GRANTEE || ')') GRANTEE_FORMATED, RANK() OVER(PARTITION BY GRANTEE, PRIVILEGE ORDER BY PREF ASC) RANK3,
      FLOOR(((DENSE_RANK() OVER (PARTITION BY PRIVILEGE ORDER BY GRANTEE ASC))-1)/100) GROUP_ID FROM (
    SELECT GRANTEE, PRIVILEGE, NULL PATH, 1 PREF
    FROM   DBA_SYS_PRIVS
    WHERE  GRANTEE NOT IN (SELECT ROLE FROM DBA_ROLES)
    UNION ALL
    SELECT GRANTEE, PRIVILEGE, PATH, 2 PREF FROM (
      SELECT GRANTEE, PRIVILEGE, PATH, RANK() OVER(PARTITION BY GRANTEE, PRIVILEGE ORDER BY PATH ASC) RANK2
      FROM   (SELECT A.GRANTEE,
                     B.PRIVILEGE,
                     A.PATH,
                     A.NIVEL,
                     RANK() OVER(PARTITION BY A.GRANTEE, B.PRIVILEGE ORDER BY NIVEL ASC) RANK1
              FROM   (SELECT A.GRANTEE,
                             GRANTED_ROLE FIRST_ROLE,
                             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                             LTRIM(SYS_CONNECT_BY_PATH(GRANTED_ROLE, '->'), '->') PATH,
                             LEVEL NIVEL
                      FROM   DBA_ROLE_PRIVS A
                      CONNECT BY PRIOR GRANTEE = GRANTED_ROLE) A,
                     DBA_SYS_PRIVS B
              WHERE  A.GRANTEE NOT IN (SELECT ROLE FROM DBA_ROLES)
              AND    A.GRANTED_ROLE_ROOT = B.GRANTEE)
      WHERE  RANK1 = 1
    ) WHERE  RANK2 = 1
  )
) WHERE RANK3 = 1
GROUP BY PRIVILEGE, GROUP_ID
ORDER BY 1,2]';

    :sql_text_cdb := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
SELECT /*+ &&top_level_hints. */ CON_ID, PRIVILEGE, LISTAGG(GRANTEE_FORMATED, ', ') WITHIN GROUP (ORDER BY GRANTEE) GRANTEES FROM (
  SELECT CON_ID, GRANTEE, PRIVILEGE, DECODE(PATH,NULL,GRANTEE,'(' || GRANTEE || ')') GRANTEE_FORMATED, RANK() OVER(PARTITION BY CON_ID, GRANTEE, PRIVILEGE ORDER BY PREF ASC) RANK3,
      FLOOR(((DENSE_RANK() OVER (PARTITION BY CON_ID, PRIVILEGE ORDER BY GRANTEE ASC))-1)/100) GROUP_ID FROM (
    SELECT CON_ID, GRANTEE, PRIVILEGE, NULL PATH, 1 PREF
    FROM   CDB_SYS_PRIVS
    WHERE  (CON_ID, GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)
    UNION ALL
    SELECT CON_ID, GRANTEE, PRIVILEGE, PATH, 2 PREF FROM (
      SELECT CON_ID, GRANTEE, PRIVILEGE, PATH, RANK() OVER(PARTITION BY CON_ID, GRANTEE, PRIVILEGE ORDER BY PATH ASC) RANK2
      FROM   (SELECT A.CON_ID,
                     A.GRANTEE,
                     B.PRIVILEGE,
                     A.PATH,
                     A.NIVEL,
                     RANK() OVER(PARTITION BY A.CON_ID, A.GRANTEE, B.PRIVILEGE ORDER BY A.NIVEL ASC) RANK1
              FROM   (SELECT CON_ID,
                             GRANTEE,
                             GRANTED_ROLE FIRST_ROLE,
                             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                             LTRIM(SYS_CONNECT_BY_PATH(GRANTED_ROLE, '->'), '->') PATH,
                             LEVEL NIVEL
                      FROM   CDB_ROLE_PRIVS A
                      CONNECT BY PRIOR GRANTEE = GRANTED_ROLE AND PRIOR CON_ID = CON_ID) A,
                     CDB_SYS_PRIVS B
              WHERE  (A.CON_ID, A.GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)
              AND    A.GRANTED_ROLE_ROOT = B.GRANTEE AND A.CON_ID = B.CON_ID)
      WHERE  RANK1 = 1
    ) WHERE  RANK2 = 1
  )
) WHERE RANK3 = 1 GROUP BY CON_ID, PRIVILEGE, GROUP_ID ORDER BY 1,2,3]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Grants by User';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SYS_PRIVS' 'DBA_SYS_PRIVS'
DEF foot = '* Grants between brackets have system privileges granted indirectly.';
BEGIN
     :sql_text := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
WITH PRIVS_TAB AS (
    SELECT GRANTEE, PRIVILEGE, NULL PATH, 1 PREF
    FROM   DBA_SYS_PRIVS
    WHERE  GRANTEE NOT IN (SELECT ROLE FROM DBA_ROLES)
    UNION ALL
    SELECT GRANTEE, PRIVILEGE, PATH, 2 PREF FROM (
      SELECT GRANTEE, PRIVILEGE, PATH, RANK() OVER(PARTITION BY GRANTEE, PRIVILEGE ORDER BY PATH ASC) RANK2
      FROM   (SELECT A.GRANTEE,
                     B.PRIVILEGE,
                     A.PATH,
                     A.NIVEL,
                     RANK() OVER(PARTITION BY A.GRANTEE, B.PRIVILEGE ORDER BY NIVEL ASC) RANK1
              FROM   (SELECT A.GRANTEE,
                             GRANTED_ROLE FIRST_ROLE,
                             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                             LTRIM(SYS_CONNECT_BY_PATH(GRANTED_ROLE, '->'), '->') PATH,
                             LEVEL NIVEL
                      FROM   DBA_ROLE_PRIVS A
                      CONNECT BY PRIOR GRANTEE = GRANTED_ROLE) A,
                     DBA_SYS_PRIVS B
              WHERE  A.GRANTEE NOT IN (SELECT ROLE FROM DBA_ROLES)
              AND    A.GRANTED_ROLE_ROOT = B.GRANTEE)
      WHERE  RANK1 = 1
    ) WHERE  RANK2 = 1
  )
SELECT /*+ &&top_level_hints. */
  GRANTEE,
  LISTAGG(PRIVILEGE_FORMATED, ', ') WITHIN GROUP (ORDER BY PRIVILEGE) PRIVS
  FROM (
    SELECT
      GRANTEE,
      PRIVILEGE,
      DECODE(PATH,NULL,PRIVILEGE,'(' || PRIVILEGE || ')') PRIVILEGE_FORMATED,
      RANK() OVER(PARTITION BY GRANTEE, PRIVILEGE ORDER BY PREF ASC) RANK3,
      FLOOR(((DENSE_RANK() OVER (PARTITION BY GRANTEE ORDER BY PRIVILEGE ASC))-1)/100) GROUP_ID
    FROM PRIVS_TAB)
WHERE RANK3 = 1
GROUP BY GRANTEE, GROUP_ID
ORDER BY 1,2]';

    :sql_text_cdb := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
WITH PRIVS_TAB AS (
    SELECT CON_ID, GRANTEE, PRIVILEGE, NULL PATH, 1 PREF
    FROM   CDB_SYS_PRIVS
    WHERE  (CON_ID, GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)
    UNION ALL
    SELECT CON_ID, GRANTEE, PRIVILEGE, PATH, 2 PREF FROM (
      SELECT CON_ID, GRANTEE, PRIVILEGE, PATH, RANK() OVER(PARTITION BY CON_ID, GRANTEE, PRIVILEGE ORDER BY PATH ASC) RANK2
      FROM   (SELECT A.CON_ID,
                     A.GRANTEE,
                     B.PRIVILEGE,
                     A.PATH,
                     A.NIVEL,
                     RANK() OVER(PARTITION BY A.CON_ID, A.GRANTEE, B.PRIVILEGE ORDER BY A.NIVEL ASC) RANK1
              FROM   (SELECT CON_ID,
                             GRANTEE,
                             GRANTED_ROLE FIRST_ROLE,
                             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                             LTRIM(SYS_CONNECT_BY_PATH(GRANTED_ROLE, '->'), '->') PATH,
                             LEVEL NIVEL
                      FROM   CDB_ROLE_PRIVS A
                      CONNECT BY PRIOR GRANTEE = GRANTED_ROLE AND PRIOR CON_ID = CON_ID) A,
                     CDB_SYS_PRIVS B
              WHERE  (A.CON_ID, A.GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)
              AND    A.GRANTED_ROLE_ROOT = B.GRANTEE AND A.CON_ID = B.CON_ID)
      WHERE  RANK1 = 1
    ) WHERE  RANK2 = 1
  )
SELECT /*+ &&top_level_hints. */
  CON_ID,
  GRANTEE,
  LISTAGG(PRIVILEGE_FORMATED, ', ') WITHIN GROUP (ORDER BY PRIVILEGE) PRIVS
  FROM (
    SELECT
      CON_ID,
      GRANTEE,
      PRIVILEGE,
      DECODE(PATH,NULL,PRIVILEGE,'(' || PRIVILEGE || ')') PRIVILEGE_FORMATED,
      RANK() OVER(PARTITION BY CON_ID, GRANTEE, PRIVILEGE ORDER BY PREF ASC) RANK3,
      FLOOR(((DENSE_RANK() OVER (PARTITION BY CON_ID, GRANTEE ORDER BY PRIVILEGE ASC))-1)/100) GROUP_ID
    FROM PRIVS_TAB)
WHERE RANK3 = 1
GROUP BY CON_ID, GRANTEE, GROUP_ID
ORDER BY 1,2,3]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'System Grants (not default)';
DEF main_table='&&dva_view_prefix.SYS_PRIVS';
BEGIN
  :sql_text := q'[
select  /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
*  from   &&dva_object_prefix.sys_privs
where  1=1
  AND GRANTEE not in (SELECT ROLE FROM &&dva_object_prefix.roles WHERE ORACLE_MAINTAINED='Y')
  AND GRANTEE not in (SELECT USERNAME FROM &&dva_object_prefix.users WHERE ORACLE_MAINTAINED='Y')
]';
END;
/
@@&&skip_ver_le_10.&&skip_ver_le_11.&&9a_pre_one.

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/


