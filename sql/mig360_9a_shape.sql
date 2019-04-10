
/*****************************************************************************************/
--

DEF title = 'CPU - 90% Percentile';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_HIST_ACTIVE_SESS_HISTORY' 'DBA_HIST_ACTIVE_SESS_HISTORY'
BEGIN
  :sql_text := q'[
With cpu_data AS(
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       'CPU'                      escp_metric_group,
       CASE h.session_state 
       WHEN 'ON CPU' THEN 'CPU' 
       ELSE 'RMCPUQ' 
       END                        escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.sample_time              escp_end_date,
       to_number(TO_CHAR(COUNT(*)))          escp_value
  FROM dba_hist_active_sess_history h
 WHERE 1=1 
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
 GROUP BY
       h.session_state,
       h.instance_number,
       h.sample_time
 ORDER BY
       h.session_state,
       h.instance_number,
       h.sample_time)
SELECT escp_instance_number,PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY escp_value) "Percentile 90%"
FROM   cpu_data
Group by escp_instance_number      
]';
  :sql_text_cdb := q'[
With cpu_data AS(
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       'CPU'                      escp_metric_group,
       CASE h.session_state 
       WHEN 'ON CPU' THEN 'CPU' 
       ELSE 'RMCPUQ' 
       END                        escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.sample_time              escp_end_date,
       to_number(TO_CHAR(COUNT(*)))          escp_value
  FROM cdb_hist_active_sess_history h
 WHERE 1=1 
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
 GROUP BY
       h.session_state,
       h.instance_number,
       h.sample_time
 ORDER BY
       h.session_state,
       h.instance_number,
       h.sample_time)
SELECT escp_instance_number,PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY escp_value) "Percentile 90%"
FROM   cpu_data
Group by escp_instance_number
]';
END;
/

@@&&skip_diagnostics.&&9a_pre_one.


/*****************************************************************************************/
--

DEF title = 'CPU - 97% Percentile';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_HIST_ACTIVE_SESS_HISTORY' 'DBA_HIST_ACTIVE_SESS_HISTORY'
BEGIN
  :sql_text := q'[
With cpu_data AS(
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       'CPU'                      escp_metric_group,
       CASE h.session_state 
       WHEN 'ON CPU' THEN 'CPU' 
       ELSE 'RMCPUQ' 
       END                        escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.sample_time              escp_end_date,
       to_number(TO_CHAR(COUNT(*)))          escp_value
  FROM dba_hist_active_sess_history h
 WHERE 1=1 
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
 GROUP BY
       h.session_state,
       h.instance_number,
       h.sample_time
 ORDER BY
       h.session_state,
       h.instance_number,
       h.sample_time)
SELECT escp_instance_number,ROUND(PERCENTILE_CONT(0.97) WITHIN GROUP (ORDER BY escp_value)) "Percentile 97%"
FROM   cpu_data
Group by escp_instance_number      
]';
  :sql_text_cdb := q'[
With cpu_data AS(
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       'CPU'                      escp_metric_group,
       CASE h.session_state 
       WHEN 'ON CPU' THEN 'CPU' 
       ELSE 'RMCPUQ' 
       END                        escp_metric_acronym,
       TO_CHAR(h.instance_number) escp_instance_number,
       h.sample_time              escp_end_date,
       to_number(TO_CHAR(COUNT(*)))          escp_value
  FROM cdb_hist_active_sess_history h
 WHERE 1=1 
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&mig360_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
 GROUP BY
       h.session_state,
       h.instance_number,
       h.sample_time
 ORDER BY
       h.session_state,
       h.instance_number,
       h.sample_time)
SELECT escp_instance_number,ROUND(PERCENTILE_CONT(0.97) WITHIN GROUP (ORDER BY escp_value)) "Percentile 97%"
FROM   cpu_data
Group by escp_instance_number
]';
END;
/

@@&&skip_diagnostics.&&9a_pre_one.


/*****************************************************************************************/
--
DEF title = 'Memory';
@@&&fc_main_table_name. '&&is_cdb.' 'CDB_HIST_OSSTAT' 'DBA_HIST_OSSTAT'

BEGIN
  :sql_text := q'[
