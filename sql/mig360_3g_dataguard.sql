/*****************************************************************************************/
--

DEF title = 'Database Role';
DEF main_table = '&&v_view_prefix.DATABASE';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT database_role role, name, db_unique_name, platform_id, open_mode, log_mode, flashback_on, protection_mode, protection_level /* &&section_id..&&report_sequence. */
FROM &&v_object_prefix.database
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'Force Logging';
DEF main_table = '&&v_view_prefix.DATABASE';
BEGIN
  :sql_text := q'[
SELECT force_logging, remote_archive, supplemental_log_data_pk, supplemental_log_data_ui, switchover_status, dataguard_broker /* &&section_id..&&report_sequence. */
FROM &&v_object_prefix.database
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/


DEF title = 'Catproc Release';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_REGISTRY' 'DBA_REGISTRY'
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT version, modified, status /* &&section_id..&&report_sequence. */
  FROM &&dva_object_prefix.registry WHERE comp_id = 'CATPROC'
]';
  :sql_text_cdb := q'[
SELECT con_id, version, modified, status /* &&section_id..&&report_sequence. */
  FROM CDB_registry WHERE comp_id = 'CATPROC'
ORDER BY con_id,version,modified
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Threads';
DEF main_table = '&&v_view_prefix.THREAD';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, instance, status /* &&section_id..&&report_sequence. */
FROM &&v_object_prefix.thread
]';
END;
/
@@&&9a_pre_one.   


/*****************************************************************************************/

DEF title = 'Instances';
DEF main_table = '&&gv_view_prefix.INSTANCE';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, instance_name, host_name, version, archiver, log_switch_wait /* &&section_id..&&report_sequence. */
FROM &&gv_object_prefix.instance ORDER BY thread#
]';
  :sql_text_cdb := q'[
SELECT thread#, instance_name, host_name, version, archiver, log_switch_wait, con_id /* &&section_id..&&report_sequence. */
FROM &&gv_object_prefix.instance ORDER BY con_id, thread#
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/


DEF title = 'Log Switching';
DEF main_table = '&&v_view_prefix.ARCHIVED_LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT fs.log_switches_under_20_mins, ss.log_switches_over_20_mins /* &&section_id..&&report_sequence. */
  FROM (
SELECT SUM(COUNT (ROUND((b.first_time - a.first_time) * 1440) )) "LOG_SWITCHES_UNDER_20_MINS"  
  FROM &&v_object_prefix.archived_log a, &&v_object_prefix.archived_log b 
 WHERE a.sequence# + 1 = b.sequence# 
   AND a.dest_id = 1 
   AND a.thread# = b.thread#  
   AND a.dest_id = b.dest_id 
   AND a.dest_id = (
SELECT MIN(dest_id) 
  FROM &&gv_object_prefix.archive_dest 
 WHERE target='PRIMARY' 
   AND destination IS NOT NULL) 
   AND ROUND((b.first_time - a.first_time) * 1440)  < 20 
 GROUP BY ROUND((b.first_time - a.first_time) * 1440))  fs, (
SELECT  SUM(COUNT (ROUND((b.first_time - a.first_time) * 1440) )) "LOG_SWITCHES_OVER_20_MINS"  
  FROM &&v_object_prefix.archived_log a, &&v_object_prefix.archived_log b 
 WHERE a.sequence# + 1 = b.sequence# 
   AND a.dest_id = 1 
   AND a.thread# = b.thread#  
   AND a.dest_id = b.dest_id 
   AND a.dest_id = (
SELECT MIN(dest_id) 
  FROM &&gv_object_prefix.archive_dest 
 WHERE target='PRIMARY' 
   AND destination IS NOT NULL) 
   AND ROUND((b.first_time - a.first_time) * 1440)  > 19 
 GROUP BY ROUND((b.first_time - a.first_time) * 1440)) ss
]';
END;
/
@@&&9a_pre_one.    


/*****************************************************************************************/

