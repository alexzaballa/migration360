DEF title = 'RMAN Backup Size';
DEF main_table = 'V$BACKUP_PIECE';
BEGIN
  --got from Michael Dinh	 
  :sql_text := q'[
SELECT TO_CHAR(completion_time, 'YYYY-MON-DD') completion_time, type, round(sum(bytes)/1048576) MB, round(sum(elapsed_seconds)/60) min
    FROM
    (
    SELECT
    CASE
      WHEN s.backup_type='L' THEN 'ARCHIVELOG'
      WHEN s.controlfile_included='YES' THEN 'CONTROLFILE'
      WHEN s.backup_type='D' AND s.incremental_level=0 THEN 'LEVEL0'
      WHEN s.backup_type='I' AND s.incremental_level=1 THEN 'LEVEL1'
      WHEN s.backup_type='D' AND s.incremental_level is null THEN 'FULL'
   END type,
   TRUNC(s.completion_time) completion_time, p.bytes, s.elapsed_seconds
   FROM v$backup_piece p, v$backup_set s
   WHERE p.status='A' AND p.recid=s.recid
   UNION ALL
   SELECT 'DATAFILECOPY' type, TRUNC(completion_time), output_bytes, 0 elapsed_seconds FROM v$backup_copy_details
   )
   GROUP BY TO_CHAR(completion_time, 'YYYY-MON-DD'), type
   ORDER BY 1 ASC,2,3
]';
END;
/
@@&&9a_pre_one.


/******************************************************************************************/

DEF title = 'RMAN Backup Non-Default Configurations';
DEF main_table = 'GV$RMAN_CONFIGURATION';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.


/******************************************************************************************/

DEF title = 'RMAN Encryption Algorithms';
DEF main_table = 'V$RMAN_ENCRYPTION_ALGORITHMS';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'RMAN Compression Algorithms';
DEF main_table = 'GV$RMAN_COMPRESSION_ALGORITHM';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/******************************************************************************************/

DEF title = 'RMAN Backup Job Details';
DEF main_table = 'V$RMAN_BACKUP_JOB_DETAILS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM v$rman_backup_job_details
 --WHERE start_time >= (SYSDATE - 100)
 ORDER BY
       start_time DESC
';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--RMAN Backup Set Details

DEF title = 'RMAN Backup Set Details';
DEF main_table = '&&v_view_prefix.BACKUP_SET_DETAILS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.backup_set_details
 ORDER BY
       1, 2, 3, 4, 5
]';
END;
/
@@&&9a_pre_one.


/******************************************************************************************/

DEF title = 'RMAN Output';
DEF main_table = 'GV$RMAN_OUTPUT';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Fast Recovery Area';
DEF main_table = 'V$RECOVERY_FILE_DEST';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Fast Recovery Area Usage';
DEF main_table = 'V$RECOVERY_AREA_USAGE';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Restore Point';
DEF main_table = 'V$RESTORE_POINT';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Flashback Statistics';
DEF main_table = 'V$FLASHBACK_DATABASE_STAT';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Flashback Log';
DEF main_table = 'V$FLASHBACK_DATABASE_LOG';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Block Corruption';
DEF main_table = 'V$DATABASE_BLOCK_CORRUPTION';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Block Change Tracking';
DEF main_table = 'V$BLOCK_CHANGE_TRACKING';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'REDO LOG';
DEF main_table = 'V$LOG';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
     *
  FROM v$log
 ORDER BY 1, 2, 3, 4
';
END;
/
@@&&9a_pre_one.

DEF title = 'REDO LOG Files';
DEF main_table = 'V$LOGFILE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
     *
  FROM v$logfile
 ORDER BY 1, 2, 3, 4
';
END;
/
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'REDO LOG History';
DEF main_table = 'V$LOG_HISTORY';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
 THREAD#, TO_CHAR(trunc(FIRST_TIME), ''YYYY-MON-DD'') day, count(*)
from v$log_history
where FIRST_TIME >= (sysdate - 31)
group by rollup(THREAD#, trunc(FIRST_TIME))
order by THREAD#, trunc(FIRST_TIME)
';
END;
/
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'REDO LOG Switches Frequency Map';
DEF main_table = 'V$LOG_HISTORY';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := '
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */
       thread#,
       TO_CHAR(TRUNC(first_time), ''YYYY-MM-DD'') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), ''Dy'') day,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''00'', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''01'', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''02'', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''03'', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''04'', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''05'', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''06'', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''07'', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''08'', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''09'', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''10'', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''11'', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''12'', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''13'', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''14'', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''15'', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''16'', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''17'', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''18'', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''19'', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''20'', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''21'', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''22'', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''23'', 1, 0)) h23,
       COUNT(*) per_day
  FROM v$log_history
 GROUP BY
       thread#,
       TRUNC(first_time)
 ORDER BY
       thread#,
       TRUNC(first_time) DESC NULLS LAST
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */
       ROWNUM row_num_noprint, log.*
  FROM log
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */
       thread#,
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
 GROUP BY 
       thread#
)
SELECT /*+ &&top_level_hints. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.thread# = ms.thread#
   AND log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.thread#,
       log.yyyy_mm_dd DESC
';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--ARCHIVED LOG

DEF title = 'ARCHIVED LOG';
DEF main_table = '&&v_view_prefix.ARCHIVED_LOG';
--DEF max_rows   = '100';
BEGIN
  :sql_text := q'[
SELECT *
  FROM &&v_object_prefix.archived_log
]';
END;
/
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'ARCHIVED LOG Frequency Map per Thread';
DEF main_table = 'V$ARCHIVED_LOG';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := '
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */
       DISTINCT 
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM v$archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ &&sq_fact_hints. */
       thread#,
       TO_CHAR(TRUNC(first_time), ''YYYY-MM-DD'') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), ''Dy'') day,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''00'', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''01'', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''02'', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''03'', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''04'', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''05'', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''06'', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''07'', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''08'', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''09'', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''10'', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''11'', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''12'', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''13'', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''14'', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''15'', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''16'', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''17'', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''18'', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''19'', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''20'', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''21'', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''22'', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''23'', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(2,30), 1) TOT_GiB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(2,30) / COUNT(*), 1) AVG_GiB
  FROM log
 GROUP BY
       thread#,
       TRUNC(first_time)
 ORDER BY
       thread#,
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */
       thread#,
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
 GROUP BY 
       thread#
)
SELECT /*+ &&top_level_hints. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.thread# = ms.thread#
   AND log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.thread#,
       log.yyyy_mm_dd DESC
';
END;
/
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'ARCHIVED LOG Frequency Map per Cluster';
DEF main_table = 'V$ARCHIVED_LOG';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := '
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */
       DISTINCT 
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM v$archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ &&sq_fact_hints. */
       TO_CHAR(TRUNC(first_time), ''YYYY-MM-DD'') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), ''Dy'') day,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''00'', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''01'', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''02'', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''03'', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''04'', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''05'', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''06'', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''07'', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''08'', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''09'', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''10'', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''11'', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''12'', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''13'', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''14'', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''15'', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''16'', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''17'', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''18'', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''19'', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''20'', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''21'', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''22'', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''23'', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(2,30), 1) TOT_GiB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(2,30) / COUNT(*), 1) AVG_GiB
  FROM log
 GROUP BY
       TRUNC(first_time)
 ORDER BY
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
)
SELECT /*+ &&top_level_hints. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.yyyy_mm_dd DESC
';
END;
/
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'NOLOGGING Objects';
DEF main_table = 'DBA_TABLESPACES';
BEGIN
  :sql_text := '
WITH 
objects AS (
SELECT 1 record_type,
       ''TABLESPACE'' object_type,
       tablespace_name,
       NULL owner,
       NULL name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM dba_tablespaces
 WHERE logging = ''NOLOGGING''
   AND contents != ''TEMPORARY''
UNION ALL       
SELECT 2 record_type,
       ''TABLE'' object_type,
       tablespace_name,
       owner,
       table_name name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM dba_all_tables
 WHERE logging = ''NO''
   AND temporary = ''N''
UNION ALL       
SELECT 3 record_type,
       ''INDEX'' object_type,
       tablespace_name,
       owner,
       index_name name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM dba_indexes
 WHERE logging = ''NO''
   AND temporary = ''N''
UNION ALL       
SELECT 4 record_type,
       ''LOB'' object_type,
       tablespace_name,
       owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       NULL partition,
       NULL subpartition
  FROM dba_lobs
 WHERE logging = ''NO''
UNION ALL       
SELECT 5 record_type,
       ''TAB_PARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       NULL column_name,
       partition_name partition,
       NULL subpartition
  FROM dba_tab_partitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 6 record_type,
       ''IND_PARTITION'' object_type,
       tablespace_name,
       index_owner owner,
       index_name name,
       NULL column_name,
       partition_name partition,
       NULL subpartition
  FROM dba_ind_partitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 7 record_type,
       ''LOB_PARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       partition_name partition,
       NULL subpartition
  FROM dba_lob_partitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 8 record_type,
       ''TAB_SUBPARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       NULL column_name,
       partition_name partition,
       subpartition_name subpartition
  FROM dba_tab_subpartitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 9 record_type,
       ''IND_SUBPARTITION'' object_type,
       tablespace_name,
       index_owner owner,
       index_name name,
       NULL column_name,
       partition_name partition,
       subpartition_name subpartition
  FROM dba_ind_subpartitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 10 record_type,
       ''LOB_SUBPARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       lob_partition_name partition,
       subpartition_name subpartition
  FROM dba_lob_subpartitions
 WHERE logging = ''NO''
)
SELECT object_type,
       tablespace_name,
       owner,
       name,
       column_name,
       partition,
       subpartition
  FROM objects
 ORDER BY
       record_type,
       tablespace_name,
       owner,
       name,
       column_name,
       partition,
       subpartition
';
END;
/
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Unrecoverable Datafile';
DEF main_table = 'V$DATAFILE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM v$datafile
 WHERE unrecoverable_change# > 0
 ORDER BY
       file#
';
END;
/
@@&&9a_pre_one.

/******************************************************************************************/

