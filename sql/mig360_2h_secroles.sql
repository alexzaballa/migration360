DEF title = 'Roles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLES' 'DBA_ROLES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Default Roles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLES' 'DBA_ROLES'
BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
  :sql_text := q'[
select * from &&main_table.
where oracle_maintained='Y'
  ]';
  ELSE
  :sql_text := q'[
select * from dba_roles
where (
  role in &&default_role_list_1. or
  role in &&default_role_list_2. or
  role in &&default_role_list_3. or
  role in &&default_role_list_4. or
  role in &&default_role_list_5. or
  role in &&default_role_list_6. or
  role in &&default_role_list_7. or
  role in &&default_role_list_8. or
  role in &&default_role_list_9.
)
  ]';
  END IF;
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Non Default Roles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLES' 'DBA_ROLES'
BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
  :sql_text := q'[
select * from &&main_table.
where oracle_maintained='N'
  ]';
  ELSE
  :sql_text := q'[
select * from dba_roles
where not (
  role in &&default_role_list_1. or
  role in &&default_role_list_2. or
  role in &&default_role_list_3. or
  role in &&default_role_list_4. or
  role in &&default_role_list_5. or
  role in &&default_role_list_6. or
  role in &&default_role_list_7. or
  role in &&default_role_list_8. or
  role in &&default_role_list_9.
)
  ]';
  END IF;
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Wrong Default Roles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLES' 'DBA_ROLES'
BEGIN
  :sql_text := q'[
WITH result as (
SELECT * FROM &&main_table.
where oracle_maintained = 'Y'
minus
SELECT * FROM &&main_table.
where (
  role in &&default_role_list_1. or
  role in &&default_role_list_2. or
  role in &&default_role_list_3. or
  role in &&default_role_list_4. or
  role in &&default_role_list_5. or
  role in &&default_role_list_6. or
  role in &&default_role_list_7. or
  role in &&default_role_list_8. or
  role in &&default_role_list_9.
)
) select * from result order by role
  ]';
END;
/
@@&&skip_ver_le_11.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Sensitive Roles Granted';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLE_PRIVS' 'DBA_ROLE_PRIVS'
BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
     :sql_text := q'[
SELECT p.*
  from dba_role_privs p, dba_roles r, dba_users u
 where p.granted_role not in ('CONNECT','RESOURCE')
   and p.granted_role = r.role
   --and p.con_id = r.con_id
   and r.oracle_maintained = 'Y'
   and p.grantee = u.username
   --and p.con_id = u.con_id
   and u.oracle_maintained = 'N'
order by p.grantee, p.granted_role
]';
        :sql_text_cdb := q'[
SELECT p.*
  from cdb_role_privs p, cdb_roles r, cdb_users u
 where p.granted_role not in ('CONNECT','RESOURCE')
   and p.granted_role = r.role
   and p.con_id = r.con_id
   and r.oracle_maintained = 'Y'
   and p.grantee = u.username
   and p.con_id = u.con_id
   and u.oracle_maintained = 'N'
order by p.con_id, p.grantee, p.granted_role
]';
  ELSE
    :sql_text := q'[
       SELECT p.*
       from dba_role_privs p, dba_users u
       where p.granted_role not in ('CONNECT','RESOURCE')
       and (
         p.granted_role in &&default_role_list_1. or
         p.granted_role in &&default_role_list_2. or
         p.granted_role in &&default_role_list_3. or
         p.granted_role in &&default_role_list_4. or
         p.granted_role in &&default_role_list_5. or
         p.granted_role in &&default_role_list_6. or
         p.granted_role in &&default_role_list_7. or
         p.granted_role in &&default_role_list_8. or
         p.granted_role in &&default_role_list_9.
       )
       and p.grantee = u.username
       and not (
         u.username in &&default_user_list_1. or
         u.username in &&default_user_list_2.
       )
       order by p.grantee, p.granted_role
]';
  END IF;
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Users with CATALOG Roles';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLE_PRIVS' 'DBA_ROLE_PRIVS'
BEGIN
     :sql_text := q'[
SELECT *
  FROM dba_role_privs
  WHERE granted_role IN ('DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','SELECT_CATALOG_ROLE')
]';
     :sql_text_cdb := q'[
SELECT *
  FROM cdb_role_privs
  WHERE granted_role IN ('DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','SELECT_CATALOG_ROLE')
]';

END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'All Role Privileges';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLE_PRIVS' 'DBA_ROLE_PRIVS'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'ADMIN Role Privileges';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLE_PRIVS' 'DBA_ROLE_PRIVS'
BEGIN
:sql_text := q'[
select *
  from &&main_table.
 where admin_option='YES'
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Grants by Role';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLE_PRIVS' 'DBA_ROLE_PRIVS'
DEF foot = '* Users between brackets have role granted indirectly.';
BEGIN
 :sql_text := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
SELECT A.PRIVILEGE,
       LISTAGG(A.GRANTEE_FORMATED, ', ') WITHIN GROUP (ORDER BY A.GRANTEE) GRANTEES
