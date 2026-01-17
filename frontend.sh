#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Click Enter Button.."
read -s my_sql_root_password

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Install Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enable Nginx"
systemctl start nginx &>>$LOGFILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Remove existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

# check my repo own path 

cp /home/ec2-user/shell-script/expense-project/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied Expense config"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restart Nginx"