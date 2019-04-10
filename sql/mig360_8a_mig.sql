/*****************************************************************************************/
--
DEF title = 'Data Pump Conventional Export/Import'
@@&&fc_def_output_file. out_filename mig-data-pump-conventional-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_01_data_pump_template_&&mig360_dbtype..sql
SPO OFF;
@@&&fc_spool_end.

@@&&9a_pre_one.

/*****************************************************************************************/
--
DEF title = 'Data Pump Conventional Export/Import - NON-CDB to CDB'
@@&&fc_def_output_file. out_filename mig-data-pump-conventional2-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_01_data_pump_template_noncdb_to_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.

/*****************************************************************************************/
--
DEF title = 'Data Pump Transportable Tablespace';
@@&&fc_def_output_file. out_filename mig-data-pump-transp-tablespace-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_05_data_pump_transportable_tablespace_template_&&mig360_dbtype..sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
--
DEF title = 'Data Pump Transportable Tablespace - NON-CDB to CDB';
@@&&fc_def_output_file. out_filename mig-data-pump-transp-tablespace2-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_05_data_pump_transportable_tablespace_template_noncdb_to_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.

/*****************************************************************************************/
--
--If source is 11.2.0.3
--
DEF title = 'Data Pump Full Transportable';
@@&&fc_def_output_file. out_filename mig-data-pump-full-transp-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_10_data_pump_transportable_tablespace_full_template_&&mig360_dbtype..sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--
--If source is 11.2.0.3
--
DEF title = 'Data Pump Full Transportable - NON-CDB to CDB';
@@&&fc_def_output_file. out_filename mig-data-pump-full-transp2-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_10_data_pump_transportable_tablespace_full_template_noncdb_to_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.

/*****************************************************************************************/
--
DEF title = 'RMAN Transportable Tablespace with Data Pump';
@@&&fc_def_output_file. out_filename mig-rman-transp-tablespace-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_15_rman_transportable_tablespace_with_data_pump_template_&&mig360_dbtype..sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
--
DEF title = 'RMAN Transportable Tablespace with Data Pump - NON-CDB to CDB';
@@&&fc_def_output_file. out_filename mig-rman-transp-tablespace2-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_15_rman_transportable_tablespace_with_data_pump_template_noncdb_to_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.

/*****************************************************************************************/
--
DEF title = 'RMAN Transportable Tablespace with Data Pump - Incremental';
@@&&fc_def_output_file. out_filename mig-inc_transp-tablespace-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_20_rman_incremental_transportable_tablespace_template_&&mig360_dbtype..sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
--
DEF title = 'RMAN Transportable Tablespace with Data Pump - Incremental - NON-CDB to CDB';
@@&&fc_def_output_file. out_filename mig-inc_transp-tablespace2-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_20_rman_incremental_transportable_tablespace_template_noncdb_to_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.

/*****************************************************************************************/
--
DEF title = 'RMAN CONVERT Transportable Tablespace with Data Pump';
@@&&fc_def_output_file. out_filename mig-rman-convert-transp-tablespace-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_25_rman_convert_transportable_tablespace_with_data_pump_template_&&mig360_dbtype..sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
--
DEF title = 'RMAN CONVERT Transportable Tablespace with Data Pump - NON-CDB to CDB';
@@&&fc_def_output_file. out_filename mig-rman-convert-transp-tablespace2-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_25_rman_convert_transportable_tablespace_with_data_pump_template_noncdb_to_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.

/*****************************************************************************************/
--
--If Source is 12c
--
DEF title = 'RMAN Cross-Platform Transportable Tablespace Backup Sets';
@@&&fc_def_output_file. out_filename mig-rman-cross-plat-transp-tablespace-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_30_rman_cross_platform_transportable_tablespace_bkupsets_template_&&mig360_dbtype..sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&9a_pre_one.

/*****************************************************************************************/
--
--If Source is 12c
--
DEF title = 'RMAN Cross-Platform Transportable Tablespace Backup Sets - NON-CDB to CDB';
@@&&fc_def_output_file. out_filename mig-rman-cross-plat-transp-tablespace2-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_30_rman_cross_platform_transportable_tablespace_bkupsets_template_noncdb_to_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.


/*****************************************************************************************/
--
DEF title = 'RMAN Cross-Platform Transportable Tablespace Backup Sets - Incremental - XTTS';
@@&&fc_def_output_file. out_filename mig-rman-cross-plat-transp-tablespace-xtts-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_35_rman_cross_platform_transportable_tablespaces_xtts_template.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.


/*****************************************************************************************/
--
DEF title = 'RMAN Incremental Backup';
@@&&fc_def_output_file. out_filename mig-rman-inc-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_40_rman_inc_bkp_template.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--
--If Source is 12c
--
DEF title = 'Unplugging/Plugging (CDB) - 12.1';
@@&&fc_def_output_file. out_filename mig-unplugging-plugging-pdb-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_45_unplugging_plugging_cdb_12_1.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_when_noncdb.&&9a_pre_one.

HOS rm -f &&skip_when_cdb.&&out_filename.

/*****************************************************************************************/
--
--If Source is 12c
--
DEF title = 'Unplugging/Plugging (CDB) - 12.2+';
@@&&fc_def_output_file. out_filename mig-unplugging-plugging-pdb-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_45_unplugging_plugging_cdb_12_2.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_ver_le_12_1.&&skip_when_noncdb.&&9a_pre_one.

HOS rm -f &&skip_when_cdb.&&out_filename.

/*****************************************************************************************/
--
DEF title = 'Unplugging/Plugging (NON-CDB)';
@@&&fc_def_output_file. out_filename mig-unplugging-plugging-non-cdb-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_45_unplugging_plugging_noncdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.

/*****************************************************************************************/
--
--If Source is 12c
--
DEF title = 'Remote Cloning (CDB)';
@@&&fc_def_output_file. out_filename mig-remote-cloning-pdb-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_50_remote_cloning_cdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_when_noncdb.&&9a_pre_one.

HOS rm -f &&skip_when_cdb.&&out_filename.

/*****************************************************************************************/
--
--If Source is 12c - NON-CDB
--
DEF title = 'Remote Cloning (NON-CDB)';
@@&&fc_def_output_file. out_filename mig-remote-cloning-non-cdb-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_50_remote_cloning_noncdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_when_cdb.&&9a_pre_one.

HOS rm -f &&skip_when_noncdb.&&out_filename.


/*****************************************************************************************/
--
--If Source is 12c
--
DEF title = 'RMAN Cross-Platform Transport of PDB into Destination CDB - 12.2+';
@@&&fc_def_output_file. out_filename mig-rman-cross-plat-transp-pdb-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_55_rman_cross_platform_transportable_pdb.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&skip_ver_le_11.&&skip_ver_le_12_1.&&skip_when_noncdb.&&9a_pre_one.

HOS rm -f &&skip_when_cdb.&&out_filename.


/*****************************************************************************************/
--
DEF title = 'Cloud Backup Module';
@@&&fc_def_output_file. out_filename mig-db-backup-cloud-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_60_cloud_backup_module_template.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.

/*****************************************************************************************/
--
DEF title = 'Data Guard';
@@&&fc_def_output_file. out_filename mig-dr-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_65_oracle_dataguard_template.sql
SPO OFF;
@@&&fc_spool_end.

@@&&skip_ver_le_10.&&9a_pre_one.


/*****************************************************************************************/
--
DEF title = 'Golden Gate (To be Implemented)';
@@&&fc_def_output_file. out_filename mig-ggcs-&&section_id.&&report_sequence..txt

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''

@@&&fc_spool_start.
SPO &&out_filename.
@@sql/mig360_8_70_gg_cloud_service.sql
SPO OFF;
@@&&fc_spool_end.

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