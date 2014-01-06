#!/bin/bash

tar -xvf $1 -C $2 $2
tar -xvf $1 -C $3 $3

DB_SERVER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbhost;' ${2}/config.php)
DB_NAME=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbname;' ${2}/config.php)
DB_USER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbuser;' ${2}/config.php)
DB_PASS=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbpass;' ${2}/config.php)



REPLY=$(read "Display database user creation statements? " -n 1 -r)
echo    # new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
	create database $DB_NAME owner $DB_USER;
fi


tar -xvf $1 moodlebackup-latest.sql
tar -xvf $1 $(readlink moodlebackup-latest.sql)
 

echo "$DB_SERVER:5432:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
chmod 600 ~/.pgpass

echo 'Restoring database...'

#pg_dump -C -h $DB_SERVER -U $DB_USER $DB_NAME -f moodlebackup-$TIMESTAMP.sql

psql h $DB_SERVER -U $DB_USER- d $DB_NAME -f moodlebackup-latest.sql
