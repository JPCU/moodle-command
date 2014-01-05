#!/bin/sh

cd $1
tar -cpf moodlebackup.tar.gz moodledata/ htdocs/

DB_SERVER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once("$1/htdocs/config.php"); echo $CFG->dbhost;')
DB_NAME=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once("$1/htdocs/config.php"); echo $CFG->dbname;')
DB_USER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once("$1/htdocs/config.php"); echo $CFG->dbuser;')
DB_PASS=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once("$1/htdocs/config.php"); echo $CFG->dbpass;')
TIMESTAMP=$(date +%s)

echo "$DB_SERVER:5432:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
chmod 600 ~/.pgpass

pg_dump -C -h $DB_SERVER -U $DB_USER $DB_NAME -f moodlebackup-$TIMESTAMP.sql

rm ~/.pgpass
unset $DB_SERVER
unset $DB_NAME
unset $DB_USER
unset $DB_PASS

ln -s moodlebackup-$TIMESTAMP.sql moodlebackup-latest.sql

tar --append --file=moodlebackup.tar.gz moodlebackup-$TIMESTAMP.sql
tar --append --file=moodlebackup.tar.gz moodlebackup-latest.sql

rm moodlebackup-$TIMESTAMP.sql
rm moodlebackup-latest.sql

unset $TIMESTAMP
