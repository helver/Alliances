#!/bin/sh

perl c.pl liquid=/home/tinan/AMERSHAM.LIQ.txt unliquid=/home/tinan/amersham.mfx.txt
tar cvfz /home/tinan/Amersham.tgz output/Amersham/*.xls
