COL current_time NEW_V current_time FOR A15;
SELECT 'current_time: ' x, TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') current_time FROM DUAL;
EXEC :sql_text := '';
EXEC :sql_text_cdb := '';

-----------------------------------------

DEF title = 'SQLNET Configuration';
DEF in_filename = '$ORACLE_HOME/network/admin/sqlnet.ora'
@@&&fc_def_output_file. out_filename 'sqlnet_&&current_time..ora'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'FIPS Configuration';
DEF in_filename = '$ORACLE_HOME/ldap/admin/fips.ora'
@@&&fc_def_output_file. out_filename 'fips_&&current_time..ora'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'LDAP Configuration';
DEF in_filename = '$ORACLE_HOME/network/admin/ldap.ora'
@@&&fc_def_output_file. out_filename 'ldap_&&current_time..ora'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Microsoft Active Directory Configuration';
DEF in_filename = '$ORACLE_HOME/network/admin/dsi.ora'
@@&&fc_def_output_file. out_filename 'dsi_&&current_time..ora'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'CMAN Configuration';
DEF in_filename = '$ORACLE_HOME/network/admin/cman.ora'
@@&&fc_def_output_file. out_filename 'cman_&&current_time..ora'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Listener Configuration - $ORACLE_HOME';
DEF in_filename = '$ORACLE_HOME/network/admin/listener.ora'
@@&&fc_def_output_file. out_filename 'listener_&&current_time..ora'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Listener Configuration - Current Listener';
@@&&fc_def_output_file. out_filename 'cur_listener_&&current_time..ora'

HOS lsnrctl status | &&cmd_grep. "Listener Parameter File" | &&cmd_awk. '{print $4}' | xargs cat > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'External Procedure Configuration';
DEF in_filename = '$ORACLE_HOME/hs/admin/extproc.ora'
@@&&fc_def_output_file. out_filename 'extproc_&&current_time..ora'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Listener Status/Port';
@@&&fc_def_output_file. out_filename 'listenerstatus_&&current_time..txt'

HOS lsnrctl status > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Listener Status/Port - SRVCTL';
@@&&fc_def_output_file. out_filename 'srvctl_listenerstatus_&&current_time..txt'

HOS srvctl status listener -v > &&out_filename.
HOS srvctl status scan_listener -v >> &&out_filename.
HOS srvctl config listener -a >> &&out_filename.
HOS srvctl config scan_listener >> &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Listener Connections';
DEF main_table = 'DUAL';
@@&&fc_def_output_file. out_filename 'listener_logons_&&current_time..csv'

HOS lsnrctl show trc_directory | &&cmd_grep. trc_directory | &&cmd_awk. '{print $6"/listener.log"}' | xargs cat | &&cmd_grep. -F "establish" | &&cmd_awk. '{ print $1","$2 }' | &&cmd_awk. -F: '{ print ","$1 }' | uniq -c | { echo "COUNT,DATE,HOUR"; cat - ; } > &&out_filename.

@@&&fc_def_output_file. one_spool_html_file 'listener_logons_&&current_time..html'
HOS sh &&sh_csv_to_html_table. "," &&out_filename. &&one_spool_html_file.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_type = 'csv'
DEF one_spool_text_file_rename = 'Y'

DEF skip_html     = '--'
DEF skip_html_file = ''
DEF skip_text_file = ''

@@&&9a_pre_one.

-----------------------------------------

UNDEF current_time out_filename in_filename