DEF title = 'Log Switches';
DEF main_table = '&&v_view_prefix.ARCHIVED_LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT (CASE WHEN bucket = 1 THEN '<= ' || TO_CHAR(bucket * 5) /* &&section_id..&&report_sequence. */
             WHEN (bucket >1 AND bucket < 9) THEN TO_CHAR(bucket * 5 - 4) || ' TO ' || TO_CHAR(bucket * 5) 
             WHEN bucket > 8 THEN '>= ' || TO_CHAR(bucket * 5 - 4) END) "MINUTES", 
       switches "LOG_SWITCHES" 
  FROM (
SELECT bucket , COUNT(b.bucket) SWITCHES 
  FROM (
SELECT WIDTH_BUCKET(ROUND((b.first_time - a.first_time) * 1440), 0, 40, 8) bucket 
  FROM &&v_object_prefix.archived_log a, &&v_object_prefix.archived_log b 
 WHERE a.sequence# + 1 = b.sequence# 
   AND a.dest_id = b.dest_id  
   AND a.thread# = b.thread#  
   AND a.dest_id = (
SELECT MIN(dest_id) 
  FROM &&gv_object_prefix.archive_dest 
 WHERE target = 'PRIMARY' 
   AND destination IS NOT NULL)) b 
 GROUP BY bucket ORDER BY bucket)
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'Redo Log Group';
DEF main_table = '&&v_view_prefix.LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, group#, sequence#, bytes, archived ,status /* &&section_id..&&report_sequence. */
FROM &&v_object_prefix.log ORDER BY thread#, group#
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/

DEF title = 'Standby Logs';
DEF main_table = '&&v_view_prefix.STANDBY_LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, group#, sequence#, bytes, archived, status /* &&section_id..&&report_sequence. */
FROM &&v_object_prefix.standby_log order by thread#, group#
]';
END;
/
@@&&9a_pre_one.   


/*****************************************************************************************/


DEF title = 'Archive Destinations';
DEF main_table = '&&gv_view_prefix.ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, dest_id, destination, target, schedule, process /* &&section_id..&&report_sequence. */
 FROM &&gv_object_prefix.archive_dest gvad, &&gv_object_prefix.instance gvi 
 WHERE gvad.inst_id = gvi.inst_id 
   AND destination is NOT NULL 
 ORDER BY thread#, dest_id
]';
END;
/
@@&&9a_pre_one.     


/*****************************************************************************************/


DEF title = 'Destination Details';
DEF main_table = '&&gv_view_prefix.ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, dest_id, gvad.archiver, transmit_mode, affirm, /* &&section_id..&&report_sequence. */
       async_blocks, net_timeout, max_failure, delay_mins, reopen_secs reopen, register, binding 
  FROM &&gv_object_prefix.archive_dest gvad, &&gv_object_prefix.instance gvi 
 WHERE gvad.inst_id = gvi.inst_id 
   AND destination is NOT NULL 
 ORDER BY thread#, dest_id
]';
END;
/
@@&&9a_pre_one.   


/*****************************************************************************************/


DEF title = 'Destination Errors';
DEF main_table = '&&gv_view_prefix.ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, dest_id, gvad.status, error, fail_sequence /* &&section_id..&&report_sequence. */
 FROM &&gv_object_prefix.archive_dest gvad, &&gv_object_prefix.instance gvi 
WHERE gvad.inst_id = gvi.inst_id 
  AND destination is NOT NULL 
ORDER BY thread#, dest_id
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/


DEF title = 'Error Conditions';
DEF main_table = '&&gv_view_prefix.DATAGUARD_STATUS';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT gvi.thread#, timestamp, message /* &&section_id..&&report_sequence. */
  FROM &&gv_object_prefix.dataguard_status gvds, &&gv_object_prefix.instance gvi 
 WHERE gvds.inst_id = gvi.inst_id 
   AND severity in ('Error','Fatal') 
 ORDER BY timestamp, thread#
]';
END;
/
@@&&9a_pre_one.   

 
/*****************************************************************************************/

DEF title = 'Status Processes Redo Shipping';
DEF main_table = '&&gv_view_prefix.MANAGED_STANDBY';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT inst_id, thread#, process, pid, status, client_process, /* &&section_id..&&report_sequence. */
       client_pid, sequence#, block#, active_agents, known_agents 
  FROM &&gv_object_prefix.managed_standby 
 ORDER BY thread#, pid
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/


