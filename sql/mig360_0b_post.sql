-- Put here any customization that you want to load always after executing the sections.
-- Note it will load only once in the end.

--
UNDEF default_user_list_1
UNDEF default_user_list_2
--
--
--Call eSCP according to the user choice
--
COL escp_exec NEW_V escp_exec NOPRI
SELECT CASE WHEN '&escp_mig360_param.' = 'Y' THEN 'sql/esp_master.sql' ELSE '' END escp_exec FROM DUAL;
COL escp_exec clear
@&&escp_exec.
UNDEF escp_exec

HOS zip -mj &&moat369_zip_filename. awr_ash_pre_check_*.txt > /dev/null

HOS zip -mj &&moat369_zip_filename. quick_db_view_*.txt > /dev/null

--zip ddl for users and tablespaces
HOS zip -mj &&moat369_zip_filename. ddl_users.txt > /dev/null
HOS zip -mj &&moat369_zip_filename. ddl_tablespaces.txt > /dev/null
HOS zip -mj &&moat369_zip_filename. ddl_dbconf.txt > /dev/null