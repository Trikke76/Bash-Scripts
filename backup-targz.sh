#!/bin/bash
# Script for Backup tar.gz direcotories
# Using eiter FTP or SFTP
#
# Requierments
#
# -ncfpt
# -scp
# -tar
#########################################
# Written by: Guillermo Garron
# Contact at: http://www.go2linux.org/email.html
# Release 0.1
# Web Page: http://linux.go2linux.org
# 
#########################################
#########################################
# Configuration section
# Change the variables here to fit your needs
#####
# FTP or SCP; select the one to prefer to use
METHOD="scp"

####
# Server; Change to the server on which to want to
# store the backup
SERVER="lnxctrl"

####
# Directory to backup; The directory or directories
# to be backed up (spacer separeted)
B_DIRECTORY="/var/lib/egroupware/default/backup"

####
# User; Here put the username you use to log into
# server named above
USER_NAME="p6000221"

####
# Password; Here write down the secret password
# you use to log into the server
SECRET="bluefish"

####
# Remote directory; Put here the directory in the
# remote server where you can write your backup
R_DIRECTORY="/home/p6000221/backup"

####
# Admin email; Put here the email of the person who
# should receive the reports
ADMIN_EMAIL="patrick.uytterhoeven.2192@mai10050601.be"

####
# FTP port; Here put the port where ftp listens in 
# your ftp server
FTP_PORT=21

####
# SSH port; Here goes the ssh port if you use sftp
# instead of ftp
SSH_PORT=22

####
# Command locations; where your commands are, use which
# command to find them
NCFTPPUT="/usr/bin/ncftpput"
TAR="/bin/tar"
MAIL="/usr/sbin/sendmail"
SCP="/usr/bin/scp"

#########################################
# Program section
#########################################
FILE="backup.$(date +"%y-%m-%d").tar.gz"
OUTDIR="/tmp"
FILE_TO_GO="$OUTDIR/$FILE"
EMAIL_FILE="$OUTDIR/email.txt"

$TAR -zcf $FILE_TO_GO $B_DIRECTORY

if [ $METHOD = "ftp" ]
then
	$NCFTPPUT -m -z -u "$USER_NAME" -p "$SECRET" -P "$FTP_PORT" "$SERVER" "$R_DIRECTORY" "$FILE_TO_GO"
	EXIT_V="$?"
	case $EXIT_V in
		0) O="Success.";;
		1) O="Could not connect to remote host.";;
		2) O="Could not connect to remote host - timed out.";;
		3) O="Transfer failed.";;
		4) O="Transfer failed - timed out.";;
		5) O="Directory change failed.";;
		6) O="Directory change failed - timed out.";;
		7) O="Malformed URL.";;
		8) O="Usage error.";;
		9) O="Error in login configuration file.";;
		10) O="Library initialization failed.";;
		11) O="Session initialization failed.";;
	esac
else
	$SCP "$FILE_TO_GO" "$USER_NAME"@"$SERVER":/"$R_DIRECTORY"
	EXIT_V="$?"
	case $EXIT_V in
		0) O="Success";;
		1) O="Error";;
	esac
fi
touch $EMAIL_FILE
echo "Backup result = $O" >> $EMAIL_FILE
echo "Date $(date)" >> $EMAIL_FILE
$MAIL -s "$(hostname) Backup" $ADMIN_EMAIL < $EMAIL_FILE
rm -f $FILE_TO_GO
rm -f $EMAIL_FILE
