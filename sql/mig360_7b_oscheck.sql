COL current_time NEW_V current_time FOR A15;
SELECT 'current_time: ' x, TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') current_time FROM DUAL;

-----------------------------------------

DEF title = 'OS Users';
DEF in_filename = '/etc/passwd'
@@&&fc_def_output_file. out_filename 'ospasswd_&&current_time..txt'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ cat /etc/passwd';
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'OS Groups';
DEF in_filename = '/etc/group'
@@&&fc_def_output_file. out_filename 'osgroup_&&current_time..txt'

HOS if [ -f &&in_filename. ]; then cat &&in_filename. > &&out_filename.; fi

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ cat /etc/group';
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Crontab';
@@&&fc_def_output_file. out_filename 'crontab_&&current_time..txt'

HOS crontab -l > &&out_filename.

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ crontab -l';
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Network Stats';
@@&&fc_def_output_file. out_filename 'netstat_&&current_time..txt'

COL cmd_netstat NEW_V cmd_netstat NOPRI
select decode(platform_id,
1,'netstat -unv -P tcp', -- Solaris[tm] OE (32-bit)
2,'netstat -unv -P tcp', -- Solaris[tm] OE (64-bit)
'netstat -punta') cmd_netstat from v$database;
COL cmd_netstat NEW_V clear

HOS &&cmd_netstat. > &&out_filename.
UNDEF cmd_netstat

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
EXEC :sql_text := '$ netstat -punta';
@@&&9a_pre_one.

-----------------------------------------

DEF title = 'Environment variables';
@@&&fc_def_output_file. out_filename 'env_vars_&&current_time..txt'

HOS env | &&cmd_grep. ORA > &&out_filename

DEF one_spool_text_file = '&&out_filename.'
DEF one_spool_text_file_rename = 'Y'
DEF skip_html = '--';
DEF skip_text_file = ''
@@&&9a_pre_one.

-----------------------------------------

UNDEF skip_if_linux skip_if_sunos
UNDEF current_time out_filename in_filename
