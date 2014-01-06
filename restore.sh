#!/bin/bash
if [ $4 = "dbonly" ]; then


printf "Loading Moodle config... \n"
mv ${2}/config.php ${2}/config.php.orig

awk '!/require/' ${2}/config.php.orig > ${2}/config.php

DB_SERVER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbhost;' ${2}/config.php)
DB_NAME=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbname;' ${2}/config.php)
DB_USER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbuser;' ${2}/config.php)
DB_PASS=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbpass;' ${2}/config.php)

cp ${2}/config.php.orig ${2}/config.php


printf "Unpackaging Moodle database...\n"
tar -xvf $1 moodlebackup-latest.sql
tar -xvf $1 $(readlink moodlebackup-latest.sql)
 

echo "$DB_SERVER:5432:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
chmod 600 ~/.pgpass

printf "Restoring database...\n"

psql h $DB_SERVER -U $DB_USER- d $DB_NAME -f moodlebackup-latest.sql


else


printf "Restoring Moodle code directory... \n"
tar -xPf $1 -C / $2
printf "Restoring Moodle data directory... \n"
tar -xPf $1 -C / $3

printf "Loading Moodle config... \n"
mv ${2}/config.php ${2}/config.php.orig

awk '!/require/' ${2}/config.php.orig > ${2}/config.php

DB_SERVER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbhost;' ${2}/config.php)
DB_NAME=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbname;' ${2}/config.php)
DB_USER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbuser;' ${2}/config.php)
DB_PASS=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbpass;' ${2}/config.php)

cp ${2}/config.php.orig ${2}/config.php


printf "\n\nRun the following on database server:\n"
printf "CREATE USER %s WITH PASSWORD '%s';\n" "$DB_USER" "$DB_PASS"
printf "CREATE DATABASE %s OWNER %s;\n\n" "$DB_NAME" "$DB_USER"

printf "After user and DB are created rerun this script with dbonly"
fi


