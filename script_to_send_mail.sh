#!/bin/bash

#Getting the hostname of the system
host=$(hostname)

#present working directory
pwd=$(pwd)

#Counting the number of records in the csv file
master_sheet_records_count=$(cat master_sheet.csv | awk '(NR > 1)' | wc -l)

#fetching master_sheet details
master_sheet_details=$(cat master_sheet.csv)
#formatting master_sheet details for email
email_body=$(echo "$master_sheet_details" | awk -F '\t' '{printf "%-15s%-25s%-15s%-22s%-20s%-20s%-25s%-25s\n", $1, $2, $3, $4, $5, $6, $7, $8, $9}')


message_body1="Hi All,\nDaily Health check is done for $master_sheet_records_count server(s) ,Please find the results below. \n"
message_body2="Condition of Breach :-"
message_body3="\tServices: Actual number of services not matching the expected number of services.\n\tDisk Space: Disk Space in the respective directory exceeds 80%.\n\tFree Memory: Free Memory in the respective directory goes below to 20% of Total Memory.\n"
message_body4="Thank you,\n"

# Send the email using the mutt command
# Set the subject of the email
subject="Daily Health Check Report"
recipient="email_id_!@xyz.com email_id_2@xyz.com "

#Set the path of the HTML file to attach
html_file="$pwd/output.html"
#echo -e "$message_body1\n$email_body\n\n$message_body2" | mail -s "J&J Daily Health Check Report " -a "$html_file" $recipient

v=`date +%H`
Breached_check=$(cat master_sheet.csv | awk '(NR>1)' | grep Breached | wc -l)

if [ $Breached_check -ge 1 ]; then
    echo -e "$message_body1\n\n$master_sheet_details\n\n$message_body2\n$message_body3\n\n$message_body4" | mail -s "J&J Daily Health Check Report"  -a "$html_file" $recipient
else
    if [[ "$v" -gt 20 ]] && [[ "$v" -lt 22 ]]; then
        echo -e "$message_body1\n\n$master_sheet_details\n\n$message_body2\n$message_body3\n\n$message_body4" | mail -s "J&J Daily Health Check Report"  -a "$html_file" $recipient
        exit 1;
    else
        if [[ "$v" -gt 5 ]] && [[ "$v" -lt 7 ]]; then
            echo -e "$message_body1\n\n$master_sheet_details\n\n$message_body2\n$message_body3\n\n$message_body4" | mail -s "J&J Daily Health Check Report"  -a "$html_file" $recipient
            exit 1;
        else
            if [[ "$v" -gt 11 ]] && [[ "$v" -lt 13 ]]; then
                echo -e "$message_body1\n\n$master_sheet_details\n\n$message_body2\n$message_body3\n\n$message_body4" | mail -s "J&J Daily Health Check Report"  -a "$html_file" $recipient
                exit 1;
            else
                exit 1;
            fi
        fi
    fi
fi
