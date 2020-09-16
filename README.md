# mig360

MIG360 is a tool to advise Database migrations.

1. Unzip mig360.zip, navigate to the root mig360 directory, and connect as SYS, 
   DBA, or any User with Data Dictionary access:

```
   $ unzip mig360.zip
   $ cd mig360
   $ sqlplus / as sysdba
```

2. Execute mig360.sql.

```
   SQL> @mig360.sql
```

Usage: 

```
@mig360

@mig360 T N

@mig360 T N 1-4

@mig360 T Y 8
```

1st parameter: (T)uning pack, (D)iagnostic pack, (N)one

2nd parameter: Y/N - run or not run ESP_COLLECT - https://github.com/carlos-sierra/esp_collect

3rd parameter: sections (optional) - default all sections

4th parameter: Type of migration (To be implemented)



3. Unzip output MIG360_<dbname>_<host>_YYYYMMDD_HH24MI.zip into a directory on your PC

4. Review main html file 00001_mig360_<dbname>_index.html



## Notes ##

1. As mig360 can run for a long time, in some systems it's recommend to execute it unattended:

   $ nohup sqlplus / as sysdba @mig360.sql T Y &

2. If you need to execute MIG360 against all databases in the host, use mig360.sh:

   $ unzip mig360.zip
   
   $ cd mig360
   
   $ sh mig360.sh T Y
   
   
3. If you need to execute only a portion of MIG360 (i.e. a column, section or range) use 
   these commands. Notice first parameter can be set to one section (i.e. 3b),
   one column (i.e. 3), a range of sections (i.e. 5c-6b) or range of columns (i.e. 5-7):

   SQL> @mig360.sql T N 8
   
   note: valid column range for first parameter is 1 to 9. 


## Versions ##
* v01 (2020-09-16) by Alex Zaballa
