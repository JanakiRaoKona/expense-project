#!/bin/bash


source ./comman.sh
check_root

dnf module disable nodejs -y &>>$LOGFILE


dnf module enable nodejs:24 -y &>>$LOGFILE


dnf install nodejs -y &>>$LOGFILE



id expense &>>$LOGFILE

if [ $? -ne 0 ]
    then
        useradd expense &>>$LOGFILE
        VALIDATE $? "User added to nodejs"
    else
        echo -e "User expense is already created $Y SKIPPING... $N"
fi

mkdir -p /app &>>$LOGFILE


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE


cd /app &>>$LOGFILE
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE


npm install &>>$LOGFILE

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service &>>$LOGFILE

systemctl daemon-reload &>>$LOGFILE
systemctl start backend &>>$LOGFILE
systemctl enable backend &>>$LOGFILE

dnf install mysql -y &>>$LOGFILE
mysql -h db.janakiraodevopsapps.fun -uroot -p${my_sql_root_password} < /app/schema/backend.sql &>>$LOGFILE
systemctl restart backend &>>$LOGFILE