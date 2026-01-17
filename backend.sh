#!/bin/bash


source ./comman.sh
check_root

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:24 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs latest version:24"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

# useradd expense
# VALIDATE $? "User added to nodejs"
id expense &>>$LOGFILE

if [ $? -ne 0 ]
    then
        useradd expense &>>$LOGFILE
        VALIDATE $? "User added to nodejs"
    else
        echo -e "User expense is already created $Y SKIPPING... $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the code..."

cd /app &>>$LOGFILE
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracting backend code"

npm install &>>$LOGFILE
VALIDATE $? "Install npm dependencies"

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading... backend"
systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting... backend"
systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling... backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MYSQL Client"

mysql -h db.janakiraodevopsapps.fun -uroot -p${my_sql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema Loading..."

systemctl restart backend &>>$LOGFILE
VALIDATE $? "ReStarting... backend"