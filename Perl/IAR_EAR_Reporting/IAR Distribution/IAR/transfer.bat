@echo off
copy d:\_IARbase.mdb d:\IARImport.mdb
perl dbtest.pl %1
copy d:\IARImport.mdb d:\%1IAR.mdb
c:\"program files"\winzip\wzzip -ybc d:\%1IAR.zip d:\%1IAR.mdb
