#!/bin/bash

DEV=/home/dev
BETA=/home/beta

cp -f ${DEV}/public_html/* ${BETA}/public_html/
cp -f ${DEV}/public_html/templates/* ${BETA}/public_html/templates/
cp -f ${DEV}/public_html/thematics/* ${BETA}/public_html/thematics/
cp -f ${DEV}/public_html/payments/* ${BETA}/public_html/payments/
cp -f ${DEV}/public_html/ebay/* ${BETA}/public_html/ebay/
cp -f ${DEV}/public_html/EmailTemplates/* ${BETA}/public_html/EmailTemplates/
cp -f ${DEV}/public_html/Filters/* ${BETA}/public_html/Filters/
cp -f ${DEV}/Libs/common_smarty.inc ${BETA}/Libs/common_smarty.inc
cp -f ${DEV}/Libs/AdminObjects/* ${BETA}/Libs/AdminObjects/
cp -f ${DEV}/Libs/Bus_Objects/* ${BETA}/Libs/Bus_Objects/
cp -f ${DEV}/Libs/Ses_Objects/* ${BETA}/Libs/Ses_Objects/
cp -f ${DEV}/Bin/*.php ${BETA}/Bin/
cp -f ${DEV}/Data/schema.sql ${BETA}/Data/

diff -bB --exclude=.psql_history --exclude=templates_c --exclude=.bash_history -r ${DEV} ${BETA}

chown -R dev.dev ${DEV}
chown -R beta.beta ${BETA}
