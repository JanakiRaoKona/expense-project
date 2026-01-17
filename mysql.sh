#!/bin/bash
echo "Click Enter Button.."


check_root ()

echo "Click Enter Button.."
read -s my_sql_root_password

source ./comman.sh

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

#Below code will e the idempotent nature
mysql -h db.janakiraodevopsapps.fun -uroot -p${my_sql_root_password} -e "SHOW DATABASES;" &>>$LOGFILE

if [ $? -ne 0 ]
    then
        mysql_secure_installation --set-root-pass ${my_sql_root_password} &>>$LOGFILE
        VALIDATE $? "Setting up root password"
    else
        echo -e "MYSQL root password is already setup $Y SKIPPING... $N"
fi  