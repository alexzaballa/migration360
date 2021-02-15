/*****************************************************************************************/
--Invalid Objects

DEF title = 'Invalid Objects';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_OBJECTS' 'DBA_OBJECTS'
DEF abstract = ''
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.objects
 WHERE status = 'INVALID'
 ORDER BY
       owner,
       object_name
]';
   :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM CDB_OBJECTS
 WHERE status = 'INVALID'
 ORDER BY
       con_id,
       owner,
       object_name
]';   
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Unusable Indexes

DEF title = 'Unusable Indexes';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_INDEXES' 'DBA_INDEXES'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       index_owner,index_name, 'SUBPARTITIONED' INDEX_TYPE ,partition_name,subpartition_name
  FROM &&dva_object_prefix.ind_subpartitions
 WHERE status = 'UNUSABLE'
   AND index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
UNION ALL
SELECT index_owner,index_name,'PARTITIONED',partition_name,null
  FROM &&dva_object_prefix.ind_partitions
 WHERE status = 'UNUSABLE'
   AND index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
UNION ALL
SELECT owner,index_name,index_type,null,null   
  FROM &&dva_object_prefix.indexes
 WHERE status = 'UNUSABLE'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       1,2,4 nulls first,5 nulls first
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       index_owner,index_name, 'SUBPARTITIONED' INDEX_TYPE ,partition_name,subpartition_name,con_id
  FROM CDB_IND_SUBPARTITIONS
 WHERE status = 'UNUSABLE'
   AND index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
UNION ALL
SELECT index_owner,index_name,'PARTITIONED',partition_name,null,con_id
  FROM CDB_IND_PARTITIONS
 WHERE status = 'UNUSABLE'
   AND index_owner NOT IN &&exclusion_list.
   AND index_owner NOT IN &&exclusion_list2.
UNION ALL
SELECT owner,index_name,index_type,null,null,con_id   
  FROM CDB_INDEXES
 WHERE status = 'UNUSABLE'
   AND owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       con_id,2,3,5 nulls first,6 nulls first
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Sequences prone to contention

DEF title = 'Sequences prone to contention';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SEQUENCES' 'DBA_SEQUENCES'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       (s.last_number - CASE WHEN s.increment_by > 0 THEN s.min_value ELSE s.max_value END) / s.increment_by times_used, s.*
  FROM &&dva_object_prefix.sequences s
 WHERE s.sequence_owner not in &&exclusion_list.
   AND s.sequence_owner not in &&exclusion_list2.
   AND (s.cache_size <= 1000 OR s.order_flag = 'Y')
   AND s.min_value != s.last_number
   AND s.max_value != s.last_number
   AND (s.last_number - CASE WHEN s.increment_by > 0 THEN s.min_value ELSE s.max_value END) / s.increment_by >= 10000
 ORDER BY 1 DESC
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       (s.last_number - CASE WHEN s.increment_by > 0 THEN s.min_value ELSE s.max_value END) / s.increment_by times_used, s.*
  FROM CDB_SEQUENCES s
 WHERE s.sequence_owner not in &&exclusion_list.
   AND s.sequence_owner not in &&exclusion_list2.
   AND (s.cache_size <= 1000 OR s.order_flag = 'Y')
   AND s.min_value != s.last_number
   AND s.max_value != s.last_number
   AND (s.last_number - CASE WHEN s.increment_by > 0 THEN s.min_value ELSE s.max_value END) / s.increment_by >= 10000
 ORDER BY con_id,2 DESC
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--SQL using Literals or many children (by COUNT)

DEF title = 'SQL using Literals or many children (by COUNT)';
DEF main_table = '&&gv_view_prefix.SQL';
COL force_matching_signature FOR 99999999999999999999 HEA "SIGNATURE";
BEGIN
  :sql_text := q'[
