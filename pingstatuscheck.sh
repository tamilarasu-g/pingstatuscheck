#!/bin/bash

# Check if the logfile.txt is present or not
if [[ ! -f "logfile.txt" ]]
then
    touch logfile.txt
fi

# Host details
HOSTS_FILE="hosts.csv"

# Check if hosts.csv is present or not

if [[ ! -f "${HOSTS_FILE}" ]]
then
    echo -n "hosts.csv is not present in the current directory !!!"
    exit 1
fi

# Read through the servers.csv file and ping the host

while IFS="@" read -r host
do
    ping -c 1 -W 1 ${host} &>/dev/null
    if [[ "${?}" -eq 0`` ]]
    then
        echo "Host ${host} is alive" >> logfile.txt
    else
        echo "Host ${host} is not alive" >> logfile.txt
    fi
done < "${HOSTS_FILE}"


# Send mail

sender="your-email@gmail.com"
receiver="your-email@gmail.com"
gapp="your-app-password from google"
sub="Test mail from bash script"
body=$(cat logfile.txt)

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

# Remove the logfile.txt after sending the mail
rm logfile.txt
