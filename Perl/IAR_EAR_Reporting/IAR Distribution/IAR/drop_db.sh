#!/bin/bash

OUTFILE="/home/tinan/IARDevelopment/IAR/output/${2}/${2}.dump"

mkdir -p "output/${2}"
chmod 777 "output/${2}"

cp /dev/null $OUTFILE

psql -e -d iar -c "SELECT * from companies where id = $1;" >> $OUTFILE
psql -e -d iar -c "SELECT * from entries where company_id = $1;" >> $OUTFILE
psql -e -d iar -c "SELECT * from line_items where company_id = $1;" >> $OUTFILE
psql -e -d iar -c "SELECT * from port_lookup;" >> $OUTFILE
psql -e -d iar -c "SELECT * from filer_lookup;" >> $OUTFILE
psql -e -d iar -c "SELECT * from country_lookup;" >> $OUTFILE
psql -e -d iar -c "SELECT * from entry_type_lookup;" >> $OUTFILE
psql -e -d iar -c "SELECT * from mid_lookup;" >> $OUTFILE
psql -e -d iar -c "SELECT * from hsusa_lookup;" >> $OUTFILE