WITH
lit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       force_matching_signature, COUNT(*) cnt, MIN(sql_id) min_sql_id, MAX(sql_id) max_sql_id
  FROM &&gv_object_prefix.sql
 WHERE force_matching_signature > 0
   AND UPPER(sql_text) NOT LIKE '%MIG360%'
 GROUP BY
       force_matching_signature
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       DISTINCT lit.cnt, s.force_matching_signature, s.parsing_schema_name owner,
       CASE WHEN o.object_name IS NOT NULL THEN o.object_name||'('||s.program_line#||')' END source,
       lit.min_sql_id,
       lit.max_sql_id,
       s.sql_text
  FROM lit, &&gv_object_prefix.sql s, &&dva_object_prefix.objects o
 WHERE s.force_matching_signature = lit.force_matching_signature
   AND s.sql_id = lit.min_sql_id
   AND o.object_id(+) = s.program_id
 ORDER BY 
       1 DESC, 2
]';
  :sql_text_cdb := q'[
WITH
lit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       con_id, force_matching_signature, COUNT(*) cnt, MIN(sql_id) min_sql_id, MAX(sql_id) max_sql_id
  FROM &&gv_object_prefix.sql
 WHERE force_matching_signature > 0
   AND UPPER(sql_text) NOT LIKE '%MIG360%'
 GROUP BY
       con_id,force_matching_signature
HAVING COUNT(*) > 99
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       DISTINCT lit.cnt, s.con_id, s.force_matching_signature, s.parsing_schema_name owner,
       CASE WHEN o.object_name IS NOT NULL THEN o.object_name||'('||s.program_line#||')' END source,
       lit.min_sql_id,
       lit.max_sql_id,
       s.sql_text
  FROM lit, &&gv_object_prefix.sql s, CDB_OBJECTS o
 WHERE s.force_matching_signature = lit.force_matching_signature
   AND s.sql_id = lit.min_sql_id
   AND o.object_id(+) = s.program_id
 ORDER BY 
       1 DESC, 2, 3
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--High Cursor Count

DEF title = 'High Cursor Count';
DEF main_table = '&&gv_view_prefix.SQL';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       v1.sql_id,
       COUNT(*) child_cursors,
       MIN(inst_id) min_inst_id,
       MAX(inst_id) max_inst_id,
       MIN(child_number) min_child,
       MAX(child_number) max_child,
       v1.sql_text
  FROM &&gv_object_prefix.sql v1
 GROUP BY
       v1.sql_id,
       v1.sql_text
HAVING COUNT(*) > 99
 ORDER BY
       child_cursors DESC,
       v1.sql_id
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       v1.con_id,
       v1.sql_id,
       COUNT(*) child_cursors,
       MIN(inst_id) min_inst_id,
       MAX(inst_id) max_inst_id,
       MIN(child_number) min_child,
       MAX(child_number) max_child,
       v1.sql_text
  FROM &&gv_object_prefix.sql v1
 GROUP BY
       v1.con_id,
       v1.sql_id,
       v1.sql_text
HAVING COUNT(*) > 99
 ORDER BY
       child_cursors DESC,
       v1.con_id,
       v1.sql_id
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Orphaned Synonyms
--adding NVL to con_id - 19.9 slowness

