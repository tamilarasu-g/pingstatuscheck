#!/bin/bash

# Host details
HOSTS_FILE="hosts.csv"

#INFORMATION
INFO="info.txt"

#LOGFILE
LOG="log.txt"

# Credentials for mail
sender="your-email@gmail.com"
receiver="your-email@gmail.com"
gapp="your-app-password from google"
sub="Ping Status"

# Important parameters for ping command

WAIT_TIME=1
COUNT=3

# Check if the info.txt is present or not
if [[ ! -f "${INFO}" ]]
then
    touch ${INFO}
fi

# Check if above command succeded. That is if the file was created successfully
if [[ ${?} -ne 0 ]]
then
    echo "Could not create ${INFO}."
    exit 1
fi

# Check if hosts.csv is present or not

if [[ ! -f "${HOSTS_FILE}" ]]
then
    echo -n "hosts.csv is not present in the current directory !!!"
    exit 1
fi

# Read through the servers.csv file and ping the host

while IFS="@" read -r host
do
    ping -c $COUNT -W $WAIT_TIME ${host} &>${LOG}
    if [[ "${?}" -eq 0`` ]]
    then
        echo "Host ${host} is alive" >> ${INFO}
    else
        echo "Host ${host} is not alive" >> ${INFO}
    fi
done < "${HOSTS_FILE}"

# Body of the mail
body=$(cat ${INFO})

# Send mail

curl -s --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
    --mail-from $sender \
    --mail-rcpt $receiver\
    --user $sender:$gapp \
    -T <(echo -e "From: ${sender}
To: ${receiver}
Subject:${sub}

${body}")

# Check if the mail is sent successfully
if [[ "${?}" -eq 0 ]]
then
    echo "Mail is sent successfully !!!!"
else
    echo "Mail has not been sent due to an error !!!"
fi

# Remove the info.txt after sending the mail
rm ${INFO}