DEF title = 'Unrecoverable Datafile after Backup';
DEF main_table = 'V$DATAFILE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
df.name data_file_name, df.unrecoverable_time
FROM v$datafile df, v$backup bk
WHERE df.file#=bk.file#
and df.unrecoverable_change#!=0
and df.unrecoverable_time >  
(select max(end_time) from v$rman_backup_job_details
where INPUT_TYPE in (''DB FULL'' ,''DB INCR''))
';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Nonlogged Datafile Blocks

DEF title = 'Nonlogged Datafile Blocks';
DEF main_table = '&&v_view_prefix.NONLOGGED_BLOCK';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.nonlogged_block
]';
END;
/
@@&&skip_ver_le_10.&&skip_ver_le_11.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Blocks with Corruption or Nonlogged';
DEF main_table = '&&v_view_prefix.DATABASE_BLOCK_CORRUPTION';
BEGIN
  :sql_text := q'[
With 
CORR  As (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       e.owner, e.segment_type, e.segment_name, e.partition_name, c.file#
     , greatest(e.block_id, c.block#) corr_start_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1)
       - greatest(e.block_id, c.block#) + 1 blocks_corrupted
     , null description
  FROM &&dva_object_prefix.extents e, &&v_object_prefix.database_block_corruption c
WHERE e.file_id = c.file#
   AND e.block_id <= c.block# + c.blocks - 1
   AND e.block_id + e.blocks - 1 >= c.block#
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.segment_type, s.segment_name, s.partition_name, c.file#
     , header_block corr_start_block#
     , header_block corr_end_block#
     , 1 blocks_corrupted
     , 'Segment Header' description
  FROM &&dva_object_prefix.segments s, &&v_object_prefix.database_block_corruption c
WHERE s.header_file = c.file#
   AND s.header_block between c.block# and c.block# + c.blocks - 1
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       null owner, null segment_type, null segment_name, null partition_name, c.file#
     , greatest(f.block_id, c.block#) corr_start_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1)
       - greatest(f.block_id, c.block#) + 1 blocks_corrupted
     , 'Free Block' description
  FROM &&dva_object_prefix.free_space f, &&v_object_prefix.database_block_corruption c
WHERE f.file_id = c.file#
   AND f.block_id <= c.block# + c.blocks - 1
   AND f.block_id + f.blocks - 1 >= c.block#
ORDER  BY file#, corr_start_block#
),
NOLOG As (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       e.owner, e.segment_type, e.segment_name, e.partition_name, c.file#
     , greatest(e.block_id, c.block#) corr_start_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(e.block_id+e.blocks-1, c.block#+c.blocks-1)
       - greatest(e.block_id, c.block#) + 1 blocks_corrupted
     , null description
  FROM &&dva_object_prefix.extents e, &&v_object_prefix.nonlogged_block c
WHERE e.file_id = c.file#
   AND e.block_id <= c.block# + c.blocks - 1
   AND e.block_id + e.blocks - 1 >= c.block#
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       s.owner, s.segment_type, s.segment_name, s.partition_name, c.file#
     , header_block corr_start_block#
     , header_block corr_end_block#
     , 1 blocks_corrupted
     , 'Segment Header' description
  FROM &&dva_object_prefix.segments s, &&v_object_prefix.nonlogged_block c
WHERE s.header_file = c.file#
   AND s.header_block between c.block# and c.block# + c.blocks - 1
UNION
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       null owner, null segment_type, null segment_name, null partition_name, c.file#
     , greatest(f.block_id, c.block#) corr_start_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1) corr_end_block#
     , least(f.block_id+f.blocks-1, c.block#+c.blocks-1)
       - greatest(f.block_id, c.block#) + 1 blocks_corrupted
     , 'Free Block' description
  FROM &&dva_object_prefix.free_space f, &&v_object_prefix.nonlogged_block  c
WHERE f.file_id = c.file#
   AND f.block_id <= c.block# + c.blocks - 1
   AND f.block_id + f.blocks - 1 >= c.block#
Order  By file#, corr_start_block#
)
Select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ * from corr
Union 
Select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ * from nolog
]';
END;
/
@@&&skip_ver_le_10.&&skip_ver_le_11.&&9a_pre_one.



/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/