DEF title = 'Orphaned Synonyms';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SYNONYMS' 'DBA_SYNONYMS'
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       s.owner, s.table_owner, COUNT(1)
  FROM &&dva_object_prefix.synonyms s
 WHERE NOT EXISTS
       (select NULL
          from &&dva_object_prefix.objects o
         where o.object_name = s.table_name
           and o.owner = s.table_owner)
   AND s.db_link IS NULL
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.table_owner NOT IN &&exclusion_list.
   AND s.table_owner NOT IN &&exclusion_list2.
 GROUP BY s.owner, s.table_owner
 ORDER BY s.owner
]';
  :sql_text_cdb := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       s.owner, s.table_owner, COUNT(1), s.con_id
  FROM CDB_SYNONYMS s
 WHERE NOT EXISTS
       (select NULL
          from CDB_OBJECTS o
         where o.object_name = s.table_name
           and o.owner = s.table_owner
           and nvl(o.con_id,-1) = nvl(s.con_id,-1)
           )
   AND s.db_link IS NULL
   AND s.owner NOT IN &&exclusion_list.
   AND s.owner NOT IN &&exclusion_list2.
   AND s.table_owner NOT IN &&exclusion_list.
   AND s.table_owner NOT IN &&exclusion_list2.
 GROUP BY s.con_id, s.owner, s.table_owner
 ORDER BY s.con_id, s.owner
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Public Synonyms to Non-default Users';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SYNONYMS' 'DBA_SYNONYMS'
BEGIN
  IF '&&is_ver_ge_12.' = 'Y' THEN
   :sql_text := q'[
select /*+ &&top_level_hints. */
       s.*
  from dba_synonyms s, dba_users u
 where s.owner = 'PUBLIC'
   and s.table_owner = u.username
   and u.oracle_maintained = 'N'
]';
   :sql_text_cdb := q'[
select /*+ &&top_level_hints. */
       s.*
  from cdb_synonyms s, cdb_users u
 where s.owner = 'PUBLIC'
   and s.table_owner = u.username
   and s.con_id = u.con_id
   and u.oracle_maintained = 'N'
]';
  ELSE
   :sql_text := q'[
select /*+ &&top_level_hints. */
       *
  from dba_synonyms
 where owner = 'PUBLIC'
   and not( table_owner in &&default_user_list_1. or table_owner in &&default_user_list_2. )
]';
  END IF;
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Materialized Views';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_MVIEWS' 'DBA_MVIEWS'
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM dba_mviews
 ORDER BY owner, mview_name
';
 :sql_text_cdb := '
SELECT /*+ &&top_level_hints. */
       *
  FROM cdb_mviews
 ORDER BY con_id, owner, mview_name
'; 
END;
/
@@&&9a_pre_one. 


/*****************************************************************************************/

DEF title = 'Directories';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_DIRECTORIES' 'DBA_DIRECTORIES'
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Directories Privileges';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_DIRECTORIES' 'DBA_DIRECTORIES'
BEGIN
  :sql_text := '
SELECT d.*, P.grantee, p.grantor, p.privilege, p.grantable, p.hierarchy
FROM dba_tab_privs P, dba_directories D
WHERE D.DIRECTORY_NAME=P.table_name
';
  :sql_text_cdb := '
select d.*, P.grantee, p.grantor, p.privilege, p.grantable, p.hierarchy, p.common
from cdb_directories d, cdb_tab_privs p
WHERE p.table_name=d.directory_name and p.con_id=d.con_id
order by p.con_id, directory_name
';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Synonyms using Database Links';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_SYNONYMS' 'DBA_SYNONYMS'
BEGIN
  :sql_text := '
select *
from   dba_synonyms 
where  db_link is not null
order by 1,2
';
 :sql_text_cdb := '
select *
from   cdb_synonyms 
where  db_link is not null
order by con_id, 1, 2
';
END;
/
@@&&9a_pre_one. 


/*****************************************************************************************/

DEF title = 'Views using Database Links';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_VIEWS' 'DBA_VIEWS'
BEGIN
 IF '&&is_ver_ge_12.' = 'Y' THEN
  :sql_text := q'[
select ownerv,view_name, db_link
  from (select dbv.owner ownerv,view_name, text_vc text
          from dba_views dbv 
         where 1=1
           AND dbv.owner NOT IN &&exclusion_list.
           AND dbv.owner NOT IN &&exclusion_list2.
           AND dbv.owner NOT IN &&exclusion_list3.
           ),
       dba_db_links dbl