WITH
vm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(CASE WHEN h1.stat_name = 'VM_IN_BYTES'  AND h1.value > h0.value THEN h1.value - h0.value ELSE 0 END) in_bytes,
       SUM(CASE WHEN h1.stat_name = 'VM_OUT_BYTES' AND h1.value > h0.value THEN h1.value - h0.value ELSE 0 END) out_bytes
  FROM &&awr_object_prefix.osstat h0,
       &&awr_object_prefix.osstat h1
 WHERE h1.stat_name IN ('VM_IN_BYTES', 'VM_OUT_BYTES')
   AND h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&mig360_dbid.
   AND h0.snap_id = h1.snap_id - 1
   AND h0.dbid = h1.dbid
   AND h0.instance_number = h1.instance_number
   AND h0.stat_name = h1.stat_name
   AND h0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h0.dbid = &&mig360_dbid.
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
sga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(h1.value) bytes
  FROM &&awr_object_prefix.sga h1
 WHERE h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&mig360_dbid.
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(h1.value) bytes
  FROM &&awr_object_prefix.pgastat h1
 WHERE h1.name = 'total PGA allocated'
   AND h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&mig360_dbid.
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
mem AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snp.snap_id,
       snp.dbid,
       snp.instance_number,
       snp.begin_interval_time,
       snp.end_interval_time,
       ROUND((CAST(snp.end_interval_time AS DATE) - CAST(snp.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       NVL(vm.in_bytes, 0) vm_in_bytes,
       NVL(vm.out_bytes, 0) vm_out_bytes,
       NVL(sga.bytes, 0) sga_bytes,
       NVL(pga.bytes, 0) pga_bytes,
       NVL(sga.bytes, 0) + NVL(pga.bytes, 0) mem_bytes
  FROM &&awr_object_prefix.snapshot snp,
       vm, sga, pga
 WHERE snp.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND snp.dbid = &&mig360_dbid.
   AND snp.end_interval_time > (snp.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND vm.snap_id(+) = snp.snap_id
   AND vm.dbid(+) = snp.dbid
   AND vm.instance_number(+) = snp.instance_number
   AND sga.snap_id(+) = snp.snap_id
   AND sga.dbid(+) = snp.dbid
   AND sga.instance_number(+) = snp.instance_number
   AND pga.snap_id(+) = snp.snap_id
   AND pga.dbid(+) = snp.dbid
   AND pga.instance_number(+) = snp.instance_number
)
SELECT instance_number escp_instance_number,
       'SGA+PGA' stat_name,
       round((avg(mem_bytes)/1024/1024/1024),2) MEM_GB       
  FROM mem
 WHERE mem_bytes > 0
GROUP BY instance_number
UNION
SELECT inst_id escp_instance_number,
       'PHYSICAL_MEMORY',
       round((value/1024/1024/1024),2) MEM_GB 
  FROM GV$OSSTAT 
WHERE stat_name='PHYSICAL_MEMORY_BYTES'
ORDER BY 1,2
]';
  :sql_text_cdb := q'[
WITH
vm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(CASE WHEN h1.stat_name = 'VM_IN_BYTES'  AND h1.value > h0.value THEN h1.value - h0.value ELSE 0 END) in_bytes,
       SUM(CASE WHEN h1.stat_name = 'VM_OUT_BYTES' AND h1.value > h0.value THEN h1.value - h0.value ELSE 0 END) out_bytes
  FROM cdb_hist_osstat h0,
       cdb_hist_osstat h1
 WHERE h1.stat_name IN ('VM_IN_BYTES', 'VM_OUT_BYTES')
   AND h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&mig360_dbid.
   AND h0.snap_id = h1.snap_id - 1
   AND h0.dbid = h1.dbid
   AND h0.instance_number = h1.instance_number
   AND h0.stat_name = h1.stat_name
   AND h0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h0.dbid = &&mig360_dbid.
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
sga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(h1.value) bytes
  FROM cdb_hist_sga h1
 WHERE h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&mig360_dbid.
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       SUM(h1.value) bytes
  FROM cdb_hist_pgastat h1
 WHERE h1.name = 'total PGA allocated'
   AND h1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h1.dbid = &&mig360_dbid.
 GROUP BY
       h1.snap_id,
       h1.dbid,
       h1.instance_number
),
mem AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       snp.snap_id,
       snp.dbid,
       snp.instance_number,
       snp.begin_interval_time,
       snp.end_interval_time,
       ROUND((CAST(snp.end_interval_time AS DATE) - CAST(snp.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       NVL(vm.in_bytes, 0) vm_in_bytes,
       NVL(vm.out_bytes, 0) vm_out_bytes,
       NVL(sga.bytes, 0) sga_bytes,
       NVL(pga.bytes, 0) pga_bytes,
       NVL(sga.bytes, 0) + NVL(pga.bytes, 0) mem_bytes
  FROM cdb_hist_snapshot snp,
       vm, sga, pga
 WHERE snp.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND snp.dbid = &&mig360_dbid.
   AND snp.end_interval_time > (snp.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND vm.snap_id(+) = snp.snap_id
   AND vm.dbid(+) = snp.dbid
   AND vm.instance_number(+) = snp.instance_number
   AND sga.snap_id(+) = snp.snap_id
   AND sga.dbid(+) = snp.dbid
   AND sga.instance_number(+) = snp.instance_number
   AND pga.snap_id(+) = snp.snap_id
   AND pga.dbid(+) = snp.dbid
   AND pga.instance_number(+) = snp.instance_number
)
SELECT instance_number escp_instance_number,
       'SGA+PGA' stat_name,
       round((avg(mem_bytes)/1024/1024/1024),2) MEM_GB       
  FROM mem
 WHERE mem_bytes > 0
GROUP BY instance_number
UNION
SELECT inst_id escp_instance_number,
       'PHYSICAL_MEMORY',
       round((value/1024/1024/1024),2) MEM_GB 
  FROM GV$OSSTAT 
WHERE stat_name='PHYSICAL_MEMORY_BYTES'
ORDER BY 1,2
]';
END;
/

@@&&skip_diagnostics.&&9a_pre_one.


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