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

dnf install nginx -y &>>$LOGFILE

systemctl enable nginx &>>$LOGFILE

systemctl start nginx &>>$LOGFILE

rm -rf /usr/share/nginx/html/* &>>$LOGFILE

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE

# check my repo own path 

cp /home/ec2-user/expense-project/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE

systemctl restart nginx &>>$LOGFILE
