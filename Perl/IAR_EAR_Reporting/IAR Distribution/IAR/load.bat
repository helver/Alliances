@echo off

rem copy d:\foia_%1.mdb d:\foia.mdb
rem perl load_data.pl %1 %2
rem perl fill_line_items.pl %1

perl load_all.pl %1 %2 %3