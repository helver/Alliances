#!/bin/bash

BETA=/home/beta
PROD=/home/aswas

cp -f ${BETA}/public_html/* ${PROD}/public_html/
cp -f ${BETA}/public_html/templates/* ${PROD}/public_html/templates/
cp -f ${BETA}/public_html/thematics/* ${PROD}/public_html/thematics/
cp -f ${BETA}/public_html/payments/* ${PROD}/public_html/payments/
cp -f ${BETA}/public_html/ebay/* ${PROD}/public_html/ebay/
cp -f ${BETA}/public_html/EmailTemplates/* ${PROD}/public_html/EmailTemplates/
cp -f ${BETA}/public_html/Filters/* ${PROD}/public_html/Filters/
cp -f ${BETA}/Libs/common_smarty.inc ${PROD}/Libs/common_smarty.inc
cp -f ${BETA}/Libs/AdminObjects/* ${PROD}/Libs/AdminObjects/
cp -f ${BETA}/Libs/Bus_Objects/* ${PROD}/Libs/Bus_Objects/
cp -f ${BETA}/Libs/Ses_Objects/* ${PROD}/Libs/Ses_Objects/
cp -f ${BETA}/Bin/*.php ${PROD}/Bin/
cp -f ${BETA}/Data/schema.sql ${PROD}/Data/

diff -bB --exclude=.psql_history --exclude=templates_c --exclude=.bash_history -r ${BETA} ${PROD}

chown -R beta.beta ${BETA}
chown -R aswas.aswas ${PROD}