where upper (text) like '%@' || nvl (substr (db_link, 1, instr (db_link, '.') - 1), db_link) || '%'
]';
 :sql_text_cdb := q'[
select ownerv,view_name, db_link
  from (select dbv.owner ownerv,view_name, text_vc text
          from cdb_views dbv 
         where 1=1
           AND dbv.owner NOT IN &&exclusion_list.
           AND dbv.owner NOT IN &&exclusion_list2.
           AND dbv.owner NOT IN &&exclusion_list3.
           ),
       dba_db_links dbl
where upper (text) like '%@' || nvl (substr (db_link, 1, instr (db_link, '.') - 1), db_link) || '%'
]';
  ELSE
  :sql_text := q'[
select ownerv,view_name, db_link
  from (select dbv.owner ownerv,view_name, dbms_metadata.get_ddl ('VIEW', view_name,owner) text
          from dba_views dbv 
         where rownum <= 1000
           AND dbv.owner NOT IN &&exclusion_list.
           AND dbv.owner NOT IN &&exclusion_list2.
           AND dbv.owner NOT IN &&exclusion_list3.
           ),
       dba_db_links dbl
where upper (text) like '%@' || nvl (substr (db_link, 1, instr (db_link, '.') - 1), db_link) || '%'
]';
  END IF;
END;
/
@@&&9a_pre_one. 
--Too Slow -- need to review versions bellow to 12c

/*****************************************************************************************/

DEF title = 'Views using Database Links Through Synonyms';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_DEPENDENCIES' 'DBA_DEPENDENCIES'
BEGIN
  :sql_text := q'[
select * from dba_dependencies dep
where dep.type='VIEW'
  and dep.referenced_name in (select synonym_name from dba_synonyms where db_link is not null)
order by 1,2
]';
 :sql_text_cdb := q'[
select * from cdb_dependencies dep
where dep.type='VIEW'
  and dep.referenced_name in (select synonym_name from dba_synonyms where db_link is not null)
  and owner='SCOTT'
order by 1,2
]';
END;
/
@@&&9a_pre_one. 
/*****************************************************************************************/

DEF title = 'Materialized Views using Database Links';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_MVIEWS' 'DBA_MVIEWS'
BEGIN
  :sql_text := '
select *
from   dba_mviews 
where  master_link is not null
order by 1,2
';
 :sql_text_cdb := '
select *
from   cdb_mviews 
where  master_link is not null
order by 1,2
';
END;
/
@@&&9a_pre_one. 

/*****************************************************************************************/

DEF title = 'Other Objects using Database Links';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_DEPENDENCIES' 'DBA_DEPENDENCIES'
BEGIN
  :sql_text := ' 
select *
from   DBA_dependencies 
where  referenced_link_name is not null
order by 1,2
';
 :sql_text_cdb := '
select *
from   CDB_dependencies 
where  referenced_link_name is not null
order by 1,2
';
END;
/
@@&&9a_pre_one. 


/*****************************************************************************************/
--

DEF title = 'Database and Schema Triggers';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TRIGGERS' 'DBA_TRIGGERS'
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&dva_object_prefix.triggers
 WHERE base_object_type IN ('DATABASE', 'SCHEMA')
 ORDER BY
       base_object_type, owner, trigger_name
]';
  :sql_text_cdb := q'[
SELECT *
  FROM CDB_TRIGGERS
 WHERE base_object_type IN ('DATABASE', 'SCHEMA')
 ORDER BY
       con_id, base_object_type, owner, trigger_name
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Logon Triggers';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_TRIGGERS' 'DBA_TRIGGERS'
BEGIN
  :sql_text := q'[
select * 
 from dba_triggers 
where triggering_event like 'LOG%'
  and status = 'ENABLED'
 order by 1,2   
]';
 :sql_text_cdb := q'[
select * 
 from cdb_triggers 
where triggering_event like 'LOG%'
  and status = 'ENABLED'
 order by 1,2   
 ]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/
