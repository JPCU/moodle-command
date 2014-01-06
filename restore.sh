#!/bin/bash

printf "Restoring Moodle code directory... \n"
tar -xf $1 -C / $2
printf "Restoring Moodle data directory... \n"
tar -xf $1 -C / $3

printf "Loading Moodle config... \n"
cp ${2}/config.php ${2}/config.php.tmp

awk '!/require/' ${2}/config.php > ${2}/config.php

DB_SERVER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbhost;' ${2}/config.php)
DB_NAME=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbname;' ${2}/config.php)
DB_USER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbuser;' ${2}/config.php)
DB_PASS=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbpass;' ${2}/config.php)

#cp ${2}/config.php.tmp ${2}/config.php

printf "\n\nCREATE USER %s WITH PASSWORD '%s';\n" "$DB_USER" "$DB_PASS"
##echo CREATE USER $DB_USER WITH PASSWORD \'$DB_PASS\';
printf "create database %s owner %s;\n\n" "$DB_NAME" "$DB_USER"
##echo create database $DB_NAME owner $DB_USER;

printf "Unpackaging Moodle database...\n"
tar -xvf $1 moodlebackup-latest.sql
tar -xvf $1 $(readlink moodlebackup-latest.sql)
 

echo "$DB_SERVER:5432:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
chmod 600 ~/.pgpass

printf "Restoring database...\n"

#pg_dump -C -h $DB_SERVER -U $DB_USER $DB_NAME -f moodlebackup-$TIMESTAMP.sql

psql h $DB_SERVER -U $DB_USER- d $DB_NAME -f moodlebackup-latest.sql