FROM   (SELECT DISTINCT A.GRANTEE,
               DECODE(NIVEL,1,A.GRANTEE,'(' || A.GRANTEE || ')') GRANTEE_FORMATED,
         A.GRANTED_ROLE_ROOT PRIVILEGE,
               RANK() OVER(PARTITION BY A.GRANTEE, A.GRANTED_ROLE_ROOT ORDER BY NIVEL ASC) RANK,
               FLOOR(((DENSE_RANK() OVER (PARTITION BY GRANTED_ROLE_ROOT ORDER BY GRANTEE ASC))-1)/100) GROUP_ID
    FROM   (SELECT A.GRANTEE,
             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                       LEVEL NIVEL
        FROM   DBA_ROLE_PRIVS A
        CONNECT BY PRIOR GRANTEE = GRANTED_ROLE) A
    WHERE  A.GRANTEE NOT IN (SELECT ROLE FROM DBA_ROLES)) A
WHERE A.RANK = 1
GROUP BY A.PRIVILEGE, A.GROUP_ID
ORDER BY 1, 2]';
 :sql_text_cdb := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
SELECT A.CON_ID,
       A.PRIVILEGE,
       LISTAGG(A.GRANTEE_FORMATED, ', ') WITHIN GROUP (ORDER BY A.GRANTEE) GRANTEES
FROM   (SELECT DISTINCT A.CON_ID,
               A.GRANTEE,
               DECODE(NIVEL,1,A.GRANTEE,'(' || A.GRANTEE || ')') GRANTEE_FORMATED,
         A.GRANTED_ROLE_ROOT PRIVILEGE,
               RANK() OVER(PARTITION BY A.GRANTEE, A.GRANTED_ROLE_ROOT ORDER BY NIVEL ASC) RANK,
               FLOOR(((DENSE_RANK() OVER (PARTITION BY CON_ID, GRANTED_ROLE_ROOT ORDER BY GRANTEE ASC))-1)/100) GROUP_ID
    FROM   (SELECT A.CON_ID,
             A.GRANTEE,
             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                       LEVEL NIVEL
        FROM   CDB_ROLE_PRIVS A
        CONNECT BY PRIOR GRANTEE = GRANTED_ROLE AND PRIOR CON_ID = CON_ID) A
    WHERE  (A.CON_ID, A.GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)) A
WHERE A.RANK = 1
GROUP BY A.CON_ID, A.PRIVILEGE, A.GROUP_ID
ORDER BY 1, 2, 3]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Grants by User';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_ROLE_PRIVS' 'DBA_ROLE_PRIVS'
DEF foot = '* Users between brackets have role granted indirectly.';
BEGIN
 :sql_text := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
SELECT A.GRANTEE,
       LISTAGG(A.PRIVILEGE_FORMATED, ', ') WITHIN GROUP (ORDER BY A.PRIVILEGE) GRANTEES
FROM   (SELECT DISTINCT A.GRANTEE,
               DECODE(NIVEL,1,A.GRANTED_ROLE_ROOT,'(' || A.GRANTED_ROLE_ROOT || ')') PRIVILEGE_FORMATED,
         A.GRANTED_ROLE_ROOT PRIVILEGE,
               RANK() OVER(PARTITION BY A.GRANTEE, A.GRANTED_ROLE_ROOT ORDER BY NIVEL ASC) RANK,
               FLOOR(((DENSE_RANK() OVER (PARTITION BY GRANTEE ORDER BY GRANTED_ROLE_ROOT ASC))-1)/100) GROUP_ID
    FROM   (SELECT A.GRANTEE,
             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                       LEVEL NIVEL
        FROM   DBA_ROLE_PRIVS A
        CONNECT BY PRIOR GRANTEE = GRANTED_ROLE) A
    WHERE  A.GRANTEE NOT IN (SELECT ROLE FROM DBA_ROLES)) A
WHERE A.RANK = 1
GROUP BY A.GRANTEE, A.GROUP_ID
ORDER BY 1, 2]';
 :sql_text_cdb := q'[
-- Written by Rodrigo Jorge - www.dbarj.com.br
SELECT A.CON_ID,
       A.GRANTEE,
       LISTAGG(A.PRIVILEGE_FORMATED, ', ') WITHIN GROUP (ORDER BY A.PRIVILEGE) GRANTEES
FROM   (SELECT DISTINCT A.CON_ID,
               A.GRANTEE,
               DECODE(NIVEL,1,A.GRANTED_ROLE_ROOT,'(' || A.GRANTED_ROLE_ROOT || ')') PRIVILEGE_FORMATED,
         A.GRANTED_ROLE_ROOT PRIVILEGE,
               RANK() OVER(PARTITION BY A.GRANTEE, A.GRANTED_ROLE_ROOT ORDER BY NIVEL ASC) RANK,
               FLOOR(((DENSE_RANK() OVER (PARTITION BY CON_ID, GRANTEE ORDER BY GRANTED_ROLE_ROOT ASC))-1)/100) GROUP_ID
    FROM   (SELECT A.CON_ID,
             A.GRANTEE,
             CONNECT_BY_ROOT GRANTED_ROLE GRANTED_ROLE_ROOT,
                       LEVEL NIVEL
        FROM   CDB_ROLE_PRIVS A
        CONNECT BY PRIOR GRANTEE = GRANTED_ROLE AND PRIOR CON_ID = CON_ID) A
    WHERE  (A.CON_ID, A.GRANTEE) NOT IN (SELECT CON_ID, ROLE FROM CDB_ROLES)) A
WHERE A.RANK = 1
GROUP BY A.CON_ID, A.GRANTEE, A.GROUP_ID
ORDER BY 1, 2, 3]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

