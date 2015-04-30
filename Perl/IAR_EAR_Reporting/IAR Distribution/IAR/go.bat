@echo off
mkdir output\%1
rem copy d:\foia_%1.mdb d:\foia.mdb
rem perl IAR.pl liquid=m:/%1.LIQ.txt unliquid=m:/%1.mfx.txt client=%1
rem perl IAR.pl liquid=m:/%1_liq.txt unliquid=m:/%1_mfx.txt client=%1
perl IAR.pl client=%1
rem erase m:\%1.tgz
rem c:\"program files"\winzip\wzzip -ybc m:\%1.tgz output\%1\*.xls
