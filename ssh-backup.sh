#!/bin/bash
# Created by TEMTEK
# Website: http://www.temtek.net
# License: MIT go to https://opensource.org/licenses/MIT for more information about license
# Zips the given directory recursively
# Uploads to given FTP via cURL
# Sends e-mail right after zipping the file or after uploading the file to FTP successfuly

# Directory to zip
DIRECTORY=~/work
SAVE_DIRECTORY=~/backup

# FTP information
FTP_UPLOAD=n
FTP_USERNAME=
FTP_PASS=""
FTP_SERVER=
FTP_DIR=

# MAIL information
SEND_MAIL=n
MAIL_TO=""
MAIL_SUBJECT="Your Backup is Ready"
MAIL_BODY="Backup successful"

# DO NOT EDIT BELOW THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING!
DATE=`date +'%Y-%m-%d'`
BACKUP_FILE_NAME="backup-$DATE.zip"

# No directory was given
if [ ${#DIRECTORY} -lt 1 ]; then
    echo "No directory was given";
    exit -1;
fi

# Directory doesn't exist, terminate shell script
if [ ! -d "$DIRECTORY" ]; then
    echo "$DIRECTORY doesn't exist";
    exit -2;
fi

# Save directory was given but it doesn't exist
if [[ ${#SAVE_DIRECTORY} > 0 && ! -d "$SAVE_DIRECTORY" ]]; then
    mkdir -m 775 -p "$SAVE_DIRECTORY";
fi

# Save directory is not finishing with /
if [[ "$SAVE_DIRECTORY" != "*/" ]]; then
    SAVE_DIRECTORY="$SAVE_DIRECTORY/"
fi

# ZIP directory first
ZIP_FILE="$SAVE_DIRECTORY$BACKUP_FILE_NAME"
zip -r "$ZIP_FILE" "$DIRECTORY";
echo "zip file $BACKUP_FILE_NAME has been created";

# Send e-mail
if [ "$SEND_MAIL" = "y" ]; then
    echo "$MAIL_BODY" | mail -s "$MAIL_SUBJECT" "$MAIL_TO";
    echo -e "Backup mail has been sent \n"
fi

# Don't Upload via FTP, process finished
if [ "$FTP_UPLOAD" = "n" ]; then
    echo "Backup finished";
    exit 0;
fi

# Uploading via FTP
# FTP directory is not finishing with /
if [[ "$FTP_DIR" != "*/" ]]; then
    FTP_DIR="$FTP_DIR/"
fi

# FTP directory is not beginning with /
if [[ "$FTP_DIR" != "/*" ]]; then
    FTP_DIR="/$FTP_DIR"
fi

# UPLOAD VIA cURL to FTP
curl -T "$ZIP_FILE" ftp://"$FTP_SERVER$FTP_DIR" --user "$FTP_USERNAME":"$FTP_PASS"

# No errors while uploading file
if [ 0 -eq $? ]; then
    if [ "$SEND_MAIL" = "ftp" ]; then
        echo "$MAIL_BODY" | mail -s "$MAIL_SUBJECT" "$MAIL_TO";
        echo -e "Backup mail has been sent \n"
    fi

    # All good, finished
    exit 0;
# There was an error while uploading file
else;
    echo "Couldn't upload backup file to FTP";
    exit -3;
fi