DEF title = 'Current and Last Seq#';
DEF main_table = '&&gv_view_prefix.ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT cu.thread#, cu.dest_id, la.lastarchived "Last Archived", /* &&section_id..&&report_sequence. */
       cu.currentsequence "Current Sequence", appl.lastapplied "Last Applied" 
 FROM (
select gvi.thread#, gvd.dest_id, MAX(gvd.log_sequence) currentsequence 
  FROM &&gv_object_prefix.archive_dest gvd, &&gv_object_prefix.instance gvi 
 WHERE gvd.status = 'VALID' 
   AND gvi.inst_id = gvd.inst_id 
 GROUP BY thread#, dest_id) cu, (
SELECT thread#, dest_id, MAX(sequence#) lastarchived 
  FROM &&gv_object_prefix.archived_log 
 WHERE resetlogs_change# = (
SELECT resetlogs_change# 
  FROM &&v_object_prefix.database) 
   AND archived = 'YES' 
 GROUP BY thread#, dest_id) la, (
SELECT thread#, dest_id, MAX(sequence#) lastapplied 
  FROM &&gv_object_prefix.archived_log 
 WHERE resetlogs_change# = (
SELECT resetlogs_change# 
  FROM &&v_object_prefix.database) 
   AND applied = 'YES' 
 GROUP BY thread#, dest_id) appl 
 WHERE cu.thread# = la.thread# 
   AND cu.thread# = appl.thread# 
   AND cu.dest_id = la.dest_id 
   AND cu.dest_id = appl.dest_id 
 ORDER BY 1, 2
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/


DEF title = 'Standby Dest';
DEF main_table = '&&v_view_prefix.ARCHIVE_DEST_STATUS';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT dest_id, database_mode, recovery_mode, protection_mode, standby_logfile_count, standby_logfile_active /* &&section_id..&&report_sequence. */
  FROM &&v_object_prefix.archive_dest_status 
 WHERE destination IS NOT NULL
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/


DEF title = 'Non-default Init Parameters';
DEF main_table = '&&v_view_prefix.PARAMETER';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT num, '*' "THREAD#", name, value /* &&section_id..&&report_sequence. */
  FROM &&v_object_prefix.PARAMETER WHERE NUM IN (
SELECT num 
  FROM &&v_object_prefix.parameter 
 WHERE (isdefault = 'FALSE' OR ismodified <> 'FALSE') 
   AND name NOT LIKE 'nls%'
 MINUS
SELECT num 
  FROM &&gv_object_prefix.parameter gvp, &&gv_object_prefix.instance gvi 
 WHERE num IN (
SELECT DISTINCT gvpa.num 
  FROM &&gv_object_prefix.parameter gvpa, &&gv_object_prefix.parameter gvpb 
 WHERE gvpa.num = gvpb.num 
   AND  gvpa.value <> gvpb.value 
   AND (gvpa.isdefault = 'FALSE' OR gvpa.ismodified <> 'FALSE') 
   AND gvpa.name NOT LIKE 'nls%') 
   AND gvi.inst_id = gvp.inst_id  
   AND (gvp.isdefault = 'FALSE' OR gvp.ismodified <> 'FALSE') 
   AND gvp.name NOT LIKE 'nls%')
 UNION
SELECT num, TO_CHAR(thread#) "THREAD#", name, value 
  FROM &&gv_object_prefix.parameter gvp, &&gv_object_prefix.instance gvi 
 WHERE num IN (
SELECT DISTINCT gvpa.num 
  FROM &&gv_object_prefix.parameter gvpa, &&gv_object_prefix.parameter gvpb 
 WHERE gvpa.num = gvpb.num 
   AND gvpa.value <> gvpb.value 
   AND (gvpa.isdefault = 'FALSE' OR gvpa.ismodified <> 'FALSE') 
   AND gvp.name NOT LIKE 'nls%') 
   AND gvi.inst_id = gvp.inst_id  
   AND (gvp.isdefault = 'FALSE' OR gvp.ismodified <> 'FALSE') 
   AND gvp.name NOT LIKE 'nls%' 
 ORDER BY 1, 2
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'DG_BROKER_CONFIG';
DEF main_table = 'GV$DG_BROKER_CONFIG';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text'
@@&&skip_ver_le_10.&&skip_ver_le_11.&&9a_pre_one.


/*****************************************************************************************/

DEF title = 'DATAGUARD_CONFIG';
DEF main_table = 'GV$DATAGUARD_CONFIG';
@@&&fc_gen_select_star_query. '&&main_table.' 'sql_text' '1'
@@&&9a_pre_one.


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
