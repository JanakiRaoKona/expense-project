#!/bin/bash

set -e
handle_error() {
  local lineno=$1
  local msg=$2
  echo "Error occur at line no: $lineno: message: $msg"
}
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

source ./comman.sh
check_root

dnf install mysql-server -y &>>$LOGFILE


systemctl enable mysqld &>>$LOGFILE


systemctl start mysqld &>>$LOGFILE


#Below code will e the idempotent nature
mysql -h db.janakiraodevopsapps.fun -uroot -p${my_sql_root_password} -e "SHOW DATABASES;" &>>$LOGFILE

if [ $? -ne 0 ]
    then
        mysql_secure_installation --set-root-pass ${my_sql_root_password} &>>$LOGFILE
        VALIDATE $? "Setting up root password"
    else
        echo -e "MYSQL root password is already setup $Y SKIPPING... $N"
fi  