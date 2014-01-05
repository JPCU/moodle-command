#!/bin/sh

echo 'Adding code and data directorys to archive...\n'

tar -cpPf moodlebackup.tar.gz ${1}/moodledata/ ${1}/htdocs/

DB_SERVER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbhost;' ${1}/htdocs/config.php)
DB_NAME=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbname;' ${1}/htdocs/config.php)
DB_USER=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbuser;' ${1}/htdocs/config.php)
DB_PASS=$(php -r 'error_reporting(0); define("CLI_SCRIPT", 1); include_once($argv[1]); echo $CFG->dbpass;' ${1}/htdocs/config.php)
TIMESTAMP=$(date +%s)

echo "$DB_SERVER:5432:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
chmod 600 ~/.pgpass

echo 'Downloading database...\n'

pg_dump -C -h $DB_SERVER -U $DB_USER $DB_NAME -f moodlebackup-$TIMESTAMP.sql

echo 'Adding database to archive...\n'

rm ~/.pgpass
unset DB_SERVER
unset DB_NAME
unset DB_USER
unset DB_PASS

ln -s moodlebackup-$TIMESTAMP.sql moodlebackup-latest.sql

tar --append --file=moodlebackup.tar.gz moodlebackup-$TIMESTAMP.sql
tar --append --file=moodlebackup.tar.gz moodlebackup-latest.sql

rm moodlebackup-$TIMESTAMP.sql
rm moodlebackup-latest.sql

unset TIMESTAMP
echo '\nAll done!\n'
