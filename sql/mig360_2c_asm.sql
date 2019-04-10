/*****************************************************************************************/
--ASM Attributes

DEF title = 'ASM Attributes';
DEF main_table = '&&v_view_prefix.ASM_ATTRIBUTE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_attribute
 ORDER BY
       1, 2
]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--ASM Client

DEF title = 'ASM Client';
DEF main_table = '&&v_view_prefix.ASM_CLIENT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_client
 ORDER BY
       1, 2
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--ASM Template

DEF title = 'ASM Template';
DEF main_table = '&&v_view_prefix.ASM_TEMPLATE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_template
 ORDER BY
       1, 2
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/
--ASM Disk Group

DEF title = 'ASM Disk Group';
DEF main_table = '&&v_view_prefix.ASM_DISKGROUP';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_diskgroup
 ORDER BY
       1, 2
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--ASM Disk Group Stat

DEF title = 'ASM Disk Group Stat';
DEF main_table = '&&v_view_prefix.ASM_DISKGROUP_STAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_diskgroup_stat
 ORDER BY
       1, 2
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--ASM Disk

DEF title = 'ASM Disk';
DEF main_table = '&&v_view_prefix.ASM_DISK';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_disk
 ORDER BY
       1, 2
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--ASM Disk Stat

DEF title = 'ASM Disk Stat';
DEF main_table = '&&v_view_prefix.ASM_DISK_STAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_disk_stat
 ORDER BY
       1, 2
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--ASM Disk IO Stats

DEF title = 'ASM Disk IO Stats';
DEF main_table = '&&gv_view_prefix.ASM_DISK_IOSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.asm_disk_iostat
 ORDER BY
       1, 2, 3, 4, 5
]';
END;
/
@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--ASM File

DEF title = 'ASM File';
DEF main_table = '&&v_view_prefix.ASM_FILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.asm_file
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/
--Files Count per Disk Group

DEF title = 'Files Count per Disk Group';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
count(*) files, name disk_group, 'Datafile' file_type
from
(select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.datafile)
group by name
union all
select count(*) files, name disk_group, 'Tempfile' file_type
from
(select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.tempfile)
group by name
order by 1 desc, 2, 3
]';
END;
/
@@&&9a_pre_one.

/*****************************************************************************************/
--Data and Temp Files Count per Disk Group

DEF title = 'Data and Temp Files Count per Disk Group';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
count(*) files, name disk_group
from
(select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.datafile
union all
select regexp_substr(name, '[^/]+', 1, 1) name from &&v_object_prefix.tempfile)
group by name
order by 1 desc
]';
END;
/
@@&&9a_pre_one.


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/


