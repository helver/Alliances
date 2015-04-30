@echo off
copy d:\_EARbase.mdb d:\EARImport.mdb
perl EAR_phase2.pl %*
copy d:\EARImport.mdb d:\%1EAR.mdb
c:\"program files"\winzip\wzzip -ybc d:\%1EAR.zip d:\%1EAR.mdb